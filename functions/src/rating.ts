import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";

const db = admin.firestore();

// Calculate ELO rating after a game
export const updateEloRating = onDocumentUpdated(
  "games/{gameId}",
  async (event:any) => {
    const after = event.data?.after.data();
    const before = event.data?.before.data();

    if (!after || !before) return;

    // Only process when game is completed and ELO hasn't been calculated yet
    if (
      after.status !== "completed" ||
      after.eloCalculated === true ||
      before.status === "completed"
    ) {
      return;
    }

    // Only calculate for ranked games
    if (!after.isRanked) {
      await event.data.after.ref.update({ eloCalculated: true });
      return;
    }

    const playerWhiteId = after.playerWhiteId;
    const playerBlackId = after.playerBlackId;

    if (!playerWhiteId || !playerBlackId) {
      return;
    }

    // Get both players' data
    const [whiteDoc, blackDoc] = await Promise.all([
      db.collection("users").doc(playerWhiteId).get(),
      db.collection("users").doc(playerBlackId).get(),
    ]);

    if (!whiteDoc.exists || !blackDoc.exists) {
      return;
    }

    const whiteData = whiteDoc.data()!;
    const blackData = blackDoc.data()!;

    const whiteRating = whiteData.rating || 1200;
    const blackRating = blackData.rating || 1200;
    const whiteGamesPlayed = whiteData.gamesPlayed || 0;
    const blackGamesPlayed = blackData.gamesPlayed || 0;

    // Determine result
    let result: "white" | "black" | "draw";
    if (after.winner === "white") {
      result = "white";
    } else if (after.winner === "black") {
      result = "black";
    } else {
      result = "draw";
    }

    // Calculate new ratings
    const { whiteNewRating, blackNewRating, whiteChange, blackChange } =
      calculateEloChanges(
        whiteRating,
        blackRating,
        whiteGamesPlayed,
        blackGamesPlayed,
        result
      );

    // Update both players
    const batch = db.batch();

    // Update white player
    const whiteRef = db.collection("users").doc(playerWhiteId);
    batch.update(whiteRef, {
      rating: whiteNewRating,
      gamesPlayed: admin.firestore.FieldValue.increment(1),
      ratingHistory: admin.firestore.FieldValue.arrayUnion({
        rating: whiteNewRating,
        change: whiteChange,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      }),
    });

    // Update black player
    const blackRef = db.collection("users").doc(playerBlackId);
    batch.update(blackRef, {
      rating: blackNewRating,
      gamesPlayed: admin.firestore.FieldValue.increment(1),
      ratingHistory: admin.firestore.FieldValue.arrayUnion({
        rating: blackNewRating,
        change: blackChange,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      }),
    });

    // Mark game as ELO calculated
    batch.update(event.data.after.ref, { eloCalculated: true });

    await batch.commit();

    console.log(
      `Updated ELO: ${playerWhiteId} (${whiteRating} → ${whiteNewRating}), ` +
      `${playerBlackId} (${blackRating} → ${blackNewRating})`
    );

    // Check if category changed for either player
    await checkCategoryChange(playerWhiteId, whiteRating, whiteNewRating);
    await checkCategoryChange(playerBlackId, blackRating, blackNewRating);
  }
);

// Calculate ELO changes using standard ELO formula
function calculateEloChanges(
  whiteRating: number,
  blackRating: number,
  whiteGamesPlayed: number,
  blackGamesPlayed: number,
  result: "white" | "black" | "draw"
): {
  whiteNewRating: number;
  blackNewRating: number;
  whiteChange: number;
  blackChange: number;
} {
  // Get K-factors
  const whiteK = getKFactor(whiteGamesPlayed);
  const blackK = getKFactor(blackGamesPlayed);

  // Calculate expected scores
  const whiteExpected = 1 / (1 + Math.pow(10, (blackRating - whiteRating) / 400));
  const blackExpected = 1 / (1 + Math.pow(10, (whiteRating - blackRating) / 400));

  // Calculate actual scores
  let whiteActual: number, blackActual: number;
  if (result === "white") {
    whiteActual = 1;
    blackActual = 0;
  } else if (result === "black") {
    whiteActual = 0;
    blackActual = 1;
  } else {
    whiteActual = 0.5;
    blackActual = 0.5;
  }

  // Calculate rating changes
  const whiteChange = Math.round(whiteK * (whiteActual - whiteExpected));
  const blackChange = Math.round(blackK * (blackActual - blackExpected));

  // Calculate new ratings (minimum 100)
  const whiteNewRating = Math.max(100, whiteRating + whiteChange);
  const blackNewRating = Math.max(100, blackRating + blackChange);

  return { whiteNewRating, blackNewRating, whiteChange, blackChange };
}

// Get K-factor based on number of games played
function getKFactor(gamesPlayed: number): number {
  if (gamesPlayed < 30) return 32;
  if (gamesPlayed < 100) return 24;
  return 16;
}

// Get category by ELO
function getCategoryByElo(elo: number): "A" | "B" | "C" | "D" {
  if (elo < 1500) return "A";
  if (elo < 1800) return "B";
  if (elo < 2000) return "C";
  return "D";
}

// Check and update category if it changed
async function checkCategoryChange(
  userId: string,
  oldRating: number,
  newRating: number
): Promise<void> {
  const oldCategory = getCategoryByElo(oldRating);
  const newCategory = getCategoryByElo(newRating);

  if (oldCategory !== newCategory) {
    await db.collection("users").doc(userId).update({
      currentCategory: newCategory,
      categoryChangedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `User ${userId} category changed: ${oldCategory} → ${newCategory}`
    );
  }
}

// Update monthly leaderboard when user earns stars
export const updateMonthlyLeaderboard = onDocumentUpdated(
  "users/{userId}",
  async (event) => {
    const after = event.data?.after.data();
    const before = event.data?.before.data();

    if (!after || !before) return;

    // Check if monthlyStars changed
    const afterStars = after.monthlyStars || 0;
    const beforeStars = before.monthlyStars || 0;

    if (afterStars === beforeStars) return;

    const userId = event.params.userId;
    const category = after.currentCategory || "A";
    const now = new Date();
    const monthYear = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;
    const categoryKey = `category_${category}`;

    // Update leaderboard entry
    const leaderboardRef = db
      .collection("monthly_leaderboard")
      .doc(monthYear)
      .collection(categoryKey)
      .doc(userId);

    const leaderboardDoc = await leaderboardRef.get();

    if (leaderboardDoc.exists) {
      await leaderboardRef.update({
        totalStars: afterStars,
        displayName: after.displayName || "Unknown",
        elo: after.rating || 1200,
      });
    } else {
      await leaderboardRef.set({
        displayName: after.displayName || "Unknown",
        totalStars: afterStars,
        tournamentsPlayed: after.tournamentsPlayed || 0,
        wins: after.tournamentsWon || 0,
        rank: 0,
        elo: after.rating || 1200,
        avatarUrl: after.photoURL || null,
      });
    }

    // Recalculate ranks for this category
    await recalculateLeaderboardRanks(monthYear, categoryKey);
  }
);

// Recalculate leaderboard ranks
async function recalculateLeaderboardRanks(
  monthYear: string,
  categoryKey: string
): Promise<void> {
  const snapshot = await db
    .collection("monthly_leaderboard")
    .doc(monthYear)
    .collection(categoryKey)
    .orderBy("totalStars", "desc")
    .get();

  const batch = db.batch();
  let rank = 1;

  snapshot.docs.forEach((doc:any) => {
    batch.update(doc.ref, { rank });
    rank++;
  });

  await batch.commit();
}

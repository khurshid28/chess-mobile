import { onSchedule } from "firebase-functions/v2/scheduler";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import admin from "firebase-admin";

const db = admin.firestore();

interface Tournament {
  id: string;
  category: "A" | "B" | "C" | "D";
  minElo: number;
  maxElo: number;
  scheduledTime: admin.firestore.Timestamp;
  status: "pending" | "registration" | "inProgress" | "completed";
  maxPlayers: number;
  currentPlayers: number;
  winnerId?: string;
  runnerUpId?: string;
  thirdPlaceId?: string;
}

interface TournamentParticipant {
  userId: string;
  displayName: string;
  elo: number;
  seed: number;
  joinedAt: admin.firestore.Timestamp;
  isActive: boolean;
  currentRound: number;
  eliminated: boolean;
  stars_earned: number;
}

interface Match {
  matchId: string;
  player1Id: string;
  player2Id: string;
  player1Name?: string;
  player2Name?: string;
  player1Score: number;
  player2Score: number;
  winnerId?: string;
  status: "pending" | "inProgress" | "completed";
  games: any[];
  isArmageddon: boolean;
}

// Schedule daily tournaments - runs at 08:00 UTC (09:00 Uzbekistan time)
export const scheduleDailyTournaments = onSchedule(
  {
    schedule: "0 8 * * *", // 8 AM UTC every day
    timeZone: "Asia/Tashkent",
  },
  async (event) => {
    const today = new Date();
    
    // Tournament times in Uzbekistan timezone (10:00, 14:00, 18:00, 21:00)
    const tournamentTimes = [
      { hour: 10, minute: 0 },
      { hour: 14, minute: 0 },
      { hour: 18, minute: 0 },
      { hour: 21, minute: 0 },
    ];

    const batch = db.batch();

    for (const time of tournamentTimes) {
      const scheduledTime = new Date(today);
      scheduledTime.setHours(time.hour, time.minute, 0, 0);

      // Create tournament for each category
      const categories: Array<{ cat: "A" | "B" | "C" | "D"; min: number; max: number }> = [
        { cat: "A", min: 1200, max: 1500 },
        { cat: "B", min: 1500, max: 1800 },
        { cat: "C", min: 1800, max: 2000 },
        { cat: "D", min: 2000, max: 9999 },
      ];

      for (const category of categories) {
        const tournamentRef = db.collection("tournaments").doc();
        
        // Registration opens 45 minutes before scheduled time
        const registrationTime = new Date(scheduledTime);
        registrationTime.setMinutes(registrationTime.getMinutes() - 45);
        
        const isRegistrationOpen = new Date() >= registrationTime;

        batch.set(tournamentRef, {
          category: category.cat,
          minElo: category.min,
          maxElo: category.max,
          scheduledTime: admin.firestore.Timestamp.fromDate(scheduledTime),
          status: isRegistrationOpen ? "registration" : "pending",
          maxPlayers: 16,
          currentPlayers: 0,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
    console.log(`Created daily tournaments for ${today.toDateString()}`);
  }
);

// Auto-start tournaments when scheduled time is reached
export const autoStartTournaments = onSchedule(
  {
    schedule: "*/5 * * * *", // Every 5 minutes
    timeZone: "Asia/Tashkent",
  },
  async (event) => {
    const now = admin.firestore.Timestamp.now();
    
    // Find tournaments that should start
    const tournamentsSnapshot = await db
      .collection("tournaments")
      .where("status", "==", "registration")
      .where("scheduledTime", "<=", now)
      .get();

    for (const tournamentDoc of tournamentsSnapshot.docs) {
      const tournament = tournamentDoc.data() as Tournament;
      
      if (tournament.currentPlayers >= 2) {
        // Generate bracket and start tournament
        await generateBracket(tournamentDoc.id);
        
        await tournamentDoc.ref.update({
          status: "inProgress",
          startedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        console.log(`Started tournament ${tournamentDoc.id}`);
      } else {
        // Cancel tournament if not enough players
        await tournamentDoc.ref.update({
          status: "completed",
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        
        console.log(`Cancelled tournament ${tournamentDoc.id} - not enough players`);
      }
    }
  }
);

// Generate tournament bracket
async function generateBracket(tournamentId: string): Promise<void> {
  // Get all participants
  const participantsSnapshot = await db
    .collection("tournaments")
    .doc(tournamentId)
    .collection("participants")
    .get();

  const participants: TournamentParticipant[] = participantsSnapshot.docs.map(
    (doc) => doc.data() as TournamentParticipant
  );

  // Sort by ELO for seeding
  participants.sort((a, b) => b.elo - a.elo);

  // Assign seeds
  const batch = db.batch();
  participants.forEach((participant, index) => {
    const participantRef = db
      .collection("tournaments")
      .doc(tournamentId)
      .collection("participants")
      .doc(participant.userId);
    
    batch.update(participantRef, { seed: index + 1 });
  });

  await batch.commit();

  // Create Round 1 bracket (Round of 16)
  const pairings = [
    [1, 16], [8, 9], [4, 13], [5, 12],
    [2, 15], [7, 10], [3, 14], [6, 11]
  ];

  const matches: Match[] = [];
  const totalPlayers = participants.length;

  for (let i = 0; i < 8; i++) {
    const seed1 = pairings[i][0];
    const seed2 = pairings[i][1];

    const player1 = seed1 <= totalPlayers 
      ? participants.find(p => p.seed === seed1)
      : null;
    const player2 = seed2 <= totalPlayers 
      ? participants.find(p => p.seed === seed2)
      : null;

    if (player1 && player2) {
      // Both players present
      matches.push({
        matchId: `r1_m${i + 1}`,
        player1Id: player1.userId,
        player2Id: player2.userId,
        player1Name: player1.displayName,
        player2Name: player2.displayName,
        player1Score: 0,
        player2Score: 0,
        status: "pending",
        games: [],
        isArmageddon: false,
      });
    } else if (player1) {
      // Player 1 gets BYE
      matches.push({
        matchId: `r1_m${i + 1}`,
        player1Id: player1.userId,
        player2Id: "BYE",
        player1Name: player1.displayName,
        player2Name: "BYE",
        player1Score: 2,
        player2Score: 0,
        winnerId: player1.userId,
        status: "completed",
        games: [],
        isArmageddon: false,
      });
    }
  }

  // Save Round 1
  await db
    .collection("tournaments")
    .doc(tournamentId)
    .collection("brackets")
    .doc("round_1")
    .set({
      round: 1,
      matches: matches,
    });
}

// Calculate and distribute monthly prizes - runs on 1st day of each month at 00:00
export const distributeMonthlyPrizes = onSchedule(
  {
    schedule: "0 0 1 * *", // 1st day of month at midnight
    timeZone: "Asia/Tashkent",
  },
  async (event) => {
    const lastMonth = new Date();
    lastMonth.setMonth(lastMonth.getMonth() - 1);
    const monthYear = `${lastMonth.getFullYear()}-${String(lastMonth.getMonth() + 1).padStart(2, "0")}`;

    const categories = ["A", "B", "C", "D"];
    const bonusStars: { [key: string]: number[] } = {
      A: [500, 300, 200],
      B: [750, 450, 300],
      C: [1000, 600, 400],
      D: [1500, 900, 600],
    };

    for (const category of categories) {
      const categoryKey = `category_${category}`;
      
      // Get top 3 for this category
      const leaderboardSnapshot = await db
        .collection("monthly_leaderboard")
        .doc(monthYear)
        .collection(categoryKey)
        .orderBy("totalStars", "desc")
        .limit(3)
        .get();

      const batch = db.batch();
      let rank = 1;

      for (const doc of leaderboardSnapshot.docs) {
        const userId = doc.id;
        const stars = bonusStars[category][rank - 1];

        // Award bonus stars
        const userRef = db.collection("users").doc(userId);
        batch.update(userRef, {
          stars: admin.firestore.FieldValue.increment(stars),
        });

        // Create badge
        const badgeData = {
          type: rank === 1 ? `monthlyChampion${category}` : 
                rank === 2 ? `runnerUp${category}` : 
                `thirdPlace${category}`,
          name: rank === 1 ? `Monthly Champion ${category}` :
                rank === 2 ? `Runner-up ${category}` :
                `3rd Place ${category}`,
          description: `${rank === 1 ? "1st" : rank === 2 ? "2nd" : "3rd"} place in Category ${category} for ${monthYear}`,
          earnedAt: admin.firestore.FieldValue.serverTimestamp(),
          monthYear: monthYear,
        };

        const badgeRef = userRef.collection("badges").doc();
        batch.set(badgeRef, badgeData);

        // Add Grandmaster badge for Category D winner
        if (category === "D" && rank === 1) {
          const gmBadgeRef = userRef.collection("badges").doc();
          batch.set(gmBadgeRef, {
            type: "grandmaster",
            name: "Grandmaster",
            description: "Monthly Champion in Category D (2000+)",
            earnedAt: admin.firestore.FieldValue.serverTimestamp(),
            monthYear: monthYear,
          });
        }

        rank++;
      }

      await batch.commit();
    }

    // Reset monthly stars for all users
    const usersSnapshot = await db
      .collection("users")
      .where("monthlyStars", ">", 0)
      .get();

    const resetBatch = db.batch();
    usersSnapshot.docs.forEach((doc) => {
      resetBatch.update(doc.ref, { monthlyStars: 0 });
    });
    await resetBatch.commit();

    console.log(`Distributed monthly prizes for ${monthYear}`);
  }
);

// Update tournament when match is completed
export const onMatchComplete = onDocumentUpdated(
  "tournaments/{tournamentId}/brackets/{roundId}",
  async (event) => {
    const tournamentId = event.params.tournamentId;
    const after = event.data?.after.data();

    if (!after) return;

    const roundData = after as { round: number; matches: Match[] };
    const allMatchesCompleted = roundData.matches.every(
      (m) => m.status === "completed"
    );

    if (!allMatchesCompleted) return;

    // Award stars for this round
    const roundName = 
      roundData.round === 1 ? "round_of_16" :
      roundData.round === 2 ? "quarter_final" :
      null;

    if (roundName) {
      const tournamentDoc = await db.collection("tournaments").doc(tournamentId).get();
      const tournament = tournamentDoc.data() as Tournament;
      
      // Award stars to winners
      for (const match of roundData.matches) {
        if (match.winnerId && match.winnerId !== "BYE") {
          const stars = getStarsForPlacement(tournament.category, roundName);
          await awardStars(tournamentId, match.winnerId, stars, roundName);
        }
      }
    }

    // Generate next round if not final
    if (roundData.round < 4) {
      await generateNextRound(tournamentId, roundData.round, roundData.matches);
    } else {
      // Tournament completed
      await completeTournament(tournamentId, roundData.matches);
    }
  }
);

function getStarsForPlacement(category: string, placement: string): number {
  const rewards: { [key: string]: { [key: string]: number } } = {
    A: { round_of_16: 5, quarter_final: 15, first_place: 80, second_place: 50, third_place: 30 },
    B: { round_of_16: 7, quarter_final: 20, first_place: 100, second_place: 65, third_place: 40 },
    C: { round_of_16: 10, quarter_final: 25, first_place: 120, second_place: 80, third_place: 50 },
    D: { round_of_16: 15, quarter_final: 35, first_place: 150, second_place: 100, third_place: 65 },
  };
  return rewards[category]?.[placement] || 0;
}

async function awardStars(
  tournamentId: string,
  userId: string,
  stars: number,
  placement: string
): Promise<void> {
  const batch = db.batch();

  // Update user's stars
  const userRef = db.collection("users").doc(userId);
  batch.update(userRef, {
    stars: admin.firestore.FieldValue.increment(stars),
    monthlyStars: admin.firestore.FieldValue.increment(stars),
  });

  // Update participant's stars
  const participantRef = db
    .collection("tournaments")
    .doc(tournamentId)
    .collection("participants")
    .doc(userId);
  batch.update(participantRef, {
    stars_earned: admin.firestore.FieldValue.increment(stars),
  });

  await batch.commit();
}

async function generateNextRound(
  tournamentId: string,
  currentRound: number,
  matches: Match[]
): Promise<void> {
  const winners = matches
    .filter((m) => m.winnerId && m.winnerId !== "BYE")
    .map((m) => m.winnerId!);

  const nextRoundMatches: Match[] = [];
  for (let i = 0; i < winners.length; i += 2) {
    const player1Id = winners[i];
    const player2Id = winners[i + 1];

    // Get player names
    const player1Doc = await db
      .collection("tournaments")
      .doc(tournamentId)
      .collection("participants")
      .doc(player1Id)
      .get();
    const player2Doc = await db
      .collection("tournaments")
      .doc(tournamentId)
      .collection("participants")
      .doc(player2Id)
      .get();

    const player1 = player1Doc.data() as TournamentParticipant;
    const player2 = player2Doc.data() as TournamentParticipant;

    nextRoundMatches.push({
      matchId: `r${currentRound + 1}_m${Math.floor(i / 2) + 1}`,
      player1Id: player1Id,
      player2Id: player2Id,
      player1Name: player1.displayName,
      player2Name: player2.displayName,
      player1Score: 0,
      player2Score: 0,
      status: "pending",
      games: [],
      isArmageddon: false,
    });
  }

  await db
    .collection("tournaments")
    .doc(tournamentId)
    .collection("brackets")
    .doc(`round_${currentRound + 1}`)
    .set({
      round: currentRound + 1,
      matches: nextRoundMatches,
    });
}

async function completeTournament(
  tournamentId: string,
  finalMatches: Match[]
): Promise<void> {
  const finalMatch = finalMatches[0];
  const winnerId = finalMatch.winnerId;
  const runnerUpId = finalMatch.player1Id === winnerId 
    ? finalMatch.player2Id 
    : finalMatch.player1Id;

  // Get tournament data
  const tournamentDoc = await db.collection("tournaments").doc(tournamentId).get();
  const tournament = tournamentDoc.data() as Tournament;

  // Award final prizes
  if (winnerId) {
    await awardStars(
      tournamentId,
      winnerId,
      getStarsForPlacement(tournament.category, "first_place"),
      "first_place"
    );
  }
  if (runnerUpId) {
    await awardStars(
      tournamentId,
      runnerUpId,
      getStarsForPlacement(tournament.category, "second_place"),
      "second_place"
    );
  }

  // Update tournament
  await tournamentDoc.ref.update({
    status: "completed",
    winnerId: winnerId,
    runnerUpId: runnerUpId,
    completedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

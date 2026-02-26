"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.onMatchComplete = exports.distributeMonthlyPrizes = exports.autoStartTournaments = exports.scheduleDailyTournaments = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firestore_1 = require("firebase-functions/v2/firestore");
const firebase_admin_1 = __importDefault(require("firebase-admin"));
const db = firebase_admin_1.default.firestore();
// Schedule daily tournaments - runs at 08:00 UTC (09:00 Uzbekistan time)
exports.scheduleDailyTournaments = (0, scheduler_1.onSchedule)({
    schedule: "0 8 * * *", // 8 AM UTC every day
    timeZone: "Asia/Tashkent",
}, async (event) => {
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
        const categories = [
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
                scheduledTime: firebase_admin_1.default.firestore.Timestamp.fromDate(scheduledTime),
                status: isRegistrationOpen ? "registration" : "pending",
                maxPlayers: 16,
                currentPlayers: 0,
                createdAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
            });
        }
    }
    await batch.commit();
    console.log(`Created daily tournaments for ${today.toDateString()}`);
});
// Auto-start tournaments when scheduled time is reached
exports.autoStartTournaments = (0, scheduler_1.onSchedule)({
    schedule: "*/5 * * * *", // Every 5 minutes
    timeZone: "Asia/Tashkent",
}, async (event) => {
    const now = firebase_admin_1.default.firestore.Timestamp.now();
    // Find tournaments that should start
    const tournamentsSnapshot = await db
        .collection("tournaments")
        .where("status", "==", "registration")
        .where("scheduledTime", "<=", now)
        .get();
    for (const tournamentDoc of tournamentsSnapshot.docs) {
        const tournament = tournamentDoc.data();
        if (tournament.currentPlayers >= 2) {
            // Generate bracket and start tournament
            await generateBracket(tournamentDoc.id);
            await tournamentDoc.ref.update({
                status: "inProgress",
                startedAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Started tournament ${tournamentDoc.id}`);
        }
        else {
            // Cancel tournament if not enough players
            await tournamentDoc.ref.update({
                status: "completed",
                completedAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
            });
            console.log(`Cancelled tournament ${tournamentDoc.id} - not enough players`);
        }
    }
});
// Generate tournament bracket
async function generateBracket(tournamentId) {
    // Get all participants
    const participantsSnapshot = await db
        .collection("tournaments")
        .doc(tournamentId)
        .collection("participants")
        .get();
    const participants = participantsSnapshot.docs.map((doc) => doc.data());
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
    const matches = [];
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
        }
        else if (player1) {
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
exports.distributeMonthlyPrizes = (0, scheduler_1.onSchedule)({
    schedule: "0 0 1 * *", // 1st day of month at midnight
    timeZone: "Asia/Tashkent",
}, async (event) => {
    const lastMonth = new Date();
    lastMonth.setMonth(lastMonth.getMonth() - 1);
    const monthYear = `${lastMonth.getFullYear()}-${String(lastMonth.getMonth() + 1).padStart(2, "0")}`;
    const categories = ["A", "B", "C", "D"];
    const bonusStars = {
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
                stars: firebase_admin_1.default.firestore.FieldValue.increment(stars),
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
                earnedAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
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
                    earnedAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
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
});
// Update tournament when match is completed
exports.onMatchComplete = (0, firestore_1.onDocumentUpdated)("tournaments/{tournamentId}/brackets/{roundId}", async (event) => {
    var _a;
    const tournamentId = event.params.tournamentId;
    const after = (_a = event.data) === null || _a === void 0 ? void 0 : _a.after.data();
    if (!after)
        return;
    const roundData = after;
    const allMatchesCompleted = roundData.matches.every((m) => m.status === "completed");
    if (!allMatchesCompleted)
        return;
    // Award stars for this round
    const roundName = roundData.round === 1 ? "round_of_16" :
        roundData.round === 2 ? "quarter_final" :
            null;
    if (roundName) {
        const tournamentDoc = await db.collection("tournaments").doc(tournamentId).get();
        const tournament = tournamentDoc.data();
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
    }
    else {
        // Tournament completed
        await completeTournament(tournamentId, roundData.matches);
    }
});
function getStarsForPlacement(category, placement) {
    var _a;
    const rewards = {
        A: { round_of_16: 5, quarter_final: 15, first_place: 80, second_place: 50, third_place: 30 },
        B: { round_of_16: 7, quarter_final: 20, first_place: 100, second_place: 65, third_place: 40 },
        C: { round_of_16: 10, quarter_final: 25, first_place: 120, second_place: 80, third_place: 50 },
        D: { round_of_16: 15, quarter_final: 35, first_place: 150, second_place: 100, third_place: 65 },
    };
    return ((_a = rewards[category]) === null || _a === void 0 ? void 0 : _a[placement]) || 0;
}
async function awardStars(tournamentId, userId, stars, placement) {
    const batch = db.batch();
    // Update user's stars
    const userRef = db.collection("users").doc(userId);
    batch.update(userRef, {
        stars: firebase_admin_1.default.firestore.FieldValue.increment(stars),
        monthlyStars: firebase_admin_1.default.firestore.FieldValue.increment(stars),
    });
    // Update participant's stars
    const participantRef = db
        .collection("tournaments")
        .doc(tournamentId)
        .collection("participants")
        .doc(userId);
    batch.update(participantRef, {
        stars_earned: firebase_admin_1.default.firestore.FieldValue.increment(stars),
    });
    await batch.commit();
}
async function generateNextRound(tournamentId, currentRound, matches) {
    const winners = matches
        .filter((m) => m.winnerId && m.winnerId !== "BYE")
        .map((m) => m.winnerId);
    const nextRoundMatches = [];
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
        const player1 = player1Doc.data();
        const player2 = player2Doc.data();
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
async function completeTournament(tournamentId, finalMatches) {
    const finalMatch = finalMatches[0];
    const winnerId = finalMatch.winnerId;
    const runnerUpId = finalMatch.player1Id === winnerId
        ? finalMatch.player2Id
        : finalMatch.player1Id;
    // Get tournament data
    const tournamentDoc = await db.collection("tournaments").doc(tournamentId).get();
    const tournament = tournamentDoc.data();
    // Award final prizes
    if (winnerId) {
        await awardStars(tournamentId, winnerId, getStarsForPlacement(tournament.category, "first_place"), "first_place");
    }
    if (runnerUpId) {
        await awardStars(tournamentId, runnerUpId, getStarsForPlacement(tournament.category, "second_place"), "second_place");
    }
    // Update tournament
    await tournamentDoc.ref.update({
        status: "completed",
        winnerId: winnerId,
        runnerUpId: runnerUpId,
        completedAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
    });
}
//# sourceMappingURL=tournament.js.map
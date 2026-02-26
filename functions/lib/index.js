"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.denormalizeUserProfile = exports.acceptRematch = exports.handleGameAction = exports.cleanupStaleMatchmakingEntries = exports.dequeueFromMatchmaking = exports.enqueueForMatchmaking = exports.claimAbandonment = exports.claimTimeout = exports.makeMove = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-functions/v2/firestore");
const scheduler_1 = require("firebase-functions/v2/scheduler");
const firebase_admin_1 = __importDefault(require("firebase-admin"));
const chess_js_1 = require("chess.js");
firebase_admin_1.default.initializeApp();
const db = firebase_admin_1.default.firestore();
// Export tournament functions
__exportStar(require("./tournament"), exports);
__exportStar(require("./rating"), exports);
const ELO_RANGE = 150;
async function createMatch(transaction, player1, player2, timeControl) {
    const players = [player1, player2];
    const whiteIndex = Math.floor(Math.random() * 2);
    const blackIndex = 1 - whiteIndex;
    const whitePlayer = players[whiteIndex];
    const blackPlayer = players[blackIndex];
    const maxElo = Math.max(whitePlayer.elo, blackPlayer.elo);
    const newGame = {
        fen: INITIAL_FEN,
        pgn: "",
        moves: [],
        status: "inprogress",
        maxElo: maxElo,
        participants: [whitePlayer.id, blackPlayer.id],
        playerWhiteId: whitePlayer.id,
        playerWhiteName: whitePlayer.data.displayName || "Guest",
        playerWhiteElo: whitePlayer.elo,
        playerWhiteCountryCode: whitePlayer.data.countryCode || null,
        playerWhiteImage: whitePlayer.data.profileImage || null,
        playerWhiteStatus: "online",
        playerBlackId: blackPlayer.id,
        playerBlackName: blackPlayer.data.displayName || "Guest",
        playerBlackElo: blackPlayer.elo,
        playerBlackCountryCode: blackPlayer.data.countryCode || null,
        playerBlackImage: blackPlayer.data.profileImage || null,
        playerBlackStatus: "online",
        turn: "w",
        createdAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
        initialTime: timeControl,
        whiteTimeLeft: timeControl,
        blackTimeLeft: timeControl,
        lastMoveTimestamp: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
        eloCalculated: false,
        isRanked: true,
        tournamentId: null,
        tournamentMatchId: null,
        pendingPromotion: null,
        playerWhiteDisconnectedAt: null,
        playerBlackDisconnectedAt: null,
    };
    const newGameRef = db.collection("games").doc();
    transaction.set(newGameRef, newGame);
    return newGameRef.id;
}
const INITIAL_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
const K_FACTOR = 32;
const ABANDONMENT_GRACE_PERIOD_MS = 30 * 1000;
const MIN_MOVES_FOR_ELO = 5;
function getMoveCountFromFen(fen) {
    const parts = fen.split(" ");
    if (parts.length < 6)
        return 1;
    const moveCount = parseInt(parts[5], 10);
    return isNaN(moveCount) ? 1 : moveCount;
}
function validateInput(data, requiredFields) {
    for (const field in requiredFields) {
        if (data[field] === undefined || data[field] === null) {
            if (requiredFields[field].startsWith("optional_"))
                continue;
            throw new https_1.HttpsError("invalid-argument", `Missing required parameter: ${field}`);
        }
        const expectedType = requiredFields[field].replace("optional_", "");
        if (typeof data[field] !== expectedType) {
            throw new https_1.HttpsError("invalid-argument", `Invalid type for parameter: ${field}. Expected ${expectedType}, got ${typeof data[field]}.`);
        }
        if (expectedType === "string" &&
            typeof data[field] === "string" &&
            data[field].trim() === "") {
            if (!requiredFields[field].startsWith("optional_")) {
                throw new https_1.HttpsError("invalid-argument", `Parameter cannot be empty: ${field}`);
            }
        }
    }
}
function parseUci(uci) {
    if (typeof uci !== "string" || uci.length < 4 || uci.length > 5)
        return null;
    const from = uci.substring(0, 2);
    const to = uci.substring(2, 4);
    const promotion = uci.length === 5 ? uci.substring(4, 5) : undefined;
    if (!/^[a-h][1-8]$/.test(from) || !/^[a-h][1-8]$/.test(to))
        return null;
    if (promotion && !/^[qrbn]$/.test(promotion))
        return null;
    return { from, to, promotion };
}
async function finalizeGameAndCalculateElo(transaction, gameRef, gameData, winner, outcome, finalUpdates) {
    let currentGameData;
    if (gameData) {
        currentGameData = gameData;
    }
    else {
        const gameDoc = await transaction.get(gameRef);
        if (!gameDoc.exists) {
            console.error(`Game ${gameRef.id} not found during finalization.`);
            return;
        }
        currentGameData = gameDoc.data();
    }
    if (currentGameData.status === "completed" ||
        currentGameData.status === "error") {
        console.log(`Game ${gameRef.id} already finalized. Skipping ELO calculation and state updates.`);
        return;
    }
    const now = firebase_admin_1.default.firestore.FieldValue.serverTimestamp();
    const finalFen = finalUpdates.fen || currentGameData.fen;
    const moveCount = getMoveCountFromFen(finalFen);
    if (winner === "none" ||
        !currentGameData.playerWhiteId ||
        !currentGameData.playerBlackId ||
        moveCount < MIN_MOVES_FOR_ELO) {
        let finalOutcome = outcome;
        if (moveCount < MIN_MOVES_FOR_ELO &&
            winner !== "draw" &&
            winner !== "none" &&
            outcome !== "internal_error_fen_corruption") {
            finalOutcome = `${outcome}_unrated_early_end`;
        }
        transaction.update(gameRef, Object.assign(Object.assign({}, finalUpdates), { status: outcome.includes("error") ? "error" : "completed", outcome: finalOutcome, winner: winner === "none" ? null : winner, eloCalculated: true, completedAt: now }));
        return;
    }
    const whiteRef = db.collection("users").doc(currentGameData.playerWhiteId);
    const blackRef = db.collection("users").doc(currentGameData.playerBlackId);
    const [whiteDoc, blackDoc] = await Promise.all([
        transaction.get(whiteRef),
        transaction.get(blackRef),
    ]);
    if (!whiteDoc.exists || !blackDoc.exists) {
        console.error(`Missing user documents for game ${gameRef.id}`);
        transaction.update(gameRef, Object.assign(Object.assign({}, finalUpdates), { status: "completed", winner: winner, outcome: outcome, eloCalculated: true, completedAt: now }));
        return;
    }
    const whiteData = whiteDoc.data();
    const blackData = blackDoc.data();
    const eloWhite = whiteData.elo || 1200;
    const eloBlack = blackData.elo || 1200;
    const expectedWhite = 1 / (1 + Math.pow(10, (eloBlack - eloWhite) / 400));
    let scoreWhite;
    if (winner === "white")
        scoreWhite = 1.0;
    else if (winner === "black")
        scoreWhite = 0.0;
    else
        scoreWhite = 0.5;
    const newEloWhite = Math.round(eloWhite + K_FACTOR * (scoreWhite - expectedWhite));
    const newEloBlack = Math.round(eloBlack + K_FACTOR * (1 - scoreWhite - (1 - expectedWhite)));
    const updateStats = (stats, score) => ({
        wins: ((stats === null || stats === void 0 ? void 0 : stats.wins) || 0) + (score === 1.0 ? 1 : 0),
        losses: ((stats === null || stats === void 0 ? void 0 : stats.losses) || 0) + (score === 0.0 ? 1 : 0),
        draws: ((stats === null || stats === void 0 ? void 0 : stats.draws) || 0) + (score === 0.5 ? 1 : 0),
    });
    transaction.update(whiteRef, {
        elo: newEloWhite,
        stats: updateStats(whiteData.stats, scoreWhite),
    });
    transaction.update(blackRef, {
        elo: newEloBlack,
        stats: updateStats(blackData.stats, 1 - scoreWhite),
    });
    transaction.update(gameRef, Object.assign(Object.assign({}, finalUpdates), { status: "completed", winner: winner, outcome: outcome, eloCalculated: true, completedAt: now }));
}
exports.makeMove = (0, https_1.onCall)(async (request) => {
    var _a;
    const { gameId, moveUci, promotion } = request.data;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    validateInput(request.data, {
        gameId: "string",
        moveUci: promotion ? "optional_string" : "string",
        promotion: "optional_string",
    });
    if (!userId) {
        throw new https_1.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const gameRef = db.collection("games").doc(gameId);
    try {
        const result = await db.runTransaction(async (transaction) => {
            const gameDoc = await transaction.get(gameRef);
            if (!gameDoc.exists) {
                throw new Error("Game not found.");
            }
            const gameData = gameDoc.data();
            if (gameData.status !== "inprogress") {
                if (gameData.status === "waiting") {
                    throw new Error("Waiting for opponent to join.");
                }
                return {
                    success: true,
                    outcome: gameData.outcome,
                    alreadyCompleted: true,
                };
            }
            if (!gameData.playerBlackId) {
                throw new Error("Waiting for opponent to join.");
            }
            const playerColor = gameData.playerWhiteId === userId
                ? "w"
                : gameData.playerBlackId === userId
                    ? "b"
                    : null;
            if (!playerColor) {
                throw new Error("Not a participant.");
            }
            const finalizingPromotion = gameData.pendingPromotion &&
                gameData.pendingPromotion.color === playerColor;
            const now = firebase_admin_1.default.firestore.Timestamp.now();
            let timeElapsedMs = 0;
            let newTimeLeft = playerColor === "w" ? gameData.whiteTimeLeft : gameData.blackTimeLeft;
            const isMyTurn = gameData.turn === playerColor;
            if (isMyTurn && !finalizingPromotion) {
                if (gameData.lastMoveTimestamp instanceof firebase_admin_1.default.firestore.Timestamp) {
                    timeElapsedMs =
                        now.toMillis() - gameData.lastMoveTimestamp.toMillis();
                }
                const timeSpentInSeconds = Math.ceil(timeElapsedMs / 1000);
                newTimeLeft -= timeSpentInSeconds;
                if (newTimeLeft <= 0) {
                    newTimeLeft = 0;
                    const winner = playerColor === "w" ? "black" : "white";
                    const finalTimeUpdates = {
                        whiteTimeLeft: playerColor === "w" ? 0 : gameData.whiteTimeLeft,
                        blackTimeLeft: playerColor === "b" ? 0 : gameData.blackTimeLeft,
                        lastMoveTimestamp: now,
                        pendingPromotion: null,
                    };
                    await finalizeGameAndCalculateElo(transaction, gameRef, gameData, winner, "timeout", finalTimeUpdates);
                    return { success: true, outcome: "timeout" };
                }
            }
            if (!isMyTurn && !finalizingPromotion) {
                throw new Error("Not your turn.");
            }
            const chess = new chess_js_1.Chess();
            try {
                chess.load(gameData.fen);
            }
            catch (e) {
                console.error(`CRITICAL: Failed to load FEN in makeMove: ${gameData.fen}`, e);
                await finalizeGameAndCalculateElo(transaction, gameRef, gameData, "none", "internal_error_fen_corruption", {});
                throw new Error("Game state corrupted. Game aborted.");
            }
            let move = null;
            const updates = {};
            if (finalizingPromotion) {
                if (!promotion) {
                    throw new Error("Missing promotion piece.");
                }
                move = chess.move({
                    from: gameData.pendingPromotion.from,
                    to: gameData.pendingPromotion.to,
                    promotion: promotion,
                });
            }
            else {
                if (!moveUci) {
                    throw new Error("Missing move UCI.");
                }
                const moveObject = parseUci(moveUci);
                if (!moveObject) {
                    throw new Error("Invalid UCI format received.");
                }
                const piece = chess.get(moveObject.from);
                const targetRank = moveObject.to.charAt(1);
                const isPawnMove = piece && piece.color === playerColor && piece.type === "p";
                const isLastRank = (playerColor === "w" && targetRank === "8") ||
                    (playerColor === "b" && targetRank === "1");
                if (isPawnMove && isLastRank && !moveObject.promotion) {
                    const validationChess = new chess_js_1.Chess(chess.fen());
                    const validationMove = validationChess.move(Object.assign(Object.assign({}, moveObject), { promotion: "q" }));
                    if (validationMove) {
                        updates.pendingPromotion = {
                            from: moveObject.from,
                            to: moveObject.to,
                            color: playerColor,
                        };
                        updates.playerWhiteDisconnectedAt =
                            playerColor === "w"
                                ? null
                                : gameData.playerWhiteDisconnectedAt || null;
                        updates.playerBlackDisconnectedAt =
                            playerColor === "b"
                                ? null
                                : gameData.playerBlackDisconnectedAt || null;
                        if (isMyTurn) {
                            if (playerColor === "w") {
                                updates.whiteTimeLeft = newTimeLeft;
                            }
                            else {
                                updates.blackTimeLeft = newTimeLeft;
                            }
                            updates.lastMoveTimestamp = now;
                        }
                        transaction.update(gameRef, updates);
                        return { success: true, requiresPromotion: true };
                    }
                }
                move = chess.move(moveObject);
            }
            if (move === null) {
                // CORRECTED LOGGING
                console.error(`SERVER REJECTION: User ${userId} tried move (uci: "${moveUci}", promotion: "${promotion}") on FEN "${gameData.fen}". Move is illegal.`);
                throw new Error("Invalid move.");
            }
            updates.fen = chess.fen();
            updates.turn = chess.turn();
            // Track moves and generate PGN
            const currentMoves = gameData.moves || [];
            const newMoves = [...currentMoves, move.san];
            updates.moves = newMoves;
            // Generate PGN string from moves
            let pgnMoves = "";
            for (let i = 0; i < newMoves.length; i++) {
                if (i % 2 === 0) {
                    pgnMoves += `${Math.floor(i / 2) + 1}. `;
                }
                pgnMoves += `${newMoves[i]} `;
            }
            updates.pgn = pgnMoves.trim();
            if (!updates.lastMoveTimestamp) {
                updates.lastMoveTimestamp = now;
            }
            updates.drawOfferFrom = null;
            updates.pendingPromotion = null;
            if (updates.playerWhiteDisconnectedAt === undefined) {
                updates.playerWhiteDisconnectedAt =
                    playerColor === "w"
                        ? null
                        : gameData.playerWhiteDisconnectedAt || null;
            }
            if (updates.playerBlackDisconnectedAt === undefined) {
                updates.playerBlackDisconnectedAt =
                    playerColor === "b"
                        ? null
                        : gameData.playerBlackDisconnectedAt || null;
            }
            if (isMyTurn && !finalizingPromotion) {
                if (updates.whiteTimeLeft === undefined &&
                    updates.blackTimeLeft === undefined) {
                    if (playerColor === "w") {
                        updates.whiteTimeLeft = newTimeLeft;
                    }
                    else {
                        updates.blackTimeLeft = newTimeLeft;
                    }
                }
            }
            if (chess.isGameOver()) {
                let winner;
                let outcome;
                if (chess.isCheckmate()) {
                    winner = playerColor === "w" ? "white" : "black";
                    outcome = "checkmate";
                }
                else {
                    winner = "draw";
                    if (chess.isStalemate())
                        outcome = "stalemate";
                    else if (chess.isInsufficientMaterial())
                        outcome = "insufficient_material";
                    else if (chess.isThreefoldRepetition())
                        outcome = "threefold_repetition";
                    else if (chess.isDraw())
                        outcome = "50_move_rule";
                    else
                        outcome = "draw";
                }
                await finalizeGameAndCalculateElo(transaction, gameRef, gameData, winner, outcome, updates);
            }
            else {
                transaction.update(gameRef, updates);
            }
            return { success: true };
        });
        return result;
    }
    catch (error) {
        console.error("Transaction failed: ", error);
        let code = "internal";
        const message = error.message;
        if (message.includes("Invalid move") ||
            message.includes("Not your turn") ||
            message.includes("Game is not active") ||
            message.includes("Waiting for opponent") ||
            message.includes("Invalid promotion attempt") ||
            message.includes("Game state corrupted")) {
            code = "failed-precondition";
        }
        else if (message.includes("Missing promotion piece") ||
            message.includes("Missing move UCI") ||
            message.includes("Invalid UCI format")) {
            code = "invalid-argument";
        }
        throw new https_1.HttpsError(code, message);
    }
});
exports.claimTimeout = (0, https_1.onCall)(async (request) => {
    var _a;
    const { gameId } = request.data;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    validateInput(request.data, {
        gameId: "string",
    });
    if (!userId) {
        throw new https_1.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const gameRef = db.collection("games").doc(gameId);
    try {
        const result = await db.runTransaction(async (transaction) => {
            const gameDoc = await transaction.get(gameRef);
            if (!gameDoc.exists) {
                throw new Error("Game not found.");
            }
            const gameData = gameDoc.data();
            if (gameData.status !== "inprogress") {
                return {
                    success: true,
                    outcome: gameData.outcome,
                    alreadyCompleted: true,
                };
            }
            const playerColor = gameData.playerWhiteId === userId
                ? "w"
                : gameData.playerBlackId === userId
                    ? "b"
                    : null;
            if (!playerColor) {
                throw new Error("Not a participant.");
            }
            const opponentColor = gameData.turn;
            if (gameData.pendingPromotion &&
                gameData.pendingPromotion.color === opponentColor) {
                throw new Error("Opponent is selecting promotion. Clock is paused.");
            }
            if (opponentColor === playerColor) {
                throw new Error("Cannot claim timeout on your own turn.");
            }
            const opponentTimeLeft = opponentColor === "w" ? gameData.whiteTimeLeft : gameData.blackTimeLeft;
            const now = firebase_admin_1.default.firestore.Timestamp.now();
            let timeElapsedMs = 0;
            if (gameData.lastMoveTimestamp instanceof firebase_admin_1.default.firestore.Timestamp) {
                timeElapsedMs = now.toMillis() - gameData.lastMoveTimestamp.toMillis();
            }
            const timeSpentInSeconds = Math.ceil(timeElapsedMs / 1000);
            const calculatedTimeLeft = opponentTimeLeft - timeSpentInSeconds;
            if (calculatedTimeLeft > 0) {
                throw new Error(`Opponent has not timed out yet. Remaining: ${calculatedTimeLeft}s`);
            }
            const winner = opponentColor === "w" ? "black" : "white";
            const finalTimeUpdates = {
                whiteTimeLeft: opponentColor === "w" ? 0 : gameData.whiteTimeLeft,
                blackTimeLeft: opponentColor === "b" ? 0 : gameData.blackTimeLeft,
                lastMoveTimestamp: now,
                pendingPromotion: null,
            };
            await finalizeGameAndCalculateElo(transaction, gameRef, gameData, winner, "timeout", finalTimeUpdates);
            return { success: true, outcome: "timeout" };
        });
        return result;
    }
    catch (error) {
        console.error("Claim timeout transaction failed: ", error);
        const code = error.message.includes("Game is not active") ||
            error.message.includes("Cannot claim") ||
            error.message.includes("has not timed out") ||
            error.message.includes("Not a participant") ||
            error.message.includes("Clock is paused")
            ? "failed-precondition"
            : "internal";
        throw new https_1.HttpsError(code, error.message);
    }
});
exports.claimAbandonment = (0, https_1.onCall)(async (request) => {
    var _a;
    const { gameId } = request.data;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    validateInput(request.data, {
        gameId: "string",
    });
    if (!userId) {
        throw new https_1.HttpsError("unauthenticated", "User must be authenticated.");
    }
    const gameRef = db.collection("games").doc(gameId);
    try {
        const result = await db.runTransaction(async (transaction) => {
            const gameDoc = await transaction.get(gameRef);
            if (!gameDoc.exists) {
                throw new Error("Game not found.");
            }
            const gameData = gameDoc.data();
            if (gameData.status !== "inprogress") {
                return {
                    success: true,
                    outcome: gameData.outcome,
                    alreadyCompleted: true,
                };
            }
            const playerColor = gameData.playerWhiteId === userId
                ? "w"
                : gameData.playerBlackId === userId
                    ? "b"
                    : null;
            if (!playerColor) {
                throw new Error("Not a participant.");
            }
            const opponentDisconnectedTimestamp = playerColor === "w"
                ? gameData.playerBlackDisconnectedAt
                : gameData.playerWhiteDisconnectedAt;
            if (!opponentDisconnectedTimestamp ||
                !(opponentDisconnectedTimestamp instanceof firebase_admin_1.default.firestore.Timestamp)) {
                throw new Error("Opponent is not disconnected or timestamp is invalid.");
            }
            const now = firebase_admin_1.default.firestore.Timestamp.now();
            const timeDisconnectedMs = now.toMillis() - opponentDisconnectedTimestamp.toMillis();
            if (timeDisconnectedMs < ABANDONMENT_GRACE_PERIOD_MS) {
                const remaining = Math.ceil((ABANDONMENT_GRACE_PERIOD_MS - timeDisconnectedMs) / 1000);
                throw new Error(`Grace period has not expired yet. Wait ${remaining}s.`);
            }
            const winner = playerColor === "w" ? "white" : "black";
            await finalizeGameAndCalculateElo(transaction, gameRef, gameData, winner, "abandonment", {});
            return { success: true, outcome: "abandonment" };
        });
        return result;
    }
    catch (error) {
        console.error("Claim abandonment transaction failed: ", error);
        const code = error.message.includes("Game is not active") ||
            error.message.includes("Opponent is not disconnected") ||
            error.message.includes("Grace period") ||
            error.message.includes("Not a participant")
            ? "failed-precondition"
            : "internal";
        throw new https_1.HttpsError(code, error.message);
    }
});
exports.enqueueForMatchmaking = (0, https_1.onCall)(async (request) => {
    var _a;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    const { timeControl } = request.data;
    validateInput(request.data, {
        timeControl: "number",
    });
    if (!userId)
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    if (timeControl <= 0)
        throw new https_1.HttpsError("invalid-argument", "Time control must be positive.");
    const userRef = db.collection("users").doc(userId);
    const myQueueRef = db.collection("matchmaking_queue").doc(userId);
    try {
        const result = await db.runTransaction(async (transaction) => {
            const userDoc = await transaction.get(userRef);
            if (!userDoc.exists)
                throw new Error("User profile not found.");
            const userData = userDoc.data();
            const userElo = userData.elo || 1200;
            const activeGameQuery = db
                .collection("games")
                .where("participants", "array-contains", userId)
                .where("status", "in", ["waiting", "inprogress"])
                .limit(1);
            const activeGameSnapshot = await transaction.get(activeGameQuery);
            const existingEntryDoc = await transaction.get(myQueueRef);
            if (!activeGameSnapshot.empty) {
                const activeGameId = activeGameSnapshot.docs[0].id;
                console.warn(`User ${userId} reconnecting to active game ${activeGameId}.`);
                if (existingEntryDoc.exists) {
                    transaction.delete(myQueueRef);
                }
                return { status: "matched", gameId: activeGameId };
            }
            if (existingEntryDoc.exists) {
                const entryData = existingEntryDoc.data();
                if (entryData.matchedGameId) {
                    return { status: "matched", gameId: entryData.matchedGameId };
                }
                if (entryData.timeControl === timeControl) {
                    return { status: "waiting" };
                }
            }
            const opponentsQuery = db
                .collection("matchmaking_queue")
                .where("timeControl", "==", timeControl)
                .where("matchedGameId", "==", null)
                .where("elo", ">=", userElo - ELO_RANGE)
                .where("elo", "<=", userElo + ELO_RANGE)
                .orderBy("elo")
                .orderBy("queuedAt")
                .limit(10);
            const snapshot = await transaction.get(opponentsQuery);
            let opponentId = null;
            for (const doc of snapshot.docs) {
                if (doc.id !== userId) {
                    opponentId = doc.id;
                    break;
                }
            }
            if (opponentId) {
                const opponentRef = db.collection("matchmaking_queue").doc(opponentId);
                const opponentDocLocked = await transaction.get(opponentRef);
                if (!opponentDocLocked.exists) {
                    throw new https_1.HttpsError("aborted", "Contention: Opponent disappeared.");
                }
                const opponentData = opponentDocLocked.data();
                if (opponentData.matchedGameId !== null) {
                    throw new https_1.HttpsError("aborted", "Contention: Opponent already matched.");
                }
                const gameId = await createMatch(transaction, { id: userId, data: userData, elo: userElo }, {
                    id: opponentId,
                    data: opponentData.userData,
                    elo: opponentData.elo,
                }, timeControl);
                transaction.update(opponentRef, {
                    matchedGameId: gameId,
                });
                if (existingEntryDoc.exists) {
                    transaction.delete(myQueueRef);
                }
                return { status: "matched", gameId: gameId };
            }
            else {
                const newEntry = {
                    userId: userId,
                    elo: userElo,
                    timeControl: timeControl,
                    queuedAt: firebase_admin_1.default.firestore.Timestamp.now(),
                    userData: {
                        displayName: userData.displayName || "Guest",
                        countryCode: userData.countryCode || null,
                        profileImage: userData.profileImage || null,
                    },
                    matchedGameId: null,
                };
                transaction.set(myQueueRef, newEntry);
                return { status: "waiting" };
            }
        });
        return result;
    }
    catch (error) {
        console.error("Matchmaking transaction failed: ", error);
        if (error.code === "ABORTED" || error.code === "aborted") {
            throw new https_1.HttpsError("unavailable", "High contention in matchmaking. Please try again shortly.");
        }
        throw new https_1.HttpsError("internal", error.message || "Matchmaking failed.");
    }
});
exports.dequeueFromMatchmaking = (0, https_1.onCall)(async (request) => {
    var _a;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    if (!userId)
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    const queueRef = db.collection("matchmaking_queue").doc(userId);
    try {
        await db.runTransaction(async (transaction) => {
            const entryDoc = await transaction.get(queueRef);
            if (entryDoc.exists) {
                const entryData = entryDoc.data();
                if (entryData.matchedGameId === null) {
                    transaction.delete(queueRef);
                }
            }
        });
        return { success: true };
    }
    catch (error) {
        console.error("Dequeue transaction failed: ", error);
        throw new https_1.HttpsError("internal", "Failed to leave the queue.");
    }
});
// Run every 2 minutes to remove unmatched entries older than 3 minutes
exports.cleanupStaleMatchmakingEntries = (0, scheduler_1.onSchedule)("every 2 minutes", async (event) => {
    const STALE_TIMEOUT_MS = 3 * 60 * 1000;
    const staleThreshold = firebase_admin_1.default.firestore.Timestamp.fromMillis(Date.now() - STALE_TIMEOUT_MS);
    const staleQuery = db
        .collection("matchmaking_queue")
        .where("matchedGameId", "==", null)
        .where("queuedAt", "<", staleThreshold)
        .limit(450);
    try {
        const snapshot = await staleQuery.get();
        if (snapshot.empty) {
            console.log("No stale matchmaking entries to clean up.");
            return;
        }
        const batch = db.batch();
        snapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
        });
        await batch.commit();
        console.log(`Cleaned up ${snapshot.size} stale matchmaking entries.`);
    }
    catch (error) {
        console.error("Error cleaning up stale matchmaking entries:", error);
    }
});
exports.handleGameAction = (0, https_1.onCall)(async (request) => {
    var _a;
    const { gameId, action, value } = request.data;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    validateInput(request.data, {
        gameId: "string",
        action: "string",
        value: "optional_string",
    });
    if (!userId)
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    const gameRef = db.collection("games").doc(gameId);
    return await db.runTransaction(async (transaction) => {
        var _a;
        const gameDoc = await transaction.get(gameRef);
        if (!gameDoc.exists)
            throw new https_1.HttpsError("not-found", "Game not found.");
        const gameData = gameDoc.data();
        const now = firebase_admin_1.default.firestore.FieldValue.serverTimestamp();
        const requiresInProgress = action.includes("draw");
        const requiresCompleted = action === "offer_rematch";
        if (requiresInProgress && gameData.status !== "inprogress") {
            throw new https_1.HttpsError("failed-precondition", "Action requires the game to be in progress.");
        }
        if (requiresCompleted && gameData.status !== "completed") {
            throw new https_1.HttpsError("failed-precondition", "Action requires the game to be completed.");
        }
        if ((action === "resign" || action === "update_status") &&
            gameData.status === "completed") {
            if (action === "update_status") {
                return { success: true, message: "Game already completed." };
            }
        }
        const playerColorStr = gameData.playerWhiteId === userId
            ? "white"
            : gameData.playerBlackId === userId
                ? "black"
                : null;
        const playerColor = playerColorStr === "white"
            ? "w"
            : playerColorStr === "black"
                ? "b"
                : null;
        if (!playerColor)
            throw new https_1.HttpsError("permission-denied", "Not a participant.");
        const updates = {};
        switch (action) {
            case "resign":
                const winner = playerColor === "w" ? "black" : "white";
                await finalizeGameAndCalculateElo(transaction, gameRef, gameData, winner, "resignation", {});
                break;
            case "offer_draw":
                if (gameData.drawOfferFrom === playerColorStr)
                    return { success: true };
                updates.drawOfferFrom = playerColorStr;
                transaction.update(gameRef, updates);
                break;
            case "accept_draw":
                if (gameData.drawOfferFrom &&
                    gameData.drawOfferFrom !== playerColorStr) {
                    await finalizeGameAndCalculateElo(transaction, gameRef, gameData, "draw", "agreed_draw", { drawOfferFrom: null });
                }
                else {
                    throw new https_1.HttpsError("failed-precondition", "No valid draw offer to accept.");
                }
                break;
            case "decline_draw":
                if (gameData.drawOfferFrom &&
                    gameData.drawOfferFrom !== playerColorStr) {
                    updates.drawOfferFrom = null;
                    transaction.update(gameRef, updates);
                }
                else {
                    throw new https_1.HttpsError("failed-precondition", "No valid draw offer to decline.");
                }
                break;
            case "offer_rematch":
                if (gameData.rematchOfferFrom === userId)
                    return { success: true };
                updates.rematchOfferFrom = userId;
                transaction.update(gameRef, updates);
                break;
            case "update_status":
                if (value !== "online" && value !== "disconnected") {
                    throw new https_1.HttpsError("invalid-argument", "Invalid status value.");
                }
                const statusField = `player${playerColorStr.charAt(0).toUpperCase() + playerColorStr.slice(1)}Status`;
                updates[statusField] = value;
                const disconnectionTimestampField = playerColor === "w"
                    ? "playerWhiteDisconnectedAt"
                    : "playerBlackDisconnectedAt";
                const currentStatus = (_a = gameDoc.data()) === null || _a === void 0 ? void 0 : _a[statusField];
                if (value === "disconnected") {
                    if (currentStatus !== "disconnected") {
                        updates[disconnectionTimestampField] = now;
                    }
                }
                else if (value === "online") {
                    updates[disconnectionTimestampField] = null;
                }
                transaction.update(gameRef, updates);
                break;
            default:
                throw new https_1.HttpsError("invalid-argument", "Invalid action.");
        }
        return { success: true };
    });
});
exports.acceptRematch = (0, https_1.onCall)(async (request) => {
    var _a;
    const userId = (_a = request.auth) === null || _a === void 0 ? void 0 : _a.uid;
    const { gameId } = request.data;
    validateInput(request.data, {
        gameId: "string",
    });
    if (!userId)
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    const oldGameRef = db.collection("games").doc(gameId);
    try {
        const result = await db.runTransaction(async (transaction) => {
            const oldGameDoc = await transaction.get(oldGameRef);
            if (!oldGameDoc.exists)
                throw new Error("Old game not found.");
            const oldGameData = oldGameDoc.data();
            if (oldGameData.status !== "completed")
                throw new Error("Game is not completed.");
            if (!oldGameData.eloCalculated) {
                throw new Error("ELO calculation pending. Please wait.");
            }
            if (!oldGameData.playerWhiteId || !oldGameData.playerBlackId)
                throw new Error("Missing players in old game.");
            const isParticipant = oldGameData.playerWhiteId === userId ||
                oldGameData.playerBlackId === userId;
            if (!isParticipant)
                throw new Error("Not a participant.");
            if (oldGameData.nextGameId) {
                return { newGameId: oldGameData.nextGameId };
            }
            if (!oldGameData.rematchOfferFrom ||
                oldGameData.rematchOfferFrom === userId) {
                throw new Error("No valid rematch offer to accept.");
            }
            const whiteRef = db.collection("users").doc(oldGameData.playerBlackId);
            const blackRef = db.collection("users").doc(oldGameData.playerWhiteId);
            const [whiteDoc, blackDoc] = await Promise.all([
                transaction.get(whiteRef),
                transaction.get(blackRef),
            ]);
            if (!whiteDoc.exists || !blackDoc.exists)
                throw new Error("Could not find user profiles.");
            const whiteData = whiteDoc.data();
            const blackData = blackDoc.data();
            const initialTime = oldGameData.initialTime || 300;
            const newGame = {
                fen: INITIAL_FEN,
                pgn: "",
                moves: [],
                status: "inprogress",
                participants: [whiteDoc.id, blackDoc.id],
                playerWhiteId: whiteDoc.id,
                playerWhiteName: whiteData.displayName || "Guest",
                playerWhiteElo: whiteData.elo || 1200,
                playerWhiteCountryCode: whiteData.countryCode || null,
                playerWhiteImage: whiteData.profileImage || null,
                playerWhiteStatus: "online",
                playerBlackId: blackDoc.id,
                playerBlackName: blackData.displayName || "Guest",
                playerBlackElo: blackData.elo || 1200,
                playerBlackCountryCode: blackData.countryCode || null,
                playerBlackImage: blackData.profileImage || null,
                playerBlackStatus: "online",
                turn: "w",
                createdAt: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
                initialTime: initialTime,
                whiteTimeLeft: initialTime,
                blackTimeLeft: initialTime,
                lastMoveTimestamp: firebase_admin_1.default.firestore.FieldValue.serverTimestamp(),
                eloCalculated: false,
                pendingPromotion: null,
                playerWhiteDisconnectedAt: null,
                playerBlackDisconnectedAt: null,
            };
            const newGameRef = db.collection("games").doc();
            transaction.set(newGameRef, newGame);
            transaction.update(oldGameRef, {
                nextGameId: newGameRef.id,
                rematchOfferFrom: null,
            });
            return { newGameId: newGameRef.id };
        });
        return result;
    }
    catch (error) {
        console.error("Rematch transaction failed: ", error);
        const code = error.message.includes("No valid rematch offer") ||
            error.message.includes("Game is not completed") ||
            error.message.includes("ELO calculation pending") ||
            error.message.includes("Not a participant")
            ? "failed-precondition"
            : "internal";
        throw new https_1.HttpsError(code, error.message);
    }
});
exports.denormalizeUserProfile = (0, firestore_1.onDocumentUpdated)("users/{userId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        return null;
    }
    const userId = event.params.userId;
    const beforeData = snapshot.before.data();
    const afterData = snapshot.after.data();
    const updates = {};
    if (beforeData.profileImage !== afterData.profileImage) {
        updates.profileImage = afterData.profileImage || null;
    }
    if (beforeData.displayName !== afterData.displayName) {
        updates.displayName = afterData.displayName || "Guest";
    }
    if (beforeData.countryCode !== afterData.countryCode) {
        updates.countryCode = afterData.countryCode || null;
    }
    if (Object.keys(updates).length === 0) {
        return null;
    }
    const gamesQuery = db
        .collection("games")
        .where("participants", "array-contains", userId);
    const MAX_BATCH_SIZE = 450;
    let lastDoc = null;
    let processedCount = 0;
    try {
        while (true) {
            let query = gamesQuery.limit(MAX_BATCH_SIZE);
            if (lastDoc) {
                query = query.startAfter(lastDoc);
            }
            const gamesSnapshot = await query.get();
            if (gamesSnapshot.empty) {
                break;
            }
            const batch = db.batch();
            gamesSnapshot.docs.forEach((doc) => {
                const gameData = doc.data();
                const gameUpdates = {};
                if (gameData.playerWhiteId === userId) {
                    if (updates.profileImage !== undefined)
                        gameUpdates.playerWhiteImage = updates.profileImage;
                    if (updates.displayName !== undefined)
                        gameUpdates.playerWhiteName = updates.displayName;
                    if (updates.countryCode !== undefined)
                        gameUpdates.playerWhiteCountryCode = updates.countryCode;
                }
                if (gameData.playerBlackId === userId) {
                    if (updates.profileImage !== undefined)
                        gameUpdates.playerBlackImage = updates.profileImage;
                    if (updates.displayName !== undefined)
                        gameUpdates.playerBlackName = updates.displayName;
                    if (updates.countryCode !== undefined)
                        gameUpdates.playerBlackCountryCode = updates.countryCode;
                }
                if (Object.keys(gameUpdates).length > 0) {
                    batch.update(doc.ref, gameUpdates);
                }
            });
            await batch.commit();
            processedCount += gamesSnapshot.size;
            lastDoc = gamesSnapshot.docs[gamesSnapshot.docs.length - 1];
            if (gamesSnapshot.size < MAX_BATCH_SIZE) {
                break;
            }
        }
        console.log(`Successfully denormalized profile updates for user ${userId}. Processed ${processedCount} games.`);
    }
    catch (error) {
        console.error(`Error during denormalization processing for user ${userId}:`, error);
        throw error;
    }
    return null;
});
//# sourceMappingURL=index.js.map
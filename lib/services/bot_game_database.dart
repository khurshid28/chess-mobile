import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bot_game_history_model.dart';
import 'logger_service.dart';

class BotGameDatabase {
  static final BotGameDatabase instance = BotGameDatabase._init();
  static Database? _database;

  BotGameDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bot_games.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    AppLogger().info('🗄️ Initializing bot games database');
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    AppLogger().debug('Database path: $path');
    AppLogger().debug('Opening database...');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    
    AppLogger().info('✅ Database opened successfully');
    return db;
  }

  Future<void> _createDB(Database db, int version) async {
    AppLogger().info('🏗️ Creating bot_games table');
    
    try {
      await db.execute('''
        CREATE TABLE bot_games (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          botId TEXT NOT NULL,
          botName TEXT NOT NULL,
          botRating INTEGER NOT NULL,
          difficulty TEXT NOT NULL,
          result TEXT NOT NULL,
          resultReason TEXT NOT NULL,
          moveHistory TEXT NOT NULL,
          userSide TEXT NOT NULL,
          movesPlayed INTEGER NOT NULL,
          accuracy INTEGER NOT NULL,
          ratingChange INTEGER NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');

      AppLogger().info('✅ Table created successfully');
      AppLogger().debug('Creating index on userId and createdAt...');

      // Create index for faster queries by userId
      await db.execute('''
        CREATE INDEX idx_userId_createdAt ON bot_games(userId, createdAt DESC)
      ''');
      
      AppLogger().info('✅ Index created successfully');
    } catch (e, stackTrace) {
      AppLogger().error('❌ Error creating bot_games table', e, stackTrace);
      rethrow;
    }
  }

  Future<void> insertGame(BotGameHistory game) async {
    AppLogger().info('💾 Inserting bot game to database. ID: ${game.id}, User: ${game.userId}');
    
    try {
      final db = await database;
      
      AppLogger().debug('Database instance obtained');
      
      await db.insert(
        'bot_games',
        {
          'id': game.id,
          'userId': game.userId,
          'botId': game.botId,
          'botName': game.botName,
          'botRating': game.botRating,
          'difficulty': game.difficulty,
          'result': game.result,
          'resultReason': game.resultReason,
          'moveHistory': jsonEncode(game.moveHistory),
          'userSide': game.userSide,
          'movesPlayed': game.movesPlayed,
          'accuracy': game.accuracy,
          'ratingChange': game.ratingChange,
          'createdAt': game.createdAt.millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      AppLogger().info('✅ Bot game inserted successfully');

      // Keep only last 100 games per user
      await _cleanupOldGames(game.userId);
    } catch (e, stackTrace) {
      AppLogger().error('❌ Error inserting bot game to database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _cleanupOldGames(String userId) async {
    final db = await database;
    
    // Get count of games for this user
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bot_games WHERE userId = ?',
      [userId],
    );
    
    final count = Sqflite.firstIntValue(result) ?? 0;
    
    if (count > 100) {
      // Delete oldest games, keeping only the latest 100
      await db.rawDelete('''
        DELETE FROM bot_games 
        WHERE id IN (
          SELECT id FROM bot_games 
          WHERE userId = ? 
          ORDER BY createdAt DESC 
          LIMIT -1 OFFSET 100
        )
      ''', [userId]);
    }
  }

  Future<List<BotGameHistory>> getGamesByUser(String userId, {int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'bot_games',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
      limit: limit,
    );

    return maps.map((map) {
      return BotGameHistory(
        id: map['id'] as String,
        userId: map['userId'] as String,
        botId: map['botId'] as String,
        botName: map['botName'] as String,
        botRating: map['botRating'] as int,
        difficulty: map['difficulty'] as String,
        result: map['result'] as String,
        resultReason: map['resultReason'] as String,
        moveHistory: List<String>.from(jsonDecode(map['moveHistory'] as String)),
        userSide: map['userSide'] as String,
        movesPlayed: map['movesPlayed'] as int,
        accuracy: map['accuracy'] as int,
        ratingChange: map['ratingChange'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
    }).toList();
  }

  Future<BotGameHistory?> getGameById(String id) async {
    final db = await database;
    final maps = await db.query(
      'bot_games',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return BotGameHistory(
      id: map['id'] as String,
      userId: map['userId'] as String,
      botId: map['botId'] as String,
      botName: map['botName'] as String,
      botRating: map['botRating'] as int,
      difficulty: map['difficulty'] as String,
      result: map['result'] as String,
      resultReason: map['resultReason'] as String,
      moveHistory: List<String>.from(jsonDecode(map['moveHistory'] as String)),
      userSide: map['userSide'] as String,
      movesPlayed: map['movesPlayed'] as int,
      accuracy: map['accuracy'] as int,
      ratingChange: map['ratingChange'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  Future<int> getGamesCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bot_games WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> deleteGame(String id) async {
    final db = await database;
    await db.delete(
      'bot_games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllGames(String userId) async {
    final db = await database;
    await db.delete(
      'bot_games',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

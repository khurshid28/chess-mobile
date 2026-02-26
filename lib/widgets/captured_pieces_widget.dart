import 'package:flutter/material.dart';

/// Widget to display captured pieces with material difference
/// Pieces are grouped and same pieces overlap slightly for a nice UI
class CapturedPiecesWidget extends StatelessWidget {
  final String fen;
  final bool isWhiteSide; // Which side's captures to show (pieces this side has taken)
  final double pieceSize;

  const CapturedPiecesWidget({
    super.key,
    required this.fen,
    required this.isWhiteSide,
    this.pieceSize = 20,
  });

  // Starting material for each side
  static const Map<String, int> startingPieces = {
    'P': 8, 'N': 2, 'B': 2, 'R': 2, 'Q': 1,
    'p': 8, 'n': 2, 'b': 2, 'r': 2, 'q': 1,
  };

  // Piece values for material calculation
  static const Map<String, int> pieceValues = {
    'P': 1, 'N': 3, 'B': 3, 'R': 5, 'Q': 9,
    'p': 1, 'n': 3, 'b': 3, 'r': 5, 'q': 9,
  };

  // Piece order for display (Queen first, then Rook, Bishop, Knight, Pawn)
  static const List<String> whitePieceOrder = ['Q', 'R', 'B', 'N', 'P'];
  static const List<String> blackPieceOrder = ['q', 'r', 'b', 'n', 'p'];

  Map<String, int> _countPiecesFromFen(String fen) {
    final board = fen.split(' ').first;
    final counts = <String, int>{};
    
    for (var char in board.split('')) {
      if (RegExp(r'[pnbrqkPNBRQK]').hasMatch(char)) {
        counts[char] = (counts[char] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final currentPieces = _countPiecesFromFen(fen);
    
    // Calculate captured pieces grouped by type
    Map<String, int> capturedByType = {};
    int materialDiff = 0;
    
    // Calculate material for both sides
    int whiteMaterial = 0;
    int blackMaterial = 0;
    for (var piece in ['P', 'N', 'B', 'R', 'Q']) {
      whiteMaterial += (currentPieces[piece] ?? 0) * (pieceValues[piece] ?? 0);
    }
    for (var piece in ['p', 'n', 'b', 'r', 'q']) {
      blackMaterial += (currentPieces[piece] ?? 0) * (pieceValues[piece] ?? 0);
    }
    
    if (isWhiteSide) {
      // Show pieces white has captured (missing black pieces)
      for (var piece in blackPieceOrder) {
        final starting = startingPieces[piece] ?? 0;
        final current = currentPieces[piece] ?? 0;
        final captured = starting - current;
        if (captured > 0) {
          capturedByType[piece] = captured;
        }
      }
      materialDiff = whiteMaterial - blackMaterial;
    } else {
      // Show pieces black has captured (missing white pieces)
      for (var piece in whitePieceOrder) {
        final starting = startingPieces[piece] ?? 0;
        final current = currentPieces[piece] ?? 0;
        final captured = starting - current;
        if (captured > 0) {
          capturedByType[piece] = captured;
        }
      }
      materialDiff = blackMaterial - whiteMaterial;
    }

    if (capturedByType.isEmpty && materialDiff <= 0) {
      return const SizedBox(height: 22);
    }

    // Build piece groups
    List<Widget> pieceGroups = [];
    final pieceOrder = isWhiteSide ? blackPieceOrder : whitePieceOrder;
    
    for (var piece in pieceOrder) {
      final count = capturedByType[piece] ?? 0;
      if (count > 0) {
        pieceGroups.add(_buildPieceGroup(piece, count));
      }
    }

    return SizedBox(
      height: 22,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: pieceGroups,
              ),
            ),
          ),
          if (materialDiff > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '+$materialDiff',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build a group of same pieces with overlap
  Widget _buildPieceGroup(String piece, int count) {
    final isBlackPiece = piece == piece.toLowerCase();
    
    if (count == 1) {
      return Container(
        padding: const EdgeInsets.only(right: 2),
        decoration: isBlackPiece ? BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ) : null,
        child: _buildPieceIcon(piece),
      );
    }

    // Multiple pieces - stack them with overlap
    final overlapOffset = pieceSize * 0.55;
    final totalWidth = pieceSize + (count - 1) * overlapOffset;

    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: totalWidth,
      height: pieceSize,
      decoration: isBlackPiece ? BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ) : null,
      child: Stack(
        children: List.generate(count, (index) {
          return Positioned(
            left: index * overlapOffset,
            child: _buildPieceIcon(piece),
          );
        }),
      ),
    );
  }

  Widget _buildPieceIcon(String piece) {
    final isWhitePiece = piece == piece.toUpperCase();
    final prefix = isWhitePiece ? 'w' : 'b';
    final pieceLetter = piece.toUpperCase();
    
    return SizedBox(
      width: pieceSize,
      height: pieceSize,
      child: Image.asset(
        'assets/piece_sets/cburnett/$prefix$pieceLetter.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            piece,
            style: TextStyle(
              color: isWhitePiece ? Colors.white : Colors.grey,
              fontSize: pieceSize * 0.8,
            ),
          );
        },
      ),
    );
  }
}

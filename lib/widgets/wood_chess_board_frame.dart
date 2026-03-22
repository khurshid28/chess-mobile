import 'package:flutter/material.dart';
import 'package:chess_park/theme/wood_borders.dart';
import 'package:chess_park/theme/wood_colors.dart';
import 'package:chess_park/theme/wood_gradients.dart';
import 'package:chess_park/theme/wood_shadows.dart';
import 'package:chess_park/theme/wood_text_styles.dart';
import 'package:chess_park/theme/wood_textures.dart';

/// Classic wooden chess design system — chess board with carved wooden frame.
///
/// Renders an 8×8 chess board inside a polished wooden border frame.
/// Optionally draws coordinate labels (a-h / 1-8) in the frame style.
///
/// Pass [pieces] as a flat 64-element list (a1=0, b1=1 … h8=63)
/// to render piece images on squares, or leave it null for an empty board.
///
/// ```dart
/// WoodChessBoardFrame(
///   size: 360,
///   pieceSetPath: 'assets/piece_sets/staunton',
///   pieces: myPieceList,
///   highlightSquares: {52, 44},
/// )
/// ```
class WoodChessBoardFrame extends StatelessWidget {
  const WoodChessBoardFrame({
    super.key,
    this.size,
    this.pieces,
    this.highlightSquares = const {},
    this.pieceSetPath,
    this.showCoordinates = true,
    this.flipped = false,
    this.onSquareTap,
    this.selectedSquare,
  });

  /// Total outer widget size (frame + board). If null, fills available space.
  final double? size;

  /// 64-element list mapping square index → piece asset name (e.g. 'wK', 'bP').
  /// Null entries mean an empty square.
  final List<String?>? pieces;

  /// Square indices that should receive the highlight overlay.
  final Set<int> highlightSquares;

  /// Path prefix for piece image assets, e.g. 'assets/piece_sets/staunton'.
  final String? pieceSetPath;

  /// Show a-h / 1-8 file and rank labels inside the frame.
  final bool showCoordinates;

  /// Render from Black's perspective when true.
  final bool flipped;

  final void Function(int squareIndex)? onSquareTap;

  /// Currently selected / source square index.
  final int? selectedSquare;

  static const double _frameThickness = 24.0;
  static const List<String> _files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
  static const List<String> _ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final outerSize = size ?? constraints.maxWidth;
        final boardSize = outerSize - _frameThickness * 2;
        final sqSize   = boardSize / 8;

        return Container(
          width: outerSize,
          height: outerSize,
          decoration: BoxDecoration(
            image: WoodTextures.frame(),
            borderRadius: WoodBorders.smallRadius,
            border: WoodBorders.boardFrame,
            boxShadow: WoodShadows.boardShadow,
          ),
          child: Stack(
            children: [
              // Frame highlight
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: WoodBorders.smallRadius,
                      gradient: WoodGradients.topHighlight,
                    ),
                  ),
                ),
              ),

              // Coordinate labels in frame
              if (showCoordinates) ...[
                _FileLabels(
                  outerSize: outerSize,
                  frameThickness: _frameThickness,
                  squareSize: sqSize,
                  flipped: flipped,
                ),
                _RankLabels(
                  outerSize: outerSize,
                  frameThickness: _frameThickness,
                  squareSize: sqSize,
                  flipped: flipped,
                ),
              ],

              // The board itself
              Positioned(
                top: _frameThickness,
                left: _frameThickness,
                child: SizedBox(
                  width: boardSize,
                  height: boardSize,
                  child: _BoardGrid(
                    squareSize: sqSize,
                    pieces: pieces,
                    highlightSquares: highlightSquares,
                    selectedSquare: selectedSquare,
                    pieceSetPath: pieceSetPath,
                    flipped: flipped,
                    onSquareTap: onSquareTap,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Board grid ──────────────────────────────────────────────────────────────

class _BoardGrid extends StatelessWidget {
  const _BoardGrid({
    required this.squareSize,
    required this.pieces,
    required this.highlightSquares,
    required this.selectedSquare,
    required this.pieceSetPath,
    required this.flipped,
    required this.onSquareTap,
  });

  final double squareSize;
  final List<String?>? pieces;
  final Set<int> highlightSquares;
  final int? selectedSquare;
  final String? pieceSetPath;
  final bool flipped;
  final void Function(int)? onSquareTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(8, (rowIdx) {
        final rank = flipped ? rowIdx : 7 - rowIdx;
        return Row(
          children: List.generate(8, (colIdx) {
            final file = flipped ? 7 - colIdx : colIdx;
            final squareIndex = rank * 8 + file;
            final isLight = (rank + file) % 2 != 0;
            final isHighlighted = highlightSquares.contains(squareIndex);
            final isSelected   = selectedSquare == squareIndex;
            final pieceName    = pieces != null ? pieces![squareIndex] : null;

            return _Square(
              size: squareSize,
              isLight: isLight,
              isHighlighted: isHighlighted,
              isSelected: isSelected,
              pieceName: pieceName,
              pieceSetPath: pieceSetPath,
              onTap: onSquareTap != null
                  ? () => onSquareTap!(squareIndex)
                  : null,
            );
          }),
        );
      }),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({
    required this.size,
    required this.isLight,
    required this.isHighlighted,
    required this.isSelected,
    required this.pieceName,
    required this.pieceSetPath,
    required this.onTap,
  });

  final double size;
  final bool isLight;
  final bool isHighlighted;
  final bool isSelected;
  final String? pieceName;
  final String? pieceSetPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color squareColor = isLight ? WoodColors.boardLight : WoodColors.boardDark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base square colour
            ColoredBox(color: squareColor),

            // Highlight overlay (last move / valid move dots)
            if (isHighlighted)
              const ColoredBox(color: WoodColors.boardHighlight),

            // Selected square ring
            if (isSelected)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: WoodColors.gold,
                    width: 3,
                  ),
                ),
              ),

            // Piece image
            if (pieceName != null && pieceSetPath != null)
              Padding(
                padding: EdgeInsets.all(size * 0.05),
                child: Image.asset(
                  '$pieceSetPath/$pieceName.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Coordinate labels ───────────────────────────────────────────────────────

class _FileLabels extends StatelessWidget {
  const _FileLabels({
    required this.outerSize,
    required this.frameThickness,
    required this.squareSize,
    required this.flipped,
  });

  final double outerSize;
  final double frameThickness;
  final double squareSize;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    final labels = flipped
        ? WoodChessBoardFrame._files.reversed.toList()
        : WoodChessBoardFrame._files;

    return Positioned(
      bottom: 4,
      left: frameThickness,
      child: Row(
        children: labels.map((f) {
          return SizedBox(
            width: squareSize,
            child: Center(
              child: Text(
                f,
                style: WoodTextStyles.caption.copyWith(
                  color: WoodColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RankLabels extends StatelessWidget {
  const _RankLabels({
    required this.outerSize,
    required this.frameThickness,
    required this.squareSize,
    required this.flipped,
  });

  final double outerSize;
  final double frameThickness;
  final double squareSize;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    final labels = flipped
        ? WoodChessBoardFrame._ranks
        : WoodChessBoardFrame._ranks.reversed.toList();

    return Positioned(
      top: frameThickness,
      left: 4,
      child: Column(
        children: labels.map((r) {
          return SizedBox(
            height: squareSize,
            child: Center(
              child: Text(
                r,
                style: WoodTextStyles.caption.copyWith(
                  color: WoodColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

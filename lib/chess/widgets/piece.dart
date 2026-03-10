import 'package:dartchess/dartchess.dart' show Piece;
import 'package:flutter/widgets.dart';
import '../models.dart';
import '../images.dart';

/// Widget that displays a chess piece.
class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    required this.size,
    required this.pieceAssets,
    this.opacity,
    this.blindfoldMode = false,
    this.upsideDown = false,
    this.pieceScale = 0.82,
  });

  /// Specifies the role and color of the piece.
  final Piece piece;

  /// Size of the board square the piece will occupy.
  final double size;

  /// Scale factor for piece size relative to square size.
  /// Default is 0.82 (piece size = squareSize * 0.82).
  final double pieceScale;

  /// Piece set assets.
  final PieceAssets pieceAssets;

  /// Pieces are hidden in blindfold mode.
  final bool blindfoldMode;

  /// If `true` the piece is displayed fliped on Y axis.
  final bool upsideDown;

  /// This value is used to animate the opacity of the piece.
  final Animation<double>? opacity;

  /// [AssetImage] provider for the piece.
  AssetImage get imageProvider => pieceAssets[piece.kind]!;

  @override
  Widget build(BuildContext context) {
    if (blindfoldMode) {
      return SizedBox(width: size, height: size);
    }

    final pieceSize = size * pieceScale;
    final fromCache = ChessgroundImages.instance.get(imageProvider);

    final image =
        fromCache != null
            ? RawImage(
              image: fromCache,
              debugImageLabel: 'PieceWidgetCache(${imageProvider.assetName})',
              width: pieceSize,
              height: pieceSize,
              opacity: opacity,
            )
            : Image(
              image: imageProvider,
              width: pieceSize,
              height: pieceSize,
              opacity: opacity,
            );

    final piece = upsideDown ? Transform.flip(flipY: true, child: image) : image;

    // Center the smaller piece within the square
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: piece),
    );
  }
}

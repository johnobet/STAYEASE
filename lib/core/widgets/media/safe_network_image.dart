import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Drop-in replacement for `Image.network` that never lets a broken URL
/// crash the layout. Without this, a failed image load renders Flutter's
/// raw exception text in place of the image — which overflows any
/// fixed-size container and shows the ugly yellow/black debug stripes.
///
/// Used everywhere a property photo is shown (property cards, gallery,
/// reservation thumbnails) since photo URLs are user-entered (Owner's
/// Add Property form) and can't be guaranteed valid.
class SafeNetworkImage extends StatelessWidget {
  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = url.isEmpty
        ? _fallback()
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _fallback(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _fallback(loading: true);
            },
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  Widget _fallback({bool loading = false}) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceSunken,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textTertiary),
            )
          : Icon(Icons.image_not_supported_outlined, color: AppColors.textTertiary, size: (width ?? 40) * 0.35),
    );
  }
}

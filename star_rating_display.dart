// ============================================================
// widgets/star_rating_display.dart - عرض التقييم بالنجوم
// ============================================================
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// عرض تقييم للقراءة فقط
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final double starSize;
  final bool showCount;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.ratingCount = 0,
    this.starSize = 16,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // النجوم
        ...List.generate(5, (i) {
          final filled = i < rating.floor();
          final half   = !filled && i < rating;
          return Icon(
            filled ? Icons.star : (half ? Icons.star_half : Icons.star_border),
            color: AppTheme.goldColor,
            size: starSize,
          );
        }),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: starSize * 0.8,
              fontWeight: FontWeight.w700,
              color: AppTheme.goldColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($ratingCount)',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: starSize * 0.75,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

/// تقييم تفاعلي قابل للضغط
class StarRatingInput extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final double starSize;

  const StarRatingInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starSize = 36,
  });

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () {
            setState(() => _rating = (i + 1).toDouble());
            widget.onRatingChanged(_rating);
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              i < _rating ? Icons.star : Icons.star_border,
              key: ValueKey('$i-${i < _rating}'),
              color: AppTheme.goldColor,
              size: widget.starSize,
            ),
          ),
        );
      }),
    );
  }
}

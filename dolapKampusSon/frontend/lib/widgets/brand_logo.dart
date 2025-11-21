import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double height;
  final bool showText;
  const BrandLogo({super.key, this.height = 32, this.showText = true});

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      'assets/images/campus_marketplace_logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.shopping_bag_outlined,
            size: height, color: Theme.of(context).colorScheme.onPrimary);
      },
    );

    if (!showText) return image;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        const SizedBox(width: 10),
        Text(
          'Campus Marketplace',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ],
    );
  }
}



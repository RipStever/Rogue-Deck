import 'package:flutter/material.dart';

class DividerLineWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const DividerLineWidget({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: color,
    );
  }
}

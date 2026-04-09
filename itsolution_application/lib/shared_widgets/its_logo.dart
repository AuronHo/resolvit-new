import 'package:flutter/material.dart';
import '../constants/app_colors.dart'; // <-- 1. Import your app colors

// 2. Your class code
class ItsLogo extends StatelessWidget {
  final double size;
  final Color color;
  
  // 3. Make kPrimaryBlue optional by default
  const ItsLogo({
    super.key, 
    this.size = 48, 
    this.color = kPrimaryBlue // kPrimaryBlue comes from your import
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "IT's",
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
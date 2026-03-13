import 'package:flutter/material.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final double boxheight;

  GradientHeader({super.key, required this.title, required this.boxheight});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    return Container(
      height: height*boxheight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2DD4BF),
            Color(0xFF1FA2FF),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
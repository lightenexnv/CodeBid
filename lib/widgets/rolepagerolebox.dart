import 'package:flutter/material.dart';

class RoleBoxWidget extends StatelessWidget {
  final double boxheight;
  final Color gradientstart;
  final Color gradientend;
  final IconData displayicon;
  final String titletext;
  final String desctext;
  final VoidCallback ontapfunction;

  const RoleBoxWidget({super.key, required this.boxheight, required this.gradientstart,
  required this.gradientend,
  required this.displayicon,
    required this.titletext,
    required this.desctext,
    required this.ontapfunction

  });



  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return InkWell(
      onTap: ontapfunction,
      child: Container(
        height: height * boxheight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              gradientstart,
              gradientend,
            ],
          ),
        ),

        child: Row(
          children: [

            Icon(
              displayicon,
              color: Colors.white,
              size: 40,
            ),

            const SizedBox(width: 20),


            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titletext,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desctext,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Container(
        height: height * 0.23,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2DD4BF),
              Color(0xFF1FA2FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    Image.asset("assets/logo/codebid-logo-only-white.png",height: 30,),
                    const SizedBox(width: 8),
                    const Text(
                      "CodeBid",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                Row(
                  children: [

                    IconButton(icon: Icon(Icons.notifications_none),
                        color: Colors.white,
                      onPressed: () {  },),

                    const SizedBox(width: 15),

                    CircleAvatar(
                      radius: 16,
                      backgroundImage: AssetImage("assets/logo/codebid-logo-only-color.png",)
                    )
                  ],
                )
              ],
            ),

            const SizedBox(height: 25),
            Container(
              height: height * 0.06,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),

              child: TextField(
                cursorColor: Color(0xFF1FA2FF),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: "Search bugs, tasks...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

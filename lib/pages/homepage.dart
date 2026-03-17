
import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/pages/taskoverviewpage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final ref = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("tasks");

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      body: Column(
        children: [

          Container(
            height: height * 0.23,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2DD4BF),
                  Color(0xFF1FA2FF),
                ],
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
                        Image.asset(
                          "assets/logo/codebid-logo-only-white.png",
                          height: 30,
                        ),
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
                        IconButton(
                          icon: const Icon(Icons.notifications_none),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            Get.find<NavController>().changeIndex(4);
                          },
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              "assets/logo/codebid-logo-only-color.png",
                            ),
                          ),
                        ),
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
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search bugs, tasks...",
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ),

          Expanded(
              child: StreamBuilder(stream: ref.onValue,
                  builder: (context, snapshot){
                if(!snapshot.hasData||snapshot.data!.snapshot.value==null){
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1FA2FF),
                    ),
                  );
                }

                final data = Map<String,dynamic>.from(
                    snapshot.data!.snapshot.value as Map
                );
                final tasks = data.values.toList();


                return ListView.builder(
                    padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                    itemBuilder: (context,index){
                      final task = Map<String,dynamic>.from(tasks[index]);
                      final images = task["images"] ?? [];

                      return GestureDetector(
                        onTap: (){
                          Get.to(TaskOverviewPage(task: task));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                              color: Colors.black.withValues(alpha: 1)
                            )]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (images.isNotEmpty)
                                Hero(
                                  tag: "display-image",
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      images[0],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              SizedBox(height: height * 0.01,),

                              Text(
                                task["title"] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                task["description"] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),

                              SizedBox(height: height * 0.01,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₹ ${task["budget"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1FA2FF),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 14)
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  })
          )
        ],
      ),
    );
  }
}
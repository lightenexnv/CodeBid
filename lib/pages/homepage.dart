
import 'package:codebid/controllers/nav_controller.dart';
import 'package:codebid/pages/taskoverviewpage.dart';
import 'package:codebid/utils/timeUtil.dart';
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
                      final createdAt = task["createdAt"];

                      int timestamp = 0;

                      if (createdAt is int) {
                        timestamp = createdAt;
                      }
                      else if (createdAt is String && createdAt.isNotEmpty) {
                        try {
                          final parsedDate = DateTime.parse(createdAt);
                          timestamp = parsedDate.millisecondsSinceEpoch;
                        } catch (e) {
                          timestamp = 0;
                        }
                      }

                      if (timestamp == 0) {
                        return const Text("Invalid date");
                      }


                      return GestureDetector(
                        onTap: () {
                          Get.to(TaskOverviewPage(task: task));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              if (images.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    images[0],
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      task["title"]?.toString() ?? "",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Text(
                                          "₹ ${task["budget"]}",
                                          style: const TextStyle(
                                            color: Color(0xFF1FA2FF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "${task["bids"] ?? 0} Bids",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),


                                     Text(
                                      TimeUtils.getTimeAgo(timestamp),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
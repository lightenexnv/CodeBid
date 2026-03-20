import 'package:codebid/pages/createtaskpage.dart';
import 'package:codebid/pages/tasks_all_bids_page.dart';
import 'package:codebid/pages/tasksbidspage.dart';
import 'package:codebid/pages/placebidpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class TaskOverviewPage extends StatelessWidget {
  final Map task;

  const TaskOverviewPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    final images = task["images"] ?? [];

    return Scaffold(
      floatingActionButton: StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref("codebid_database")
            .child("tasks")
            .child(task["taskId"])
            .onValue,
        builder: (context, snapshot) {

          if (!snapshot.hasData ||
              snapshot.data!.snapshot.value == null) {
            return const SizedBox();
          }

          final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);

          final isClosed = data["isClosed"] == true;
          final currentUser = FirebaseAuth.instance.currentUser;

          final isOwner = currentUser?.uid == task["createdBy"];

          if (!isOwner || isClosed) {
            return const SizedBox();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              Get.to(CreateTaskPage(
                isEdit: true,
                task: task,
              ));
            },
            backgroundColor: const Color(0xFF1FA2FF),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              "Edit Task",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFF4F6FB),

      body: Stack(
        children: [

          Container(
            height: height * 0.15,
            width: double.infinity,
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
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task["title"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (images.isNotEmpty)
                  Hero(
                    tag: "display-image",
                    child: Container(
                      width: width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          images[0],
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    StreamBuilder(stream: FirebaseDatabase.instance.ref("codebid_database").
                                        child("tasks").child(task["taskId"]).onValue,
                                        builder: (context, snapshot){
                                      if(!snapshot.hasData || snapshot.data!.snapshot.value== null){
                                        return const Text("0");
                                      }
                                      final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);


                                      return Text(
                                        "₹ ${data["lowestBid"]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1FA2FF),
                                          fontSize: 40,
                                        ),
                                      )
                                        ;}),
                                    const Text("Lowest Bid",
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                Row(children: [
                                  const Text("Budget",
                                      style: TextStyle(color: Colors.grey)),
                                  SizedBox(width: 10,),
                                  Text(
                                    "₹ ${task["budget"]}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1FA2FF),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],)
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task["description"] ?? "",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          if (task["github"] != null &&
                              task["github"].toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link,
                                      color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      task["github"],
                                      style: const TextStyle(
                                        color: Color(0xFF1FA2FF),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 25),

                          StreamBuilder(
                            stream: FirebaseDatabase.instance
                                .ref("codebid_database")
                                .child("users")
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .onValue,
                            builder: (context, userSnap) {

                              if (!userSnap.hasData ||
                                  userSnap.data!.snapshot.value == null) {
                                return const SizedBox();
                              }

                              final role =
                              (userSnap.data!.snapshot.value as Map)["role"];

                              return StreamBuilder(
                                stream: FirebaseDatabase.instance
                                    .ref("codebid_database")
                                    .child("tasks")
                                    .child(task["taskId"])
                                    .onValue,
                                builder: (context, taskSnap) {

                                  if (!taskSnap.hasData ||
                                      taskSnap.data!.snapshot.value == null) {
                                    return const SizedBox();
                                  }

                                  final data = Map<String, dynamic>.from(
                                      taskSnap.data!.snapshot.value as Map);

                                  final isClosed = data["isClosed"] == true;

                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(

                                      onPressed: role == "requester"
                                          ? () {
                                        Get.to(TasksAllBids(
                                          taskId: task["taskId"],
                                          taskTitle: task["title"],
                                          createdBy: task["createdBy"],
                                        ));
                                      }
                                          : isClosed
                                          ? null
                                          : () {
                                        Get.to(PlaceBidPage(task: task));
                                      },

                                      style: ElevatedButton.styleFrom(
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                        backgroundColor:
                                        (role == "requester" || isClosed)
                                            ? Colors.blue
                                            : const Color(0xFF1FA2FF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),

                                      child: Text(
                                        isClosed
                                            ? "Bidding Closed"
                                            : role == "requester"
                                            ? "View Bids"
                                            : "Place a Bid",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
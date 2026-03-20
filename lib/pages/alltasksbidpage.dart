import 'package:codebid/pages/tasks_all_bids_page.dart';
import 'package:codebid/pages/taskoverviewpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AllTasksBidPage extends StatelessWidget {
  const AllTasksBidPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final user = FirebaseAuth.instance.currentUser;

    final tasksRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("tasks");

    final userRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(user!.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [

          Container(
            height: height * 0.2,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2DD4BF),
                  Color(0xFF1FA2FF),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 20),

                StreamBuilder(stream: userRef.onValue,
                    builder: (context,snapshot){
                  if(!snapshot.hasData|| snapshot.data!.snapshot.value == null){
                    return Text(
                      "Bids",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  final userData = Map<String,dynamic>.from(snapshot.data!.snapshot.value as Map);
                  final role = userData["role"];

                  if(role == "requester"){
                    return Text(
                      "Task Bids",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }else{
                    return Text(
                      "My Bids",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    );}}
                    ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder(
                    stream: userRef.onValue,
                    builder: (context, userSnap) {

                      if (!userSnap.hasData ||
                          userSnap.data!.snapshot.value == null) {
                        return const Center(child: Text("Loading..."));
                      }

                      final userData = Map<String, dynamic>.from(
                          userSnap.data!.snapshot.value as Map);

                      final role = userData["role"] ?? "";

                      return StreamBuilder(
                        stream: tasksRef.onValue,
                        builder: (context, snapshot) {

                          if (!snapshot.hasData ||
                              snapshot.data!.snapshot.value == null) {
                            return const Center(
                                child: Text("No Tasks Found"));
                          }

                          final raw =
                          snapshot.data!.snapshot.value as Map;

                          final data = raw.map(
                                (key, value) => MapEntry(
                              key.toString(),
                              Map<String, dynamic>.from(value as Map),
                            ),
                          );

                          List<Map<String, dynamic>> tasksList = [];

                          data.forEach((taskId, task) {

                            if (role == "requester") {
                              if (task["createdBy"] == user.uid) {
                                tasksList.add({
                                  ...task,
                                  "taskId": taskId,
                                });
                              }
                            }

                            else {
                              final bids = task["bids"];

                              if (bids != null) {
                                final bidsMap =
                                Map<String, dynamic>.from(bids);

                                for (var bid in bidsMap.values) {
                                  final bidData =
                                  Map<String, dynamic>.from(bid);

                                  if (bidData["userId"] == user.uid) {
                                    tasksList.add({
                                      ...task,
                                      "taskId": taskId,
                                    });
                                    break;
                                  }
                                }
                              }
                            }

                          });

                          if (tasksList.isEmpty) {
                            return const Center(
                                child: Text("No Tasks Found"));
                          }

                          return ListView.builder(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: tasksList.length,
                            itemBuilder: (context, index) {

                              final task = tasksList[index];
                              final isClosed = task["isClosed"] == true;

                              return GestureDetector(
                                onTap: () {

                                  if (role == "requester") {
                                    Get.to(() => TasksAllBids(
                                      taskId: task["taskId"],
                                      taskTitle: task["title"],
                                      createdBy: task["createdBy"],
                                    ));
                                  }

                                  else {
                                    Get.to(() => TaskOverviewPage(task: task));
                                  }

                                },
                                child: Container(
                                  margin:
                                  const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.06),
                                        blurRadius: 12,
                                        offset:
                                        const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [

                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            task["title"] ?? "",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          if (role == "requester") ...[
                                            const SizedBox(height: 6),

                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isClosed
                                                    ? Colors.red.withOpacity(0.1)
                                                    : Colors.orange.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                isClosed ? "Closed" : "Active",
                                                style: TextStyle(
                                                  color: isClosed ? Colors.red : Colors.orange,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [

                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [

                                              const Text(
                                                "Budget",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),

                                              Text(
                                                "₹${task["budget"]}",
                                                style:
                                                const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height: 5),

                                              const Text(
                                                "Lowest Bid",
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),

                                              Text(
                                                task["lowestBid"] == null
                                                    ? "--"
                                                    : "₹${task["lowestBid"]}",
                                                style:
                                                const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500,
                                                ),
                                              ),
                                            ],
                                          ),

                                          Column(
                                            children: [

                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  children: [

                                                    Text(
                                                      role == "requester"
                                                          ? "VIEW BIDS"
                                                          : "OPEN",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.green,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),

                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      color: Colors.green,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
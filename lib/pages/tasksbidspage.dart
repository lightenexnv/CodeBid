import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BidsPage extends StatelessWidget {
  const BidsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final User? user = FirebaseAuth.instance.currentUser;
    final ref =
    FirebaseDatabase.instance.ref("codebid_database").child("tasks");

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

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
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "My Bids",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: ref.onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(child: Text("No Bids Yet"));
                      }

                      final data = Map<String, dynamic>.from(
                          snapshot.data!.snapshot.value
                          as Map<dynamic, dynamic>);

                      List<Map<String, dynamic>> myBids = [];

                      data.forEach((taskId, taskData) {
                        final taskMap =
                        Map<String, dynamic>.from(taskData);

                        if (taskMap["bids"] != null) {
                          final bidsMap = Map<String, dynamic>.from(
                              taskMap["bids"]);

                          bidsMap.forEach((bidId, bidData) {
                            final bid =
                            Map<String, dynamic>.from(bidData);

                            if (bid["userId"] == user.uid) {
                              myBids.add({
                                "taskTitle":
                                taskMap["title"] ?? "No Title",
                                "amount": bid["amount"] ?? 0,
                                "timestamp": bid["timestamp"] ?? 0,
                                "status":
                                bid["status"] ?? "Pending",
                              });
                            }
                          });
                        }
                      });

                      if (myBids.isEmpty) {
                        return const Center(
                            child: Text("No bids found"));
                      }

                      myBids.sort((a, b) =>
                          (b["timestamp"] ?? 0)
                              .compareTo(a["timestamp"] ?? 0));

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: myBids.length,
                        itemBuilder: (context, index) {
                          final bid = myBids[index];

                          return Container(
                            margin:
                            const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.05),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bid["taskTitle"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Your Bid: ₹${bid["amount"]}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.green,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          "Accept",
                                          style: TextStyle(
                                              color:
                                              Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.red,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          "Decline",
                                          style: TextStyle(
                                              color:
                                              Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Status: ${bid["status"]}",
                                  style: TextStyle(
                                    color: bid["status"] ==
                                        "Accepted"
                                        ? Colors.green
                                        : bid["status"] ==
                                        "Declined"
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
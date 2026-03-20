import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TasksAllBids extends StatelessWidget {
  final String taskId;
  final String taskTitle;
  final String createdBy;

  const TasksAllBids({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final user = FirebaseAuth.instance.currentUser;

    final bidsRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("tasks")
        .child(taskId)
        .child("bids");

    final bool isTaskOwner = user?.uid == createdBy;

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

                Text(
                  taskTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: bidsRef.onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(
                            child: Text("No Bids Yet"));
                      }

                      final data = Map<String, dynamic>.from(
                          snapshot.data!.snapshot.value as Map);

                      final bids = data.entries.toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bids.length,
                        itemBuilder: (context, index) {
                          final bidId = bids[index].key;
                          final bid = Map<String, dynamic>.from(
                              bids[index].value);

                          final amount = bid["amount"] ?? 0;
                          final bidderName = bid["userName"] ?? "";
                          final bidderId = bid["userId"] ?? "";
                          final status = bid["status"] ?? "pending";
                          final isBidOwner = user?.uid == bidderId;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "₹$amount",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "User: $bidderName",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                if (isTaskOwner) ...[

                                  if (status == "pending")
                                    Row(
                                      children: [

                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final snapshot =
                                              await bidsRef.get();
                                              final taskRef = FirebaseDatabase.instance
                                                  .ref("codebid_database")
                                                  .child("tasks")
                                                  .child(taskId);

                                              await bidsRef.child(bidId).update({
                                                "status": "accepted"
                                              });

                                              await taskRef.update({
                                                "isClosed": true,
                                              });

                                              for (var child
                                              in snapshot.children) {
                                                if (child.key != bidId) {
                                                  bidsRef
                                                      .child(child.key!)
                                                      .update({
                                                    "status": "declined"
                                                  });
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text("Accept",style: TextStyle(color: Colors.white),),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              bidsRef
                                                  .child(bidId)
                                                  .update({
                                                "status": "declined"
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text("Decline",style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ],
                                    )

                                  else if (status == "accepted")
                                    const Text(
                                      "✅ Accepted",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )

                                  else if (status == "declined")
                                      const Text(
                                        "❌ Declined",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                ],

                                if (!isTaskOwner && isBidOwner)
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: status == "accepted"
                                          ? Colors.green
                                          : status == "declined"
                                          ? Colors.red
                                          : Colors.orange,
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
          ),
        ],
      ),
    );
  }
}
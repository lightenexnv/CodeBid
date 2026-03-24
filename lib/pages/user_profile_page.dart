import 'package:codebid/pages/taskoverviewpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    final userRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("users")
        .child(userId);

    final tasksRef = FirebaseDatabase.instance
        .ref("codebid_database")
        .child("tasks");

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          Container(
            height: height * 0.38,
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
            child: StreamBuilder(
              stream: userRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No Data"));
                }

                final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);

                final name = data["name"] ?? "";
                final bio = data["bio"] ?? "No bio added";
                final image = data["profileImage"] ?? "";

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : const AssetImage(
                            "assets/icons/default-profile.png")
                        as ImageProvider,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF4F6FB),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Bio",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bio,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StreamBuilder(
                              stream: tasksRef.onValue,
                              builder: (context, taskSnap) {
                                if (!taskSnap.hasData ||
                                    taskSnap.data!.snapshot.value ==
                                        null) {
                                  return const Center(
                                      child: Text("No Tasks"));
                                }

                                final tasks =
                                Map<String, dynamic>.from(
                                    taskSnap.data!.snapshot.value
                                    as Map);

                                final userTasks = tasks.entries
                                    .where((e) =>
                                Map<String, dynamic>.from(
                                    e.value)["createdBy"] ==
                                    userId)
                                    .toList();

                                if (userTasks.isEmpty) {
                                  return const Center(
                                      child: Text("No Tasks"));
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  itemCount: userTasks.length,
                                  itemBuilder: (context, index) {
                                    final taskData =
                                    Map<String, dynamic>.from(
                                        userTasks[index].value);

                                    return GestureDetector(
                                      onTap: () {
                                        Get.to(() =>
                                            TaskOverviewPage(
                                                task: taskData));
                                      },
                                      child: Container(
                                        margin:
                                        const EdgeInsets.only(
                                            bottom: 12),
                                        padding:
                                        const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(
                                              18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(
                                                  alpha: 0.05),
                                              blurRadius: 10,
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              taskData["title"] ??
                                                  "",
                                              style:
                                              const TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 6),
                                            Text(
                                              taskData[
                                              "description"] ??
                                                  "",
                                              maxLines: 2,
                                              overflow:
                                              TextOverflow
                                                  .ellipsis,
                                              style:
                                              const TextStyle(
                                                  color:
                                                  Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedyou/service/database.dart';
import 'package:feedyou/service/shared_pref.dart';
import 'package:feedyou/widget/widget_support.dart';
import 'package:flutter/material.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet;
  Stream<QuerySnapshot>? foodStream;
  int total = 0;

  Future<void> loadUserCart() async {
    id = await SharedPreferenceHelper().getUserId();
    wallet = await SharedPreferenceHelper().getUserWallet();
    if (id != null) {
      foodStream = DatabaseMethods().getFoodCart(id!);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Material(
            elevation: 2.0,
            child: Container(
              margin: const EdgeInsets.only(top: 50),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  "Your Cart",
                  style: AppWidget.BoldTextFeildStyle(),
                ),
              ),
            ),
          ),

          // Cart list (scrollable)
          Expanded(
            child: foodStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: foodStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        // No items
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              total = 0;
                            });
                          }
                        });
                        return const Center(
                          child: Text(
                            "🛒 Your cart is empty",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        );
                      }

                      var docs = snapshot.data!.docs;

                      // ✅ Calculate total safely
                      int newTotal = 0;
                      for (var doc in docs) {
                        newTotal += int.parse(doc["Total"].toString());
                      }

                      // Update total only if changed
                      if (newTotal != total) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              total = newTotal;
                            });
                          }
                        });
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          var ds = docs[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Quantity box
                                  Container(
                                    height: 50,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.deepOrangeAccent,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.orange.shade50,
                                    ),
                                    child: Center(
                                      child: Text(
                                        ds["Quantity"].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      ds["Image"],
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  // Item details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ds["name"],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "₹${ds["Total"]}",
                                          style: const TextStyle(
                                            color: Colors.deepOrange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          const Divider(height: 1),

          // Total + Checkout button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: ₹${total.toString()}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    int amount = int.parse(wallet!) - total;

                    if (amount >= 0) {
                      try {
                        // 1️⃣ Wallet update aur cart deletion ko ek sath run karo
                        await Future.wait([
                          DatabaseMethods()
                              .UpdateUserwallet(id!, amount.toString()),
                          SharedPreferenceHelper()
                              .saveUserWallet(amount.toString()),
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(id)
                              .collection('Cart')
                              .get()
                              .then((snapshot) {
                            for (var doc in snapshot.docs) {
                              doc.reference.delete();
                            }
                          }),
                        ]);

                        // 2️⃣ UI update aur SnackBar
                        setState(() {
                          total = 0;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Payment successful & Order placed!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Insufficient balance!"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 12),
                  ),
                  child: const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 16, color: Colors.white),
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

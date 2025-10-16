import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> addUserDetail(
      Map<String, dynamic> userInfoMap, String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  Future<void> UpdateUserwallet(String id, String amount) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  Future addFoodItem(Map<String, dynamic> foodInfo, String name) async {
    await FirebaseFirestore.instance.collection(name).add(foodInfo);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return await FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future addFoodToCart(
      Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection("Cart")
        .add(userInfoMap);
  }
}

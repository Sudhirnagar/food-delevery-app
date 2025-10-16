import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feedyou/pages/details.dart';
import 'package:feedyou/service/database.dart';
import 'package:feedyou/widget/widget_support.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool iceCream = false, pizza = false, salad = false, burger = false;
  Stream? foodItemStream;

  onTheLoad() async {
    foodItemStream = await DatabaseMethods().getFoodItem("Salad");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    onTheLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hello Sudhir', style: AppWidget.BoldTextFeildStyle()),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Delicious Food', style: AppWidget.HeadlineTextFeildStyle()),
              Text('Discover and get great Food',
                  style: AppWidget.LightTextFeildStyle()),
              const SizedBox(height: 20),
              showItem(),
              const SizedBox(height: 25),
              SizedBox(
                height: 270,
                child: allItemsHorizontalally(),
              ),
              const SizedBox(height: 30),
              allItemsVertically(),
            ],
          ),
        ),
      ),
    );
  }

  Widget allItemsHorizontalally() {
    return StreamBuilder(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Details(
                          detail: ds["Detail"],
                          name: ds["name"],
                          image: ds["Image"],
                          price: ds["price"])),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            ds["Image"],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(ds["name"],
                            style: AppWidget.SemiBoldTextFeildStyle()),
                        Text('Fresh and Healthy',
                            style: AppWidget.LightTextFeildStyle()),
                        Text("\u20B9${ds["price"]}",
                            style: AppWidget.SemiBoldTextFeildStyle()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget allItemsVertically() {
    return StreamBuilder(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Details(
                          detail: ds["Detail"],
                          name: ds["name"],
                          image: ds["Image"],
                          price: ds["price"])),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            ds["Image"],
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ds["name"],
                                  style: AppWidget.SemiBoldTextFeildStyle()),
                              Text(ds["Detail"],
                                  style: AppWidget.LightTextFeildStyle()),
                              Text("\u20B9${ds["price"]}",
                                  style: AppWidget.SemiBoldTextFeildStyle()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        categoryItem('assets/images/ice-cream.png', iceCream, () async {
          iceCream = true;
          burger = false;
          salad = false;
          pizza = false;
          foodItemStream = await DatabaseMethods().getFoodItem("Ice-cream");
          setState(() {});
        }),
        categoryItem('assets/images/pizza.png', pizza, () async {
          iceCream = false;
          burger = false;
          salad = false;
          pizza = true;
          foodItemStream = await DatabaseMethods().getFoodItem("Pizza");
          setState(() {});
        }),
        categoryItem('assets/images/burger.png', burger, () async {
          iceCream = false;
          burger = true;
          salad = false;
          pizza = false;
          foodItemStream = await DatabaseMethods().getFoodItem("Burger");
          setState(() {});
        }),
        categoryItem('assets/images/salad.png', salad, () async {
          iceCream = false;
          burger = false;
          salad = true;
          pizza = false;
          foodItemStream = await DatabaseMethods().getFoodItem("Salad");
          setState(() {});
        }),
      ],
    );
  }

  Widget categoryItem(String imagePath, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            imagePath,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

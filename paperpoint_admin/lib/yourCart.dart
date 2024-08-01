import 'dart:math';
import 'package:paperpoint_admin/placeorderItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paperpoint_admin/Constants/Colors/colors.dart';
import 'package:paperpoint_admin/Constants/globals.dart';
import 'package:paperpoint_admin/orderItem.dart';
import 'package:paperpoint_admin/orderOnline.dart';
import 'package:paperpoint_admin/placeOrder.dart';
import 'package:paperpoint_admin/main.dart';



class OrdersListPage extends StatefulWidget {
  final List<OrderItem> orders;

  OrdersListPage({required this.orders});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {

  int _selectedIndex=1;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(width: 150, child: _buildHeader("Your", "Cart")),
                  const SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    'assets/companyLogo.png',
                    width: 200, // Adjust the width as needed
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.orders.length,
                  itemBuilder: (context, index) {
                    return OrderListItem(order: widget.orders[index]);
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _placeOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor, // Set the background color
                    minimumSize:
                    const Size(200, 50), // Set the width and height
                  ),
                  child: const Text(
                    "Place Order",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavigationBarItemTapped,
      ),
    );
  }


  //Widgets

  void _placeOrder() async {
    String companyName = "";
    String phoneNumber = "";
    String email = "";


    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get the user UID
      String userUid = user.uid;

      print(userUid);

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Query for the specific user
    QuerySnapshot querySnapshot = await users.where('userUid', isEqualTo: userUid).get();

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document (assuming there's only one matching user)
      DocumentSnapshot userDocument = querySnapshot.docs.first;

      // Access user details
      companyName = userDocument['companyName'];
      phoneNumber = userDocument['phoneNumber'];
      email = userDocument['email'];

      // // Print or use the user details
      // print('Company Name: $companyName');
      // print('Phone Number: $phoneNumber');
      // print('Email ID: $email');

    } else {
      // print('User not found');
    }




      // Get current date and time
      DateTime now = DateTime.now();
      String orderDate = "${now.day}-${now.month}-${now.year}";
      String orderTime = "${now.hour}:${now.minute}";

      // Loop through the orderList and store each order individually
      for (OrderItem orderItem in widget.orders) {
        // Construct order data
        Map<String, dynamic> orderData = {
          'orderId': userUid,
          'orderDate': orderDate,
          'orderTime': orderTime,
          'paperType': orderItem.paperType,
          'paperSize': orderItem.paperSize,
          'paperGSM': orderItem.paperGSM,
          'quantity': orderItem.quantity,
          'deliverTo': orderItem.deliverTo,
          'companyName':companyName,
          'companyEmail':email,
          'companyPhoneNumber':phoneNumber,
          'dispatchTime':"Not Yet Dispatched",
          'DeliverTime':"Not yet Delivered"


          // 'companyName': 'YourCompanyName', // Replace with actual company name
          // 'phoneNumber': 'YourPhoneNumber', // Replace with actual phone number
        };

        // Store the order data in Firestore
        await FirebaseFirestore.instance.collection('Orders').add(orderData);
      }

      // Clear the orderList after placing the order
      setState(() {
        orderList.clear();
      });

      // Optional: Display a success message or navigate to a success screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );

    }
  }





  Widget _buildHeader(String a, String b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 40,
          ),
        ),
        Text(
          b,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  void _onNavigationBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the selected tab
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderOnline(),
          ),
        );
        break;
      case 1:
      // Cart tab
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrdersListPage(orders: orderList),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const placeorderList(),
          ),
        );
        break;
    }
  }
}

class OrderListItem extends StatefulWidget {
  final OrderItem order;

  OrderListItem({required this.order});

  @override
  State<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends State<OrderListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOrderDetails(),
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(
              style: const TextStyle(color: Colors.black), //apply style to all
              children: [
                const TextSpan(
                    text: 'Paper Type: ', style: TextStyle(fontSize: 16)),
                TextSpan(
                    text: widget.order.paperType,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))
              ])),
          Text.rich(TextSpan(
              style: const TextStyle(color: Colors.black), //apply style to all
              children: [
                const TextSpan(
                    text: 'Paper GSM: ', style: TextStyle(fontSize: 16)),
                TextSpan(
                    text: widget.order.paperGSM,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))
              ])),
          Text.rich(TextSpan(
              style: const TextStyle(color: Colors.black), //apply style to all
              children: [
                const TextSpan(
                    text: 'Paper Size: ', style: TextStyle(fontSize: 16)),
                TextSpan(
                    text: widget.order.paperSize,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))
              ])),
          Text.rich(TextSpan(
              style: const TextStyle(color: Colors.black), //apply style to all
              children: [
                const TextSpan(
                    text: 'Quantity: ', style: TextStyle(fontSize: 16)),
                TextSpan(
                    text: widget.order.quantity,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))
              ])),
          Text.rich(TextSpan(
              style: const TextStyle(color: Colors.black), //apply style to all
              children: [
                const TextSpan(
                    text: 'Deliver To: ', style: TextStyle(fontSize: 16)),
                TextSpan(
                    text: widget.order.deliverTo,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))
              ])),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          // Show a confirmation dialog before deleting
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Delete"),
                content: const Text("Are you sure you want to delete this item?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      // Delete the item from the list
                      // You can use the 'order' object to identify the item
                      // and update the UI accordingly.
                      // For example:
                      orderList.remove(widget.order);
                      // Update the UI by calling setState
                      // to trigger a rebuild of the widget tree.

                      // Close the dialog
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrdersListPage(orders: orderList),
                        ),
                      );
                    },
                    child: const Text("Delete"),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paperpoint_admin/Constants/Colors/colors.dart';
import 'package:paperpoint_admin/orderItem.dart';
import 'package:paperpoint_admin/Constants/globals.dart';
import 'package:paperpoint_admin/placeOrder.dart';
import 'package:paperpoint_admin/yourCart.dart';

import 'cancelledOrders.dart';
import 'completedOrders.dart';

class OrderOnline extends StatefulWidget {
  const OrderOnline({Key? key}) : super(key: key);

  @override
  State<OrderOnline> createState() => _OrderOnlineState();
}

class _OrderOnlineState extends State<OrderOnline> {
  final TextEditingController paperType = TextEditingController();
  final TextEditingController paperGSM = TextEditingController();
  final TextEditingController paperSize = TextEditingController();
  final TextEditingController quantity = TextEditingController();
  final TextEditingController deliverTo = TextEditingController();

  // int _selectedIndex=3;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when the back button is pressed
          },
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth*0.05,screenheight*0.08 ,screenWidth*0.05 , 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(
                        width: screenWidth*0.375, child: _buildHeader("Add", "Items")),
                    // Image.asset(
                    //   'assets/companyLogo.png',
                    //   width: screenWidth*0.5, // Adjust the width as needed
                    // ),
                    Lottie.asset('assets/addItem.json',width: screenWidth*0.5,repeat: true),
                  ],
                ),
                SizedBox(
                  height: screenWidth*0.0375,
                ),
                Row(
                  children: [
                    _buildLabel("Paper Type"),
                    SizedBox(width: screenWidth*0.1),
                    _buildTextField(paperType, "Eg: Gumming sheet"),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addItemToFirestore("paperType", paperType.text),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _showItemList("paperType"),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenheight*0.008,
                ),
                Row(
                  children: [
                    _buildLabel("Paper GSM"),
                    SizedBox(width: screenWidth*0.1),
                    _buildTextField(paperGSM, "Eg : 300 GSM"),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addItemToFirestore("paperGSM", paperGSM.text),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _showItemList("paperGSM"),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenheight*0.008,
                ),
                Row(
                  children: [
                    _buildLabel("Paper Size"),
                    SizedBox(width: screenWidth*0.1),
                    _buildTextField(paperSize, 'Eg : 25" X 36"'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addItemToFirestore("paperSize", paperSize.text),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _showItemList("paperSize"),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: 5,
                // ),
                // Row(
                //   children: [
                //     _buildLabel("Quantity"),
                //     const SizedBox(width: 40),
                //     _buildTextField(quantity, "Eg : 50000"),
                //     IconButton(
                //       icon: const Icon(Icons.add),
                //       onPressed: () => _addItemToFirestore("Quantity", paperType.text),
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.arrow_downward),
                //       onPressed: () => _showItemList("Quantity"),
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: screenheight*0.008,
                ),
                // Row(
                //   children: [
                //     _buildLabel("Deliver To"),
                //     const SizedBox(width: 40),
                //     _buildTextField(deliverTo, "Firm name,Address"),
                //   ],
                // ),
                // const SizedBox(
                //   height: 25,
                // ),
                // Center(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       _addOrderItem();
                //     },
                //     style: ElevatedButton.styleFrom(
                //       primary: buttonColor, // Set the background color
                //       minimumSize:
                //           const Size(200, 50), // Set the width and height
                //     ),
                //     child: const Text(
                //       "Add to Cart",
                //       style: TextStyle(
                //           fontSize: 22,
                //           fontWeight: FontWeight.w500,
                //           color: Colors.white),
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 20,
                // ),
              ],
            ),
          ),
        ),
      ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.shopping_cart_outlined),
        //       label: 'Pending Orders',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.remove_shopping_cart_outlined),
        //       label: 'Cancelled Orders',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.shopping_cart),
        //       label: 'Completed Orders',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.add),
        //       label: 'Add Items',
        //     )
        //   ],
        //   currentIndex: _selectedIndex,
        //   onTap: _onNavigationBarItemTapped,
        // )
    );
  }

  //WIDGETS

  Widget _buildLabel(String label) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth*0.35,
      child: Text(
        label,
        style: TextStyle(
          fontSize: screenWidth*0.054,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(60),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String a, String b) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a,
          style: TextStyle(
            color: Colors.black,
              fontSize: screenWidth*0.09
          ),
        ),
        Text(
          b,
          style:  TextStyle(
            color: Colors.black,
            fontSize: screenWidth*0.108,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _addOrderItem() {
    OrderItem orderItem = OrderItem(
      paperType: paperType.text,
      paperGSM: paperGSM.text,
      paperSize: paperSize.text,
      quantity: quantity.text,
      deliverTo: deliverTo.text,
    );

    setState(() {
      orderList.add(orderItem);
    });

    // Clear the text fields after adding to the order list
    paperType.clear();
    paperGSM.clear();
    paperSize.clear();
    quantity.clear();
    deliverTo.clear();
  }

  Widget _buildOrderList() {
    if (orderList.isEmpty) {
      return const Text("Order list is empty");
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order List:",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (var orderItem in orderList)
            Text(
              "• ${orderItem.paperType}, ${orderItem.paperGSM}, ${orderItem.paperSize}, ${orderItem.quantity}, ${orderItem.deliverTo}",
              style: const TextStyle(fontSize: 16),
            ),
        ],
      );
    }
  }
  // void _onNavigationBarItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //
  //   // Navigate to the selected tab
  //   switch (index) {
  //     case 0:
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const placeorderList(),
  //         ),
  //       );
  //       break;
  //     case 1:
  //     // Cart tab
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const placeorderListcancelled(),
  //         ),
  //       );
  //       break;
  //     case 2:
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const placeorderListcompleted(),
  //         ),
  //       );
  //       break;
  //     case 3:
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const OrderOnline(),
  //         ),
  //       );
  //       break;
  //   }
  // }
  void _addItemToFirestore(String field, String value) {
    // Check if the value is empty
    if (value.isEmpty) {
      // Show a Snackbar indicating that the field cannot be empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The field cannot be empty'),
        ),
      );
      return; // Exit the method
    }

    // Add the item to Firestore
    CollectionReference itemsCollection = FirebaseFirestore.instance.collection(field);

    itemsCollection.add({
      'value': value,
    }).then((value) {
      print('Item added to $field collection with ID: ${value.id}');
    }).catchError((error) {
      print('Failed to add item to $field collection: $error');
    });

    // Clear text fields
    paperType.clear();
    paperSize.clear();
    paperGSM.clear();
  }


  void _showItemList(String field) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$field Items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Show circular progress indicator while loading
              SizedBox(height: 16), // Add some spacing
              Text("Loading..."), // Optional: Display loading text
            ],
          ),
        );
      },
    );
    // Retrieve items from Firestore and show them in a dialog
    CollectionReference itemsCollection = FirebaseFirestore.instance.collection(field);

    itemsCollection.get().then((QuerySnapshot querySnapshot) {
      Navigator.of(context).pop();
      List<String> items = querySnapshot.docs.map((doc) => doc['value'].toString()).toList();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('$field Items'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  for (var item in items)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteItem(field, item);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      print('Failed to retrieve items from $field collection: $error');
    });
  }

  void _deleteItem(String field, String value) {
    // Delete the item from Firestore
    CollectionReference itemsCollection = FirebaseFirestore.instance.collection(field);

    itemsCollection.where('value', isEqualTo: value).get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
        print('Item deleted from $field collection: ${doc['value']}');
      });
    }).catchError((error) {
      print('Failed to delete item from $field collection: $error');
    });
  }

}

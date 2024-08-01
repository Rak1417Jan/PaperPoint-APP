import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:paperpoint_admin/Constants/Colors/colors.dart';
import 'package:paperpoint_admin/Constants/globals.dart';
import 'package:paperpoint_admin/cancelledOrders.dart';
import 'package:paperpoint_admin/completedOrders.dart';
import 'package:paperpoint_admin/orderOnline.dart';
import 'package:paperpoint_admin/yourCart.dart';
import 'package:paperpoint_admin/placeorderItem.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';


class placeorderList extends StatefulWidget {
  const placeorderList({Key? key}) : super(key: key);

  @override
  State<placeorderList> createState() => _placeorderListState();
}

class _placeorderListState extends State<placeorderList> {
  int _selectedIndex=0;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer
    _checkUndeliveredOrdersPeriodically(); // Start checking orders periodically
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose of the AudioPlayer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth*0.05,screenheight*0.08,screenWidth*0.05 , screenWidth*0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(
                      width: screenWidth*0.375, child: _buildHeader("Pending", "Orders")),
                  Column(
                    children: [
                      // Image.asset(
                      //   'assets/companyLogo.png',
                      //   width: screenWidth*0.5, // Adjust the width as needed
                      // ),
                      Lottie.asset('assets/pendingOrders.json',width: screenWidth*0.5,repeat: true),
                      SizedBox(height: screenheight*0.0032),
                      Text("Admin",style: TextStyle(fontSize: screenWidth*0.054,color: Colors.grey),)
                    ],
                  ),

                ],
              ),
              SizedBox(
                height: screenheight*0.008,
              ),
              FutureBuilder(
                future: getOrdersForUser(),
                builder: (context, AsyncSnapshot<List<PlaceOrderItem>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<PlaceOrderItem> orders = snapshot.data ?? [];
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          return PlaceOrderListItem(order: orders[index]);
                        },
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: screenheight*0.024,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const placeorderList(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: buttonColor, // Set the background color
                    minimumSize:
                    Size(screenWidth*0.5, screenheight*0.08), // Set the width and height
                  ),
                  child: Text(
                    "Refresh",
                    style: TextStyle(
                        fontSize: screenWidth*0.0495,
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
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Pending Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_shopping_cart_outlined),
            label: 'Cancelled Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Completed Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavigationBarItemTapped,
      ),
    );
  }

  Future<List<PlaceOrderItem>> getOrdersForUser() async {
      CollectionReference orders = FirebaseFirestore.instance.collection(
          'Orders');

      // Query for orders with a specific userUid
      QuerySnapshot querySnapshot = await orders.where('dispatchTime', isEqualTo: 'Not Yet Dispatched')
          .where('DeliverTime', isEqualTo: 'Not Yet Delivered').orderBy('orderDate')
          .get();

      // Process the querySnapshot to create a list of OrderItem objects
      List<PlaceOrderItem> placeorderList = querySnapshot.docs.map((
          DocumentSnapshot doc) {
        // Access the fields of the document
        String orderId = doc.id;
        String orderDate = doc['orderDate'];
        String orderTime = doc['orderTime'];
        String paperType = doc['paperType'];
        String paperSize = doc['paperSize'];
        String paperGSM = doc['paperGSM'];
        String quantity = doc['quantity'];
        String deliverTo = doc['deliverTo'];
        String companyName = doc['companyName'];
        String phoneNumber = doc['companyPhoneNumber'];
        String dispatchTime = doc['dispatchTime'];
        String deliverTime = doc['DeliverTime'];

        // Create an OrderItem object
        PlaceOrderItem orderItem = PlaceOrderItem(
            orderId: orderId,
            orderDate: orderDate,
            orderTime: orderTime,
            paperType: paperType,
            paperSize: paperSize,
            paperGSM: paperGSM,
            quantity: quantity,
            deliverTo: deliverTo,
            companyName: companyName,
            phoneNumber: phoneNumber,
            dispatchTime: dispatchTime,
            deliverTime: deliverTime
        );

        return orderItem;
      }).toList();

      return placeorderList;

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
            builder: (context) => const placeorderList(),
          ),
        );
        break;
      case 1:
      // Cart tab
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const placeorderListcancelled(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const placeorderListcompleted(),
          ),
        );
        break;
    }
  }
  void _checkUndeliveredOrdersPeriodically() {
    const Duration checkInterval = Duration(seconds: 20);

    // Schedule a periodic task to check undelivered orders
    Timer.periodic(checkInterval, (timer) {
      _checkUndeliveredOrders();
    });
  }
  void _checkUndeliveredOrders() async {
    // Get all orders from Firestore
    List<PlaceOrderItem> allOrders = await getOrdersForUser();

    // Iterate through all orders
    for (PlaceOrderItem order in allOrders) {
      // Check if the order has 'Not Yet Dispatched' status
      if (order.dispatchTime == 'Not Yet Dispatched') {
        // Trigger the audio notification here
        FlutterRingtonePlayer.play(
          android: AndroidSounds.notification,
          ios: IosSounds.glass,
          looping: false, // Android only - API >= 28
          volume: 1, // Android only - API >= 28
          asAlarm: false, // Android only - all APIs
        );
        break; // Break the loop if you only want to notify once
      }
    }
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
            fontSize: screenWidth*0.075,
          ),
        ),
        Text(
          b,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth*0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

}

class PlaceOrderListItem extends StatefulWidget {
  final PlaceOrderItem order;

  PlaceOrderListItem({required this.order});

  @override
  State<PlaceOrderListItem> createState() => _PlaceOrderListItemState();
}

class _PlaceOrderListItemState extends State<PlaceOrderListItem> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Card(
      margin: EdgeInsets.all(screenWidth*0.02),
      child: Padding(
        padding: EdgeInsets.all(screenWidth*0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildOrderDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth*0.75,
      child: Row(
        children: [
          SizedBox(
            width: screenWidth*0.4375,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Paper Type: ', style: TextStyle(fontSize: screenWidth*0.036)),
                      TextSpan(
                          text: widget.order.paperType,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),
                Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Paper GSM: ', style: TextStyle(fontSize: screenWidth*0.036)),
                      TextSpan(
                          text: widget.order.paperGSM,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),
                Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Paper Size: ', style: TextStyle(fontSize: screenWidth*0.036)),
                      TextSpan(
                          text: widget.order.paperSize,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),
                Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Quantity: ', style: TextStyle(fontSize: screenWidth*0.036)),
                      TextSpan(
                          text: widget.order.quantity,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),
                Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Deliver To: ', style: TextStyle(fontSize: screenWidth*0.036)),
                      TextSpan(
                          text: widget.order.deliverTo,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),
                Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Company Name: ', style: TextStyle(fontSize: screenWidth*0.036,color: Colors.cyan)),
                      TextSpan(
                          text: widget.order.companyName,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.black), //apply style to all
                    children: [
                      TextSpan(
                          text: 'Phone Number: ', style: TextStyle(fontSize: screenWidth*0.036, color: Colors.cyan)),
                      TextSpan(
                          text: widget.order.phoneNumber,
                          style: TextStyle(
                              fontSize: screenWidth*0.036, fontWeight: FontWeight.w700))
                    ])),
              ],
            ),
          ),
          SizedBox(
            width: screenWidth*0.025,
          ),
          SizedBox(
            width: screenWidth*0.2875,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text("Order Date: ",style: TextStyle(fontSize: screenWidth*0.036,color: Colors.black),)),
                  Center(child: Text(widget.order.orderDate,style: TextStyle(fontSize: screenWidth*0.036,color: Colors.black,fontWeight: FontWeight.w700),)),
                  Center(child: Text("Order Time: ",style: TextStyle(fontSize: screenWidth*0.036,color: Colors.black),)),
                  Center(child: Text(widget.order.orderTime,style: TextStyle(fontSize: screenWidth*0.036,color: Colors.black,fontWeight: FontWeight.w700),)),
                  Center(child: Text("Dispatch Time: ",style: TextStyle(fontSize: screenWidth*0.036,color: Colors.black),)),
                  Center(child: Text(widget.order.dispatchTime,style: TextStyle(fontSize: screenWidth*0.036,color: Colors.red,fontWeight: FontWeight.w700),textAlign: TextAlign.center,)),
                  Center(child: Text("Deliver Time: ",style: TextStyle(fontSize: screenWidth*0.036,color: Colors.black),)),
                  Center(child: Text(widget.order.deliverTime,style: TextStyle(fontSize: screenWidth*0.036,color: Colors.red,fontWeight: FontWeight.w700),textAlign: TextAlign.center,)),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _showActionDialog(widget.order);
                      },
                      child: const Text('Actions'),
                    ),
                  ),

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
  void _showActionDialog(PlaceOrderItem order) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Actions'),
          content: Column(
            children: [
              _buildSwitch('Dispatch Order', order, 'Dispatch Order'),
              _buildSwitch('Deliver Order', order, 'Deliver Order'),
              _buildSwitch('Paper type not available', order, 'Paper type not available'),
              _buildSwitch('Paper Size not available', order, 'Paper Size not available'),
              _buildSwitch('Paper GSM not available', order, 'Paper GSM not available'),
              _buildSwitch('Quantity not available', order, 'Quantity not available'),
              _buildSwitch('Cancel Order', order, 'Cancelled'),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const placeorderList(),
                    ),
                  );// Close the dialog
                },
                child: const Text('Go back'),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitch(String title, PlaceOrderItem order, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            _handleAction(order, action);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const placeorderList(),
              ),
            );
          },
          child: Text(title),
        ),
      ],
    );
  }

  void _handleAction(PlaceOrderItem order, String action) {
    switch (action) {
      case 'Dispatch Order':
      // Set dispatch time with current date and time
        DateTime now = DateTime.now();
        String dispatchDate = "${now.day}-${now.month}-${now.year}";
        String dispatchTime = "${now.hour}:${now.minute}";
        _updateOrderTime(order, 'at $dispatchTime on $dispatchDate',action);
        break;
      case 'Deliver Order':
      // Set deliver time with current date and time
        DateTime now = DateTime.now();
        String deliverDate = "${now.day}-${now.month}-${now.year}";
        String deliverTime = "${now.hour}:${now.minute}";
        _updateOrderTime(order, 'at $deliverTime on $deliverDate',action);
        break;
      case 'Paper type not available':
      // Set both dispatch and deliver times with not available message
        _updateOrderTime(order, 'Paper type not available',action);
        break;
      case 'Paper Size not available':
      // Set both dispatch and deliver times with order cancelled message
        _updateOrderTime(order, 'Paper Size not available',action);
        break;

      case 'Paper GSM not available':
      // Set both dispatch and deliver times with order cancelled message
        _updateOrderTime(order, 'Paper GSM not available',action);
        break;

      case 'Quantity not available':
      // Set both dispatch and deliver times with order cancelled message
        _updateOrderTime(order, 'Quantity not available',action);
        break;
      case 'Cancelled':
      // Set both dispatch and deliver times with order cancelled message
        _updateOrderTime(order, 'Order Cancelled',action);
        break;
    }
  }

  void _updateOrderTime(PlaceOrderItem order, String message, String action) {
    // Get a reference to the order document
    DocumentReference orderRef =
    FirebaseFirestore.instance.collection('Orders').doc(order.orderId);

    // Update either "dispatchTime" or "DeliverTime" based on the action
    if (action == 'Dispatch Order') {
      orderRef.update({
        'dispatchTime': message,
      }).then((value) {
        print('Dispatch time updated successfully');
      }).catchError((error) {
        print('Failed to update dispatch time: $error');
      });
    } else if (action == 'Deliver Order') {
      orderRef.update({
        'DeliverTime': message,
      }).then((value) {
        print('Deliver time updated successfully');
      }).catchError((error) {
        print('Failed to update deliver time: $error');
      });
    } else {
      // For other actions, update both "dispatchTime" and "DeliverTime"
      orderRef.update({
        'dispatchTime': message,
        'DeliverTime': message,
      }).then((value) {
        print('Order time updated successfully');
      }).catchError((error) {
        print('Failed to update order time: $error');
      });
    }
  }


}





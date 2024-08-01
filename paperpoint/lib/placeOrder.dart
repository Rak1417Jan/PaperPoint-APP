import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:paperpoint/Constants/Colors/colors.dart';
import 'package:paperpoint/Constants/globals.dart';
import 'package:paperpoint/orderOnline.dart';
import 'package:paperpoint/yourCart.dart';
import 'package:paperpoint/placeorderItem.dart';

class placeorderList extends StatefulWidget {
  const placeorderList({Key? key}) : super(key: key);

  @override
  State<placeorderList> createState() => _placeorderListState();
}

class _placeorderListState extends State<placeorderList> {
  int _selectedIndex = 2;

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
          padding: EdgeInsets.fromLTRB(screenWidth*0.05,0,screenWidth*0.05 , screenWidth*0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  SizedBox(
                      width: screenWidth*0.340, child: _buildHeader("Your", "Orders")),
                  // Image.asset(
                  //   'assets/companyLogo.png',
                  //   width: screenWidth*0.5, // Adjust the width as needed
                  // ),
                  Lottie.asset('assets/yourOrders.json',width: screenWidth * 0.550,repeat: true),
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

  Future<List<PlaceOrderItem>> getOrdersForUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Get the user UID
      String userUid = user.uid;


      CollectionReference orders = FirebaseFirestore.instance.collection(
          'Orders');

      // Query for orders with a specific userUid
      QuerySnapshot querySnapshot = await orders.where(
          'orderId', isEqualTo: userUid).orderBy('orderDate').get();

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
    else
    {
      return [];
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
            fontSize: screenWidth*0.09,
          ),
        ),
        Text(
          b,
          style: TextStyle(
            color: Colors.black,
            fontSize: screenWidth*0.108,
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

                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}



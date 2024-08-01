import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paperpoint/Constants/Colors/colors.dart';
import 'package:paperpoint/main.dart';
import 'package:paperpoint/orderItem.dart';
import 'package:paperpoint/Constants/globals.dart';
import 'package:paperpoint/placeOrder.dart';
import 'package:paperpoint/yourCart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authorisation/logininPage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  final TextEditingController deliverToSuggestions = TextEditingController();


  int _selectedIndex=0;
  List<String> addressList = [];
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    // Load addresses from SharedPreferences when the widget initializes
    _loadAddresses();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(screenWidth*0.05,0 ,screenWidth*0.05 , 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    SizedBox(
                        width: screenWidth*0.325, child: _buildHeader("Order", "Online")),
                    // Image.asset(
                    //   'assets/companyLogo.png',
                    //   width: screenWidth*0.5, // Adjust the width as needed
                    // ),
                    Lottie.asset('assets/orderOnline.json',width: screenWidth * 0.575,repeat: true),
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
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _showItemList("paperType",paperType),
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
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _showItemList("paperGSM",paperGSM),
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
                      icon: const Icon(Icons.arrow_downward),
                      onPressed: () => _showItemList("paperSize",paperSize),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenheight*0.008,
                ),
                Row(
                  children: [
                    _buildLabel("Quantity"),
                    SizedBox(width: screenWidth*0.1),
                    _buildTextField(quantity, "Eg : 50000"),
                  ],
                ),
                SizedBox(
                  height: screenheight*0.008,
                ),
                Row(
                  children: [
                    _buildLabel("Deliver To"),
                    SizedBox(width: screenWidth*0.1),
                    // _buildTextField(deliverTo, "Firm name,Address"),
                    Container(
                        width: screenWidth*0.45,
                        child: _buildTextFieldAddress(deliverTo, "Firm name,Address", deliverToSuggestions)),
                  ],
                ),
                SizedBox(
                  height: screenheight*0.04,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _addOrderItem();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: buttonColor, // Set the background color
                      minimumSize:
                          Size(screenWidth*0.5, screenheight*0.08), // Set the width and height
                    ),
                    child: Text(
                      "Add to Cart",
                      style: TextStyle(
                          fontSize: screenWidth*0.0495,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenheight*0.032,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _signOut();
        },
        child: const Icon(Icons.logout),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Widget _buildTextFieldAddress(
      TextEditingController controller,
      String hintText,
      TextEditingController suggestionsController,
      ) {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
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
      suggestionsCallback: (pattern) async {
        // You can fetch suggestions from your local storage or any other source.
        return addressList;
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        // Set the value of the selected suggestion in the respective TextEditingController
        controller.text = suggestion;

        // Optionally, you can clear the suggestions text field after selecting a suggestion
        suggestionsController.clear();
      },
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
          style: TextStyle(
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

    _saveAddress(deliverTo.text);


    // Clear the text fields after adding to the order list
    paperType.clear();
    paperGSM.clear();
    paperSize.clear();
    quantity.clear();
    deliverTo.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart successfully!')),
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

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _showItemList(String field, TextEditingController controller) {
    // Show loading indicator
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

    // Retrieve items from Firestore
    CollectionReference itemsCollection = FirebaseFirestore.instance.collection(field);
    itemsCollection.get().then((QuerySnapshot querySnapshot) {
      // Close the loading dialog
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
                    ElevatedButton(
                      onPressed: () {
                        // Set the value of the selected item in the respective TextEditingController
                        controller.text = item;
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item),
                        ],
                      ),
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
      // Close the loading dialog
      Navigator.of(context).pop();

      print('Failed to retrieve items from $field collection: $error');
    });
  }

  // void _showItemList(String field, TextEditingController controller) {
  //   // Retrieve items from Firestore and show them in a dialog
  //   CollectionReference itemsCollection = FirebaseFirestore.instance.collection(field);
  //
  //   itemsCollection.get().then((QuerySnapshot querySnapshot) {
  //     List<String> items = querySnapshot.docs.map((doc) => doc['value'].toString()).toList();
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('$field Items'),
  //           content: SingleChildScrollView(
  //             child: Column(
  //               children: [
  //                 for (var item in items)
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       // Set the value of the selected item in the respective TextEditingController
  //                       controller.text = item;
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         Text(item),
  //                       ],
  //                     ),
  //                   ),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //               child: const Text('Close'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }).catchError((error) {
  //     print('Failed to retrieve items from $field collection: $error');
  //   });
  // }
  // Save address to SharedPreferences
  Future<void> _saveAddress(String newAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    addressList.add(newAddress);
    await prefs.setStringList('addressList', addressList);
  }

  // Load addresses from SharedPreferences
  Future<void> _loadAddresses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAddresses = prefs.getStringList('addressList');
    if (savedAddresses != null) {
      setState(() {
        addressList = savedAddresses;
      });
    }
  }
}

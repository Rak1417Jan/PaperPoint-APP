

class OrderItem {
  String paperType;
  String paperGSM;
  String paperSize;
  String quantity;
  String deliverTo;

  OrderItem({
    required this.paperType,
    required this.paperGSM,
    required this.paperSize,
    required this.quantity,
    required this.deliverTo,
  });


  Map<String, dynamic> toJson() {
    return {
      'paperType': paperType,
      'paperGSM': paperGSM,
      'paperSize': paperSize,
      'quantity': quantity,
      'deliverTo': deliverTo,
    };
  }
}



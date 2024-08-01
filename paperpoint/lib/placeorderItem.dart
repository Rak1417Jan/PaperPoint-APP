

class PlaceOrderItem {
  String paperType;
  String paperGSM;
  String paperSize;
  String quantity;
  String deliverTo;
  String orderId;
  String orderDate;
  String orderTime;
  String companyName;
  String phoneNumber;
  String dispatchTime;
  String deliverTime;

  PlaceOrderItem({
    required this.paperType,
    required this.paperGSM,
    required this.paperSize,
    required this.quantity,
    required this.deliverTo,
    required this.orderId,
    required this.orderDate,
    required this.orderTime,
    required this.phoneNumber,
    required this.companyName,
    required this.dispatchTime,
    required this.deliverTime
  });

}

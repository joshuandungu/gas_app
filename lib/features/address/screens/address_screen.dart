import 'package:ecommerce_app_fluterr_nodejs/common/widgets/custom_textfield.dart';
import 'package:ecommerce_app_fluterr_nodejs/common/widgets/payments_details_dialog.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/global_variables.dart';
import 'package:ecommerce_app_fluterr_nodejs/constants/utils.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/address/widgets/mpesa_phone_dialog.dart';
import 'package:ecommerce_app_fluterr_nodejs/features/address/services/address_services.dart';
import 'package:ecommerce_app_fluterr_nodejs/models/product.dart';
import 'package:ecommerce_app_fluterr_nodejs/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;
  final List<Product>? products;
  final List<int>? selectedItems;
  final List<int>? quantities;
  const AddressScreen({
    super.key,
    required this.totalAmount,
    this.products,
    this.quantities,
    this.selectedItems,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();
  String addressToBeUsed = "";
  bool isLoading = false;

  final Future<PaymentConfiguration> _googlePayConfigFuture =
      PaymentConfiguration.fromAsset('gpay.json');

  List<PaymentItem> paymentItems = [];
  final AddressServices addressServices = AddressServices();
  Widget? googlePayButton;
  late final Form addressForm;

  @override
  void initState() {
    super.initState();
    paymentItems.add(
      PaymentItem(
        amount: widget.totalAmount,
        label: "Total Amount",
        status: PaymentItemStatus.final_price,
      ),
    );

    // Pre-build the Form widget
    addressForm = Form(
      key: _addressFormKey,
      child: Column(
        children: [
          CustomTextField(
            textController: flatBuildingController,
            hintText: 'Flat, House no, Building',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            textController: areaController,
            hintText: 'Area, Street',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            textController: pincodeController,
            hintText: 'District',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            textController: cityController,
            hintText: 'Town/City',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            textController: phoneNumberController,
            hintText: 'Phone Number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    // Pre-build the GooglePayButton
    _googlePayConfigFuture.then((config) {
      if (mounted) {
        setState(() {
          googlePayButton = GooglePayButton(
            onPressed: () => payPressed(
                Provider.of<UserProvider>(context, listen: false).user.address,
                'GooglePay'),
            paymentConfiguration: config,
            paymentItems: paymentItems,
            type: GooglePayButtonType.buy,
            onPaymentResult: onGooglePayResult,
            height: 75,
            width: double.infinity,
            theme: GooglePayButtonTheme.dark,
            loadingIndicator: const Center(child: CircularProgressIndicator()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    phoneNumberController.dispose();
  }

  double calculateShippingFee(String userAddress, String sellerAddress) {
    // Extract city/town from addresses
    final userCity = userAddress.split(',').last.trim().toLowerCase();
    final sellerCity = sellerAddress.split(',').last.trim().toLowerCase();

    return userCity == sellerCity ? 5.0 : 10.0;
  }

  void processCodPayment(String address, double shippingFee) {
    if (widget.products != null) {
      // Buy Now case
      addressServices.placeDirectOrder(
        context: context,
        address: address,
        totalSum: double.parse(widget.totalAmount) + shippingFee,
        products: widget.products!,
        quantities: widget.quantities!,
        phoneNumber: phoneNumberController.text,
      );
    } else {
      // Cart case
      addressServices.placeOrder(
        context: context,
        address: address,
        totalSum: double.parse(widget.totalAmount) + shippingFee,
        selectedItems: widget.selectedItems!,
        phoneNumber: phoneNumberController.text,
      );
    }
  }

  void handleMpesaPayment(String address, double shippingFee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MpesaPhoneDialog(
        onConfirm: (phoneNumber) {
          Navigator.of(context).pop(); // Close the phone dialog
          // First, place the order to get an orderId
          // Then, initiate payment
          if (widget.products != null) {
            // Buy Now case
            addressServices.placeDirectOrder(
              context: context,
              address: address,
              totalSum: double.parse(widget.totalAmount) + shippingFee,
              products: widget.products!,
              quantities: widget.quantities!,
              paymentMethod: 'M-Pesa',
              phoneNumber: phoneNumberController.text,
              onSuccess: (order) {
                addressServices.initiateMpesaPayment(
                    context: context,
                    orderId: order.id,
                    phoneNumber: phoneNumber,
                    amount: order.totalPrice);
              },
            );
          } else {
            // Cart case
            addressServices.placeOrder(
              context: context,
              address: address,
              totalSum: double.parse(widget.totalAmount) + shippingFee,
              selectedItems: widget.selectedItems!,
              paymentMethod: 'M-Pesa',
              phoneNumber: phoneNumberController.text,
              onSuccess: (order) {
                addressServices.initiateMpesaPayment(
                    context: context,
                    orderId: order.id,
                    phoneNumber: phoneNumber,
                    amount: order.totalPrice);
              },
            );
          }
        },
      ),
    );
  }

  void _placeOrder(String address) {
    // This method consolidates the order placement logic for Google Pay.
    // It determines whether it's a "Buy Now" or "Cart" order.
    if (widget.products != null) {
      // Buy Now case
      addressServices.placeDirectOrder(
        context: context,
        address: address,
        totalSum: double.parse(widget.totalAmount),
        products: widget.products!,
        quantities: widget.quantities!,
        phoneNumber: phoneNumberController.text,
        paymentMethod: 'GooglePay',
      );
    } else {
      // Cart case
      addressServices.placeOrder(
        context: context,
        address: address,
        totalSum: double.parse(widget.totalAmount),
        selectedItems: widget.selectedItems!,
        phoneNumber: phoneNumberController.text,
        paymentMethod: 'GooglePay',
      );
    }
  }

  void onGooglePayResult(res) {
    if (Provider.of<UserProvider>(context, listen: false)
        .user
        .address
        .isEmpty) {
      addressServices.saveUserAddress(
          context: context,
          address: addressToBeUsed,
          phoneNumber: phoneNumberController.text);
    }
    _placeOrder(addressToBeUsed);
  }

  void payPressed(String addressFromProvider, String paymentMethod) async {
    addressToBeUsed = "";
    bool isForm = flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isForm) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, District ${pincodeController.text}, ${cityController.text}';
      } else {
        showSnackBar(context, "Please enter all values in the address form!");
        return;
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    } else {
      showSnackBar(context, "Please enter address!");
      return;
    }

    // Save address if it's new and the user doesn't have one saved
    if (isForm &&
        Provider.of<UserProvider>(context, listen: false)
            .user
            .address
            .isEmpty) {
      addressServices.saveUserAddress(
          context: context,
          address: addressToBeUsed,
          phoneNumber: phoneNumberController.text);
    }
    if (addressToBeUsed.isNotEmpty) {
      // The GooglePayButton handles its own logic, so we don't show a dialog for it.
      if (paymentMethod == 'GooglePay') {
        // Note: Google Pay flow currently doesn't include shipping fees.
        // This would require a more significant refactor.
        return;
      }

      double shippingFee = 0;
      if (widget.products != null) {
        final sellerAddress = await addressServices.getSellerAddress(
            context: context, sellerId: widget.products![0].sellerId);
        shippingFee = calculateShippingFee(addressToBeUsed, sellerAddress);
      } else {
        final sellerAddresses =
            await addressServices.getSellerAddresses(context);
        for (var sellerAddress in sellerAddresses) {
          shippingFee += calculateShippingFee(addressToBeUsed, sellerAddress);
        }
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => PaymentDetailsDialog(
            originalAmount: double.parse(widget.totalAmount),
            shippingFee: shippingFee,
            onConfirm: () {
              Navigator.of(context).pop(); // Close the details dialog
              if (paymentMethod == 'M-Pesa') {
                handleMpesaPayment(addressToBeUsed, shippingFee);
              } else {
                processCodPayment(addressToBeUsed, shippingFee);
              }
            }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var address = context.watch<UserProvider>().user.address;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (address.isNotEmpty)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              addressForm,
              Container(
                width: double.infinity,
                height: 48,
                margin: const EdgeInsets.only(top: 15.0),
                child: ElevatedButton(
                  onPressed: () => payPressed(address, 'COD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlobalVariables.primaryColor,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Cash On Delivery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 48,
                margin: const EdgeInsets.only(top: 15.0),
                child: ElevatedButton(
                  onPressed: () => payPressed(address, 'M-Pesa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // M-Pesa color
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Pay with M-Pesa',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (googlePayButton != null) googlePayButton!,
            ],
          ),
        ),
      ),
    );
  }
}

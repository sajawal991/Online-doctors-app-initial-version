import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../Module/Doctor/Provider/DoctorProvider.dart';
import '../../../../utilities/color.dart';

Widget MessageCardCustomOffer(context, widget, timestamp){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Custom Offer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),),
        SizedBox(height: 2,),
        // Text('DescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescriptionDescription',
        //   maxLines: 2,
        //   overflow: TextOverflow.ellipsis,
        //   style: TextStyle(
        //     // fontWeight: FontWeight.bold,
        //       fontSize: 14,
        //       color: Colors.grey.shade500
        //   ),),
        // SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Total Amount: ',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
            Spacer(),
            Text('₹ ${widget.data!.customOffer.price}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
          ],
        ),
        SizedBox(height: 2,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Installment every x Month:',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
            Spacer(),
            Text('${widget.data!.customOffer.everyXMonths} Months',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
          ],
        ),
        SizedBox(height: 2,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Number of Installment:',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
            Spacer(),
            Text('${widget.data!.customOffer.installments}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
          ],
        ),

        SizedBox(height: 5,),
        Divider(height: 25, thickness: 3, color: Colors.white,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Amount to Pay:',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
            Spacer(),
            Text('₹ ${widget.data!.customOffer.currentInstallment.price}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),),
          ],
        ),


        SizedBox(height: 10,),
        ElevatedButton(
          onPressed: () {
            Razorpay razorpay = Razorpay();
            var options = {
              'key': 'rzp_test_1DP5mmOlF5G5ag',
              'amount': widget.data!.customOffer.currentInstallment.price * 100,
              'name': Provider.of<DoctorProvider>(context, listen: false).doctor!.firstName,
              'description': 'Custom Offer',
              'retry': {'enabled': true, 'max_count': 1},
              'send_sms_hash': true,
              'prefill': {
                'contact': '8888888888',
                'email': 'test@razorpay.com'
              },
              'external': {
                'wallets': ['paytm']
              }
            };
            razorpay.on(
                Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
            razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                handlePaymentSuccessResponse);
            razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                handleExternalWalletSelected);
            razorpay.open(options);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))
          ),
          child: Text(
            'Pay fee',
            style: TextStyle(color: Colors.white),
          ),
        ),


        SizedBox(height: 10,),
      ],
    ),
  );
}

void handlePaymentSuccessResponse(){
  print('a');
}
void handlePaymentErrorResponse(){
  print('b');
}
void handleExternalWalletSelected(){
  print('a');
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Service/Apiservice/chatapi.dart';
import '../config.dart';
import '../controller/get_invoices_controller.dart';
import '../utilities/color.dart';
import '../utilities/decoration.dart';
import '../widgets/appbarsWidget.dart';
import '../widgets/loadingIndicator.dart';
import '../widgets/noDataWidget.dart';
import '../widgets/paddingAdjustWidget.dart';

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({Key? key}) : super(key: key);

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  final ScrollController _scrollController = new ScrollController();
  @override
  void dispose() {
    // Dispose of the GetInvoicesController when the state is disposed
    Get.delete<GetInvoicesController>();
    _scrollController.dispose();
    super.dispose();
  }

  GetInvoicesController getInvoicesController =
      Get.put(GetInvoicesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => getInvoicesController.isLoading.value
          ? LoadingIndicatorWidget()
          : Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                CAppBarWidget(title: "All Invoices".tr),
                getInvoicesController.invoiceslistModel!.data.isEmpty
                    ? NoDataWidget()
                    : Positioned(
                        top: 80,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: IBoxDecoration.upperBoxDecoration(),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 0.0, left: 8, right: 8),
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: getInvoicesController
                                          .invoiceslistModel!.data.length,
                                      itemBuilder: (context, index) {
                                        var list = getInvoicesController
                                            .invoiceslistModel!.data[index];
                                        return GestureDetector(
                                          onTap: () {},
                                          child: PaddingAdjustWidget(
                                            index: index,
                                            itemInRow: 1,
                                            length: 2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Color(0xFFE1E1E1),
                                                  width: 0.5,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0), // Radius for all corners
                                                ),
                                              ),
                                              margin: const EdgeInsets.all(2.0),
                                              padding: const EdgeInsets.all(8.0),
                                              child: ListTile(
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text('₹' + list.amount.toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'OpenSans-Bold',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),

                                                    Text(
                                                        "Date: ${list.createdTimeStamp.toString()} ".tr,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'OpenSans-Bold',
                                                          fontSize: 14.0,
                                                        )),
                                                  ],
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: (){
                                                    ChatApi().download('$apiUrlLaravel/patient/appointment/invoice?appointment_id=${list.id.toString()}','MyDoctorjo_voice.pdf');
                                                  },
                                                  child: Icon(
                                                    Icons.download,
                                                    color: iconsColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                title: Text(
                                                    list.description.toString(),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'OpenSans-Bold',
                                                      fontSize: 14.0,
                                                    )),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              )),
                        ),
                      ),
              ],
            ),
    ));
  }
}

import 'package:az_ui/helper/extensions.dart';
import 'package:az_ui/widgets/button.dart';
import 'package:az_ui/widgets/text_form_filed.dart';
import 'package:demopatient/Screen/aboutus.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/Service/drProfileService.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:demopatient/widgets/appbarsWidget.dart';
import 'package:demopatient/widgets/errorWidget.dart';
import 'package:demopatient/widgets/imageWidget.dart';
import 'package:demopatient/widgets/loadingIndicator.dart';
import 'package:demopatient/widgets/noDataWidget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Module/User/Provider/auth_provider.dart';
import '../../utilities/color.dart';
import '../../utilities/style.dart';


class AddProfileScreen extends StatefulWidget {
  const AddProfileScreen();
  @override
  _AddProfileScreenState createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await Provider.of<AuthProvider>(context, listen: false).callApi();
    // });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // CAppBarWidget(title: 'Switch Profile'), //common app bar
            AppBar(
              iconTheme: IconThemeData(color: appBarIconColor),
              title: Text(
                'Add New Profile',
                style: kAppbarTitleStyle,
              ),
              centerTitle: true,
              backgroundColor: appBarColor,
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: IBoxDecoration.upperBoxDecoration(),
                child: Consumer<AuthProvider>(
                    builder: (context, provider, _) {

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('First Name'),
                              AzTextFormField().onChanged((val){
                                provider.setNewProfileFirstName(val);
                              }),
                              SizedBox(height: 5,),
                              Text('Last Name'),
                              AzTextFormField().onChanged((val){
                                provider.setNewProfileLastName(val);
                              }),
                              SizedBox(height: 5,),
                              Text('Age'),
                              AzTextFormField().onChanged((val){
                                provider.setNewProfileAge(val);
                              }).keyboardTypeNumber(),

                              SizedBox(height: 5,),
                              Text('Gender'),
                              // AzTextFormField().onChanged((val){
                              //   provider.setNewProfileGender(val);
                              // }),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: DropdownButton<String>(
                                  focusColor: Colors.white,
                                  value: provider.newProfileGender,
                                  //elevation: 5,
                                  style: TextStyle(color: Colors.white),
                                  iconEnabledColor: appBarColor,
                                  items: <String>[
                                    'Male',
                                    'Female',
                                    'Other',
                                  ].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value.tr,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    "Select Gender".tr,
                                  ),
                                  onChanged: (String? value) {
                                    setState(() {
                                      // print(value);
                                      provider.setNewProfileGender(value);
                                    });
                                  },
                                ),
                              ),

                              SizedBox(height: 5,),

                              AzButton('Create Profile').solidThree(appBarColor, appBarColor).wFull().onPressed(() {
                                provider.callCreateProfileApi();
                              }),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            )
          ],
        ));
  }

}

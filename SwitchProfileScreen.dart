import 'package:az_ui/helper/extensions.dart';
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
import 'AddProfileScreen.dart';


class SwitchProfileScreen extends StatefulWidget {
  const SwitchProfileScreen();
  @override
  _SwitchProfileScreenState createState() => _SwitchProfileScreenState();
}

class _SwitchProfileScreenState extends State<SwitchProfileScreen> {

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
                'Select a Profile',
                style: kAppbarTitleStyle,
              ),
              centerTitle: true,
              backgroundColor: appBarColor,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap:(){
                      Get.to(AddProfileScreen());
                    },
                    child: Icon(Icons.add),
                  ),
                )
              ],
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
                    if(provider.loading == true) {
                      return Center(
                          child: Container(
                              height: 30,
                              width: 30,
                              child: CircularProgressIndicator()
                          )
                      );
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for(int i = 0; i < provider.users.length; ++i)
                            InkWell(
                              onTap: (){
                                provider.setActiveProfile(provider.users[i]);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(provider.users[i].firstName.toString() + ' ' + provider.users[i].lastName.toString()),
                                        Spacer(),
                                        Icon(Icons.arrow_forward_ios, size: 20)
                                      ],
                                    ),
                                  ).azContainer().px(5).py(10),
                                  Divider(),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }
                ),
              ),
            )
          ],
        )
    );
  }
}

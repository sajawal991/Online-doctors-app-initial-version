import 'package:az_ui/helper/extensions.dart';
import 'package:az_ui/widgets/button.dart';
import 'package:az_ui/widgets/text_form_filed.dart';
import 'package:flutter/material.dart';
import 'package:demopatient/utilities/decoration.dart';
import 'package:provider/provider.dart';

import '../../../Provider/doctor_provider.dart';
import '../../../utilities/color.dart';
import '../../../utilities/style.dart';
import '../../../widgets/colors.dart';
import '../../Config/ColorConfig.dart';
import '../../Widget/CommonWidget.dart';
import '../Provider/DoctorProvider.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen();
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {

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
            AppBar(
              iconTheme: IconThemeData(color: mainColor),
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
                child: Consumer<DoctorProvider>(
                    builder: (context, provider, _) {

                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text("${provider.doctor!.firstName} ${provider.doctor!.lastName}")
                                .azText().bold().fs(20),
                              ),
                              gapY(),
                              Center(
                                child: Text(provider.doctor!.subTitle.toString())
                              ),
                              gapY(),
                              Text("About Doctor").azText().bold().fs(20),
                              gapY(),
                              Text(provider.doctor!.aboutUs.toString()),
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

import 'package:demopatient/Service/Model/ChatModel.dart';
import 'package:flutter/foundation.dart';
import '../../../Service/drProfileService.dart';
import '../../../model/drProfielModel.dart';

class DoctorProvider with ChangeNotifier {
  // Map<int, List<ChatClass>> selected = {};

  DrProfileModel? doctor;

  callSingleDoctorApi() async {

    List<DrProfileModel> doctors = await DrProfileService.getDataByDrId("1");
    if(doctors.isNotEmpty){
      doctor = doctors[0];
    }

    notifyListeners();
  }
}

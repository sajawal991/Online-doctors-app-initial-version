import 'package:demopatient/model/reports_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:provider/provider.dart';

class ReportProvider with ChangeNotifier{

  List<ReportsModel>? data;

  getData() async{

    var request = http.Request('GET', Uri.parse('https://mydoctorjo.com/api/patient/report/index?user_i'));


    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      data = reportsModelFromJson(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

    notifyListeners();
  }

}


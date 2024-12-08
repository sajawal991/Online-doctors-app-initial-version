// by hassan005004

import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../model/lablistmodel.dart';
import 'dart:io';

import '../../../model/prescriptionModel.dart';

class LabTestApi {

  GetLabTest(dynamic lab_test_id) async {
    final loginUrl = Uri.parse('$apiUrlLaravel/doctor/labtest/show?id=${lab_test_id}');
    final response = await http.get(loginUrl, headers: {});

    Lablistmodel model = lablistmodelSingleFromJson(response.body.toString());
    if(response.statusCode == 200){
      return model;
    }else{
      return [];
    }
  }

  GetPrescription(dynamic prescription_id) async {
    final loginUrl = Uri.parse('$apiUrlLaravel/doctor/prescription/show?id=${prescription_id}');
    final response = await http.get(loginUrl, headers: {});


    PrescriptionModel model = prescriptionModelFromJson(response.body.toString());
    if(response.statusCode == 200){
      return model;
    }else{
      return [];
    }
  }


}

import 'package:demopatient/Service/Model/ChatModel.dart';
import 'package:flutter/foundation.dart';

class NotifyProvider with ChangeNotifier {
  // Map<int, List<ChatClass>> selected = {};

  List<ChatClass> selected = [];
  // List<ChatClass> get selected => [..._selected];
  //

  void messageAdd(dynamic id,
      dynamic appointmentId,
      dynamic userListId,
      dynamic drprofileId,
      dynamic sender,
      dynamic type,
      dynamic message,
      dynamic status) {

    // if(!selected.containsKey(appointmentId)){
    //   selected[appointmentId] = [];
    // }
    //
    // for (var entry in selected.entries) {
    //   if(entry.key == appointmentId){
    //     print('asdasd');
    //     entry.value.add(ChatClass(
    //         id: id,
    //         appointmentId: appointmentId,
    //         userListId: userListId,
    //         drprofileId: drprofileId,
    //         sender: sender,
    //         type: type,
    //         message: message,
    //         status: status,
    //         createdAt: DateTime.now(),
    //         updatedAt: DateTime.now())
    //     );
    //   }
    // }


    // print(selected.length);
    selected.add(ChatClass(
        id: id,
        appointmentId: appointmentId,
        userListId: userListId,
        drprofileId: drprofileId,
        sender: sender,
        type: type,
        message: message,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now())
    );
    // print(';notifyListeners()');
    // print(_selected.length);


    notifyListeners();

  }

  void remove(dynamic id,
      dynamic appointmentId,
      dynamic userListId,
      dynamic drprofileId,
      dynamic sender,
      dynamic type,
      dynamic message,
      dynamic status) {
    selected.remove(ChatClass(
        id: id,
        appointmentId: appointmentId,
        userListId: userListId,
        drprofileId: drprofileId,
        sender: sender,
        type: type,
        message: message,
        status: status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now()));
    notifyListeners();
  }

  void messageEmpty(){
    selected = [];
    notifyListeners();
  }
}

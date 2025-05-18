// ignore_for_file: prefer_final_fields

import 'package:code_structure/core/enums/view_state_model.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/others/base_view_model.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllUsersProvider extends BaseViewModel {
  DatabaseServices _databaseServices = DatabaseServices();
  FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppUser> users = [];

  AllUsersProvider() {
    getUsers();
  }

  getUsers() async {
    setState(ViewState.busy);
    // get users from database

    Stream usersStream = await _databaseServices.allUsersStream();

    print('got users');

    usersStream.listen((event) {
      users = event;
      if (_auth.currentUser != null && _auth.currentUser!.uid.isNotEmpty) {
        users = event
            .where((element) => element.uid != _auth.currentUser!.uid)
            .toList();
      }
      notifyListeners();
      setState(ViewState.idle);
    });

    setState(ViewState.idle);
  }
}

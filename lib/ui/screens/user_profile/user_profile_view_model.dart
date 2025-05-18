import 'package:code_structure/core/enums/view_state_model.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/others/base_view_model.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileViewModel extends BaseViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseServices _databaseServices = DatabaseServices();

  bool isLiked = false;
  bool isSuperLiked = false;

  UserProfileViewModel(AppUser user) {
    addVisitor(user.uid ?? '');
    checkLikeStatus(user);
    checkSuperLikeStatus(user);
  }

  Future<void> checkLikeStatus(AppUser user) async {
    try {
      isLiked = user.likes?.contains(_auth.currentUser!.uid) ?? false;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> checkSuperLikeStatus(AppUser user) async {
    try {
      isSuperLiked = user.superLikes?.contains(_auth.currentUser!.uid) ?? false;
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  addVisitor(String userId) async {
    try {
      setState(ViewState.busy);
      // add visitor to the user profile
      await _databaseServices.addVisitor(_auth.currentUser!.uid, userId);
      setState(ViewState.idle);
    } catch (e) {
      print(e.toString());
      setState(ViewState.idle);
    }
  }

  Future<void> giveLike(String userId) async {
    try {
      setState(ViewState.busy);
      isLiked = true;
      notifyListeners();
      await _databaseServices.giveLike(_auth.currentUser!.uid, userId);
      setState(ViewState.idle);
    } catch (e) {
      print(e.toString());
      setState(ViewState.idle);
    }
  }

  Future<void> removeLike(String userId) async {
    try {
      setState(ViewState.busy);
      isLiked = false;
      notifyListeners();
      await _databaseServices.removeLike(_auth.currentUser!.uid, userId);
      setState(ViewState.idle);
    } catch (e) {
      print(e.toString());
      setState(ViewState.idle);
    }
  }

  Future<void> giveSuperLike(String userId) async {
    try {
      setState(ViewState.busy);
      isSuperLiked = true;
      notifyListeners();
      await _databaseServices.giveSuperLike(_auth.currentUser!.uid, userId);
      setState(ViewState.idle);
    } catch (e) {
      print(e.toString());
      setState(ViewState.idle);
    }
  }

  Future<void> removeSuperLike(String userId) async {
    try {
      setState(ViewState.busy);
      isSuperLiked = false;
      notifyListeners();
      await _databaseServices.removeSuperLike(_auth.currentUser!.uid, userId);
      setState(ViewState.idle);
    } catch (e) {
      print(e.toString());
      setState(ViewState.idle);
    }
  }

  ///
  ///user personal images in his/her profile
  ///
  List<String> userImagesList = [
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
  ];

  ///
  /// user friends list
  ///
  List<String> friendsImagesList = [
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
    'https://hips.hearstapps.com/hmg-prod/images/gettyimages-1175559425.jpg',
    'https://s.abcnews.com/images/GMA/billie-eilish-gty-jt-201112_1605208921798_hpMain_16x9_992.jpg',
  ];

  ///
  ///  interesting
  ///
  List<String> interestingItemList = [
    'Guitar & tabla',
    'Music & Games',
    'Fishing',
    'Swimming',
    'Book % Movies',
    'Dancing & Singing',
  ];

  ///
  /// looking for
  ///
  List<String> lookingForItemList = [
    'Guitar & tabla',
    'Music & Games',
    'Fishing',
    'Swimming',
    'Book % Movies',
    'Dancing & Singing',
  ];
}

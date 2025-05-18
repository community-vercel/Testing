import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/others/base_view_model.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:geolocator/geolocator.dart';

class DiscoverSCreenViewModel extends BaseViewModel {
  List<AppUser> allUsers = [];
  List<AppUser> filteredUsers = [];
  List<SwipeItem> _swipeItems = [];
  MatchEngine? matchEngine;
  bool isLoading = false;

  // Filter parameters
  int? minAge;
  int? maxAge;
  int? maxDistance;
  String? gender;
  double? filterLatitude;
  double? filterLongitude;

  DiscoverSCreenViewModel(List<AppUser> users) {
    print('kajsdkjfkabf ${users.length}');
    allUsers = users;
    filteredUsers = List.from(allUsers);
    _initializeCards(filteredUsers);
  }

  void _initializeCards(List<AppUser> users) {
    isLoading = true;
    notifyListeners();

    try {
      _swipeItems = users.map((user) {
        return SwipeItem(
          content: user,
          likeAction: () {
            // Handle like action
          },
          nopeAction: () {
            // Handle nope action
          },
          superlikeAction: () {
            // Handle superlike action
          },
        );
      }).toList();
      isLoading = false;
      matchEngine = MatchEngine(swipeItems: _swipeItems);
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetCards(List<AppUser> users) {
    allUsers = users;
    applyFilters(
        minAge, maxAge, maxDistance, gender, filterLatitude, filterLongitude);
  }

  void applyFilters(int? minAge, int? maxAge, int? distance, String? gender,
      double? latitude, double? longitude) {
    isLoading = true;
    notifyListeners();

    try {
      // Store filter parameters
      this.minAge = minAge;
      this.maxAge = maxAge;
      this.maxDistance = distance;
      this.gender = gender;
      this.filterLatitude = latitude;
      this.filterLongitude = longitude;

      // Start with all users
      filteredUsers = List.from(allUsers);

      // Apply age filter
      if (minAge != null && maxAge != null) {
        filteredUsers = filteredUsers.where((user) {
          if (user.dob == null) return false;
          int age = DateTime.now().year - user.dob!.year;
          return age >= minAge && age <= maxAge;
        }).toList();
      }

      // Apply gender filter
      if (gender != null && gender != 'Both') {
        filteredUsers = filteredUsers.where((user) {
          return user.gender == gender;
        }).toList();
      }

      // Apply distance filter if location is available
      if (distance != null && latitude != null && longitude != null) {
        filteredUsers = filteredUsers.where((user) {
          if (user.latitude == null || user.longitude == null) return false;

          double distanceInKm = Geolocator.distanceBetween(
                latitude,
                longitude,
                user.latitude!,
                user.longitude!,
              ) /
              1000; // Convert meters to kilometers

          return distanceInKm <= distance;
        }).toList();
      }

      // Reinitialize cards with filtered users
      _initializeCards(filteredUsers);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

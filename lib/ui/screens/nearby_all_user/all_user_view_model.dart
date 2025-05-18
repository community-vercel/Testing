import 'package:code_structure/core/constants/app_assest.dart';
import 'package:code_structure/core/model/nearby_all_user.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/others/base_view_model.dart';
import 'package:geolocator/geolocator.dart';

class NearbyAllUsersViewModel extends BaseViewModel {
  List<NearbyAllUsersModel> allUsersList = [
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderMan,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderMan,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderMan,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderMan,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderMan,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderWoman,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().pic,
        name: 'shanzoo',
        gender: AppAssets().genderMan,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().discoverBack,
        name: 'shanzoo',
        gender: AppAssets().genderWoman,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().discoverBack,
        name: 'shanzoo',
        gender: AppAssets().genderWoman,
        rating: '23'),
    NearbyAllUsersModel(
        imageUrl: AppAssets().discoverBack,
        name: 'shanzoo',
        gender: AppAssets().genderWoman,
        rating: '23')
  ];

  List<AppUser> allUsers = [];
  List<AppUser> filteredUsers = [];
  bool isLoading = false;

  // Filter parameters
  int? minAge;
  int? maxAge;
  int? maxDistance;
  String? gender;
  double? filterLatitude;
  double? filterLongitude;

  NearbyAllUsersViewModel() {
    filteredUsers = List.from(allUsers);
  }

  void updateUsers(List<AppUser> users) {
    isLoading = true;
    notifyListeners();

    try {
      allUsers = users;
      filteredUsers = List.from(allUsers);
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

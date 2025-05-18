import 'dart:io';

import 'package:code_structure/core/enums/view_state_model.dart';
import 'package:code_structure/core/model/app_user.dart';
import 'package:code_structure/core/others/base_view_model.dart';
import 'package:code_structure/core/services/database_services.dart';
import 'package:code_structure/core/services/storage_services.dart';
import 'package:code_structure/core/services/image_cache_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum ProfileMode { registration, update }

class EditProfileViewModel extends BaseViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final DatabaseServices _databaseServices = DatabaseServices();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  late AppUser appUser;
  late ProfileMode mode;
  bool get isRegistration => mode == ProfileMode.registration;

  List<File?> selectedImages = List.filled(6, null);
  List<bool> imageChanged = List.filled(6, false);

  // Predefined options
  final List<String> predefinedGenders = [
    'Male',
    'Female',
    'Non-binary',
    'Other',
    'Prefer not to say',
  ];

  final List<String> predefinedLookingFor = [
    'Friendship',
    'Dating',
    'Long-term Relationship',
    'Marriage',
    'Casual',
  ];

  final List<String> predefinedRelationshipStatus = [
    'Single',
    'In a relationship',
    'Married',
    'Divorced',
    'It\'s complicated',
    'Prefer not to say',
  ];

  EditProfileViewModel({ProfileMode? mode}) {
    this.mode = mode ?? ProfileMode.update;
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    setState(ViewState.busy);
    appUser = AppUser(
      images: List.filled(6, null),
      interests: [],
      lookingFor: [],
      createdAt: DateTime.now(),
    );

    if (isRegistration) {
      // For new registration, create a new AppUser instance
      appUser = AppUser(
        images: List.filled(6, null),
        interests: [],
        lookingFor: [],
        createdAt: DateTime.now(),
      );
    } else {
      // For profile update, fetch existing user data
      try {
        final userData =
            await _databaseServices.getUser(_auth.currentUser!.uid);
        appUser = userData ??
            AppUser(
              images: List.filled(6, null),
              interests: [],
              lookingFor: [],
              createdAt: DateTime.now(),
            );
      } catch (e) {
        print('Error fetching user data: $e');
        // Handle error appropriately
      }
    }

    setState(ViewState.idle);
  }

  bool get isProfileComplete {
    return appUser.userName != null &&
        appUser.dob != null &&
        appUser.gender != null &&
        ((selectedImages.any((img) => img != null) ?? false) ||
            (appUser.images?.any((img) => img != null) ?? false));
  }

  Future<bool> updateUser() async {
    try {
      setState(ViewState.busy);

      // Set or update basic user information
      appUser.uid = _auth.currentUser!.uid;
      appUser.createdAt ??= DateTime.now();
      appUser.fcmToken = await _firebaseMessaging.getToken();

      // Handle image updates
      for (int i = 0; i < selectedImages.length; i++) {
        if (selectedImages[i] != null) {
          // Upload new/changed images
          String url = await _storageService.uploadProfileImage(
              selectedImages[i]!, _auth.currentUser!.uid);
          appUser.images![i] = url;

          // Cache the uploaded image
          try {
            await ImageCacheHelper.cacheLocalFile(url, selectedImages[i]!);
          } catch (e) {
            print('Error caching uploaded image: $e');
          }
        }
      }

      // Update user in database
      await _databaseServices.setUser(appUser);

      setState(ViewState.idle);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      setState(ViewState.idle);
      return false;
    }
  }

  // Image handling methods
  Future<void> selectfromGallery(int index) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        selectedImages[index] = File(image.path);
        imageChanged[index] = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error selecting image: $e');
    }
  }

  Future<bool> deleteImage(int index) async {
    try {
      setState(ViewState.busy);

      final imageUrl = appUser.images?[index];

      if (imageUrl != null) {
        // Delete from storage
        try {
          await _storageService.deleteFile(imageUrl);
          await ImageCacheHelper.removeFromCache(imageUrl);
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      // Update model
      appUser.images![index] = null;
      selectedImages[index] = null;
      imageChanged[index] = true;

      setState(ViewState.idle);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error in deleteImage: $e');
      setState(ViewState.idle);
      return false;
    }
  }

  // Profile update methods with validation
  void updateField<T>(String field, T value) {
    switch (field) {
      case 'userName':
        appUser.userName = value as String;
        break;
      case 'about':
        appUser.about = value as String;
        break;
      case 'gender':
        appUser.gender = value as String;
        break;
      case 'dob':
        appUser.dob = value as DateTime;
        break;
      case 'height':
        appUser.height = value as int;
        break;
      case 'weight':
        appUser.weight = value as int;
        break;
      case 'relationshipStatus':
        appUser.relationshipStatus = value as String;
        break;
    }
    notifyListeners();
  }

  // Validation methods
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }
    return null;
  }

  String? validateAbout(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please write something about yourself';
    }
    if (value.length < 10) {
      return 'About section should be at least 10 characters';
    }
    if (value.length > 500) {
      return 'About section should be less than 500 characters';
    }
    return null;
  }

  String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    final height = int.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (height < 100 || height > 250) {
      return 'Please enter a valid height (100-250 cm)';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = int.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    if (weight < 30 || weight > 200) {
      return 'Please enter a valid weight (30-200 kg)';
    }
    return null;
  }

  void toggleLookingFor(String item) {
    appUser.lookingFor ??= [];
    if (appUser.lookingFor!.contains(item)) {
      appUser.lookingFor!.remove(item);
    } else {
      appUser.lookingFor!.add(item);
    }
    notifyListeners();
  }

  void addInterest(String interest) {
    appUser.interests ??= [];
    if (!appUser.interests!.contains(interest)) {
      appUser.interests!.add(interest);
      notifyListeners();
    }
  }

  void removeInterest(String interest) {
    appUser.interests?.remove(interest);
    notifyListeners();
  }

  // Location methods
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> updateLocation() async {
    try {
      setState(ViewState.busy);

      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        setState(ViewState.idle);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print(place.toString());
        appUser.latitude = position.latitude;
        appUser.longitude = position.longitude;
        appUser.address =
            '${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
        appUser.city = place.subAdministrativeArea;
        appUser.country = place.country;

        notifyListeners();
      }
    } catch (e) {
      print('Error updating location: $e');
    } finally {
      setState(ViewState.idle);
    }
  }

  Future<void> updateCustomLocation(String address) async {
    try {
      setState(ViewState.busy);

      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations[0];
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          appUser.latitude = location.latitude;
          appUser.longitude = location.longitude;
          appUser.address = address;
          appUser.city = place.locality;
          appUser.country = place.country;

          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating custom location: $e');
    } finally {
      setState(ViewState.idle);
    }
  }
}

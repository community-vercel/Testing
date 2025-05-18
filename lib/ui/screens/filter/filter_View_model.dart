import 'package:code_structure/core/others/base_view_model.dart';

class FilterViewModel extends BaseViewModel {
  String _currentLocation = 'select current location'; // Default location
  void updateLocation(String location) {
    _currentLocation = location;
    notifyListeners();
  }
}

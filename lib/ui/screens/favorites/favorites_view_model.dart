import 'package:code_structure/core/others/base_view_model.dart';

class FavoritesViewModel extends BaseViewModel {
  String selectedCategory = 'All connections';

  toggleCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }
}

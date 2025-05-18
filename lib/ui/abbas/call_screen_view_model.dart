import 'package:code_structure/core/others/base_view_model.dart';

class CallScreenViewModel extends BaseViewModel {
  List<String> numbersList = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '#',
    '0',
    '*'
  ];
}
// class CallScreenViewModel extends ChangeNotifier {
//   String _typedNumber = '';

//   String get typedNumber => _typedNumber;

//   void updateTypedNumber(String number) {
//     _typedNumber += number;
//     notifyListeners();
//   }

//   void clearTypedNumber() {
//     _typedNumber = '';
//     notifyListeners();
//   }

//   // Your existing code for numbersList
//   List<String> numbersList = [
//     '1', '2', '3',
//     '4', '5', '6',
//     '7', '8', '9',
//     '*', '0', '#',
//   ];
// }

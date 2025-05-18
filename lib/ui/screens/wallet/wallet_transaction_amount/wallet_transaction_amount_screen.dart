import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/ui/screens/wallet/wallet_transaction_details/wallet_transaction_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletTransactionAmountScreen extends StatefulWidget {
  const WalletTransactionAmountScreen({super.key});

  @override
  State<WalletTransactionAmountScreen> createState() =>
      _WalletTransactionAmountScreenState();
}

class _WalletTransactionAmountScreenState
    extends State<WalletTransactionAmountScreen> {
  String amount = '220.00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enter amount',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Amount display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Text(
                  '\$$amount',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: lightPinkColor),
                    borderRadius: BorderRadius.circular(23.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'USD',
                        style: TextStyle(
                          color: lightPinkColor,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: lightPinkColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          20.verticalSpace,
          Expanded(
            child: GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 22.w,
                  mainAxisSpacing: 15.h),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: 43.w,
              ),
              children: [
                _KeypadButton(
                  text: '1',
                  onTap: () => _updateAmount('1'),
                ),
                _KeypadButton(
                  text: '2',
                  onTap: () => _updateAmount('2'),
                ),
                _KeypadButton(
                  text: '3',
                  onTap: () => _updateAmount('3'),
                ),
                _KeypadButton(
                  text: '4',
                  onTap: () => _updateAmount('4'),
                ),
                _KeypadButton(
                  text: '5',
                  onTap: () => _updateAmount('5'),
                ),
                _KeypadButton(
                  text: '6',
                  onTap: () => _updateAmount('6'),
                ),
                _KeypadButton(
                  text: '7',
                  onTap: () => _updateAmount('7'),
                ),
                _KeypadButton(
                  text: '8',
                  onTap: () => _updateAmount('8'),
                ),
                _KeypadButton(
                  text: '9',
                  onTap: () => _updateAmount('9'),
                ),
                _KeypadButton(
                  text: '.',
                  onTap: () => _updateAmount('.'),
                ),
                _KeypadButton(
                  text: '0',
                  onTap: () => _updateAmount('0'),
                ),
                _KeypadButton(
                  text: '⌫',
                  onTap: _deleteLastDigit,
                ),
              ],
            ),
          ),

          // Next button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletTransactionDetailsScreen(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 20.h,
              ),
              margin: EdgeInsets.symmetric(horizontal: 36.w, vertical: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [lightOrangeColor, lightPinkColor],
                ),
              ),
              child: Center(
                child: Text(
                  'Next',
                  style: style17B,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateAmount(String digit) {
    setState(() {
      if (digit == '.' && amount.contains('.')) {
        return;
      }

      if (amount == '0.00') {
        if (digit == '.') {
          amount = '0.';
        } else {
          amount = digit;
        }
      } else {
        amount += digit;
      }
    });
  }

  void _deleteLastDigit() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0.00';
      }
    });
  }
}

class _KeypadButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _KeypadButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: lightGreyColor5,
            shape: BoxShape.circle,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

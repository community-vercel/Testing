import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CardForm extends StatefulWidget {
  final Function(CardFieldInputDetails) onCardComplete;

  const CardForm({Key? key, required this.onCardComplete}) : super(key: key);

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  CardFieldInputDetails? _cardDetails;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CardField(
            onCardChanged: (card) {
              setState(() {
                _cardDetails = card;
                _errorMessage = null; // Clear error when card details change
              });
            },
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              errorText: _errorMessage,
            ),
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ElevatedButton(
            onPressed: _isProcessing || _cardDetails?.complete != true
                ? null
                : () async {
                    if (_cardDetails == null || !_cardDetails!.complete) {
                      setState(() {
                        _errorMessage = 'Please enter complete card details';
                      });
                      return;
                    }
                    setState(() => _isProcessing = true);
                    try {
                      await widget.onCardComplete(_cardDetails!);
                    } catch (e) {
                      setState(() {
                        _errorMessage = 'Error processing card: $e';
                      });
                    } finally {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                      }
                    }
                  },
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Submit Payment'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:wallet_budget_tracker/helper/colors.dart';
import 'package:wallet_budget_tracker/helper/fonts.dart';

class MiniCalculator extends StatefulWidget {
  final Function(String) onResult;

  const MiniCalculator({
    Key? key,
    required this.onResult,
  }) : super(key: key);

  @override
  State<MiniCalculator> createState() => _MiniCalculatorState();
}

class _MiniCalculatorState extends State<MiniCalculator> {
  final TextEditingController calcController = TextEditingController();
  String currentNumber = '';
  String operation = '';
  double result = 0;
  double firstNumber = 0;

  Widget _calcButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: text.contains(RegExp(r'[0-9.]'))
                ? Colors.white
                : text == 'C'
                    ? Colors.red
                    : Colors.blue,
          ),
          child: Text(
            text,
            style: FontsHelper.mediumTextStyle(
              fontSize: 24,
              color: text.contains(RegExp(r'[0-9.]'))
                  ? Colors.black
                  : Colors.white,
            ),
          )),
    );
  }

  void _handleOperation(String op) {
    if (currentNumber.isNotEmpty) {
      firstNumber = double.parse(currentNumber);
      currentNumber = '';
      operation = op;
      calcController.text = '';
    }
  }

  void _handleNumber(String number) {
    if (number == '0' && currentNumber.isEmpty) return;
    currentNumber += number;
    calcController.text = currentNumber;
  }

  void _handleDecimal() {
    if (!currentNumber.contains('.')) {
      currentNumber = currentNumber.isEmpty ? '0.' : '$currentNumber.';
      calcController.text = currentNumber;
    }
  }

  void _calculate() {
    if (operation.isNotEmpty && currentNumber.isNotEmpty) {
      double secondNumber = double.parse(currentNumber);
      switch (operation) {
        case '+':
          result = firstNumber + secondNumber;
          break;
        case '-':
          result = firstNumber - secondNumber;
          break;
        case '*':
          result = firstNumber * secondNumber;
          break;
        case '/':
          if (secondNumber != 0) {
            result = firstNumber / secondNumber;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot divide by zero')),
            );
            return;
          }
          break;
      }
      widget.onResult(result.toStringAsFixed(2));
      Navigator.pop(context);
    }
  }

  void _clear() {
    setState(() {
      currentNumber = '';
      calcController.text = '';
      firstNumber = 0;
      operation = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Calculator', style: FontsHelper.boldTextStyle(fontSize: 20)),
      content: SizedBox(
        width: 300,
        height: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 50,
              child: TextField(
                controller: calcController,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _calcButton('7', () => _handleNumber('7')),
                _calcButton('8', () => _handleNumber('8')),
                _calcButton('9', () => _handleNumber('9')),
                _calcButton('4', () => _handleNumber('4')),
                _calcButton('5', () => _handleNumber('5')),
                _calcButton('6', () => _handleNumber('6')),
                _calcButton('1', () => _handleNumber('1')),
                _calcButton('2', () => _handleNumber('2')),
                _calcButton('3', () => _handleNumber('3')),
                _calcButton('C', _clear),
                _calcButton('0', () => _handleNumber('0')),
                _calcButton('.', _handleDecimal),
                _calcButton('÷', () => _handleOperation('/')),
                _calcButton('+', () => _handleOperation('+')),
                _calcButton('-', () => _handleOperation('-')),
                _calcButton('×', () => _handleOperation('*')),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.black,
                ),
                onPressed: _calculate,
                child: Text('=',
                    style: FontsHelper.mediumTextStyle(
                        fontSize: 24, color: ColorsHelper.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    calcController.dispose();
    super.dispose();
  }
}

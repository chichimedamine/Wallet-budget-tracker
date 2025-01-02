import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helper/colors.dart';

class AIBot extends StatefulWidget {
  const AIBot({super.key});

  @override
  _AIBotState createState() => _AIBotState();
}

enum TransactionType { income, transfer, expense, unknown }

class _AIBotState extends State<AIBot> {
  late FlutterTts flutterTts;
  TransactionType? _currentTransactionType;
  String? _transactionName;
  double? _transactionAmount;
  int count = 0;

  final _textController = TextEditingController();
  final _labeltextfieldController = TextEditingController();
  late ManualSttController _controller;
  String _finalRecognizedText = '';
  ManualSttState _currentState = ManualSttState.stopped;
  double _soundLevel = 0.0;
  Timer? _autoStopTimer;
  Timer? _silenceTimer;
  double silenceThreshold = -2.0;
  Duration silenceDuration = const Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = ManualSttController(context);
    flutterTts = FlutterTts();
    _initTts();
  }

  @override
  void dispose() {
    _textController.dispose();
    _labeltextfieldController.dispose();
    _autoStopTimer?.cancel();
    _silenceTimer?.cancel();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-GB");
    await flutterTts.setPitch(0.7);
    await flutterTts.setSpeechRate(0.6);
  }

  Future<void> respond(String message) async {
    if (message.isNotEmpty) {
      await flutterTts.speak(message);
    }
  }

  Future<void> listen() async {
    _controller.startStt();
    _currentState = ManualSttState.listening;
    _labeltextfieldController.text = "Listening...";
    _controller.listen(
      onListeningStateChanged: (state) {
        setState(() => _currentState = state);
      },
      onListeningTextChanged: (recognizedText) {
        setState(() {
          _textController.clear();
          _finalRecognizedText = recognizedText;
          _textController.text = recognizedText;
        });
      },
      onSoundLevelChanged: (level) {
        setState(() => _soundLevel = level);
      },
    );
  }

  Future<void> respondAndListen(String message) async {
    respond(message);
    flutterTts.completionHandler = () => listen();
    // Add your listening logic here
  }

  Future<void> stop() async {
    _controller.stopStt();
    count = 0;
    _labeltextfieldController.text = "Tap microphone to listen";
    _currentState = ManualSttState.stopped;
  }

  Future<void> chatAi() async {
    //add permission request microphone
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Microphone permission is not granted');
    }

    try {
      if (count == 0) {
        await TransactionTypeQuestion();
      } else if (count == 1) {
        await TransactionNameQuestion();
      } else if (count == 2) {
        await TransactionAmountQuestion();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> TransactionTypeQuestion() async {
    respond ("choose your transaction type : income, transfer, expense");

    final text = _textController.text;
    final type = _parseTransactionType(text);
    print("type: $type");

    final namePrompt = _getNamePrompt(type);
    await respond(namePrompt);
    await listen();
    count++;
  }

  TransactionAmountQuestion() {
    const amountPrompt = "What is the amount?";
    respondAndListen(amountPrompt);
    final amount = _textController.text;

    _transactionAmount = parseAmount(amount);
    count++;
  }

  double? parseAmount(String amount) {
    final amountPattern = RegExp(r'\d+(\.\d{1,2})?');
    final match = amountPattern.firstMatch(amount);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  TransactionNameQuestion() {
    final namePrompt =
        "What is the name of the transaction of type $_currentTransactionType?";
    final name = _textController.text;
    _transactionName = name;
    respondAndListen(namePrompt);
    listen();
    count++;
  }

  String _parseTransactionType(String text) {
    final lowercaseText = text.toLowerCase();
    if (lowercaseText.contains('income')) return "income";
    if (lowercaseText.contains('transfer')) return "transfer";
    if (lowercaseText.contains('expense')) return "expense";
    return "unknown";
  }

  String _getNamePrompt(String type) {
    switch (type) {
      case "income":
        return "What is the name of the income source?";
      case "transfer":
        return "What is the name of the transfer source?";
      case "expense":
        return "What is the name of the expense?";
      default:
        return "What should we name this transaction?";
    }
  }

  double? _parseAmount(String text) {
    final RegExp amountPattern = RegExp(r'\d+(\.\d{1,2})?');
    final match = amountPattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  String _buildConfirmationMessage() {
    final typeStr = _currentTransactionType.toString().split('.').last;
    final amount =
        NumberFormat.currency(symbol: '\$').format(_transactionAmount);
    return "I'll create a $typeStr transaction named '$_transactionName' for $amount";
  }

  Future<void> _processTransaction() async {
    await respond("Transaction processed successfully!");
  }

  void _resetTransactionData() {
    _currentTransactionType = null;
    _transactionName = null;
    _transactionAmount = null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentState == ManualSttState.listening ? 70 : 56,
      height: _currentState == ManualSttState.listening ? 70 : 56,
      child: FloatingActionButton(
        heroTag: "mic",
        backgroundColor: ColorsHelper.green,
        onPressed: () async {
          if (_currentState == ManualSttState.stopped) {
            _currentState = ManualSttState.listening;
            count = 0;
            chatAi();
            _textController.clear();
            ShowBottomSheetAi(context, _currentState, chatAi, stop,
                _textController, _labeltextfieldController);
            setState(() {});
          } else {
            stop();
            setState(() {});
          }
        },
        child: Icon(
          _currentState == ManualSttState.listening ? Icons.mic : Icons.mic_off,
          color: ColorsHelper.white,
        ),
      ),
    );
  }

  ShowBottomSheetAi(
      BuildContext context,
      ManualSttState statelistening,
      Function listen,
      Function stop,
      textController,
      labeltextfieldController) {
    return showModalBottomSheet(
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            height: 300,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: AbsorbPointer(
                      child: TextField(
                        showCursor: false,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        controller: labeltextfieldController,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 300.0, // Set your desired width
                    height: 60.0, // Set your desired height
                    child: AbsorbPointer(
                      child: TextField(
                        showCursor: false,
                        readOnly: true,
                        decoration: const InputDecoration(
                          //background text field transparent
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                        ),
                        controller: textController,
                        minLines: 6,
                        maxLines: 10,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FloatingActionButton(
                    heroTag: "mic",
                    backgroundColor: ColorsHelper.green,
                    onPressed: () async {
                      print("statelistening: $statelistening");
                      if (statelistening == ManualSttState.stopped) {
                        listen();
                        setState(() {
                          statelistening = ManualSttState.listening;
                        });
                      } else {
                        stop();
                        setState(() {
                          statelistening = ManualSttState.stopped;
                        });
                      }
                    },
                    child: Icon(
                      statelistening == ManualSttState.listening
                          ? Icons.mic
                          : Icons.mic_off,
                      color: ColorsHelper.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}

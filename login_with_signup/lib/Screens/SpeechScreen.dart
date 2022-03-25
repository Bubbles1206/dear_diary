import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../DatabaseHandler/DiaryDBHelper.dart';
import '../Model/DiaryModel.dart';
import 'HomeScreen.dart';

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final _conUserName = TextEditingController();
  DiaryDbHelper helper;

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;
    setState(() {
      _conUserName.text = sp.getString("user_name");
    });
  }

  final Map<String, HighlightedWord> _highlights = {
    'flutter': HighlightedWord(
      onTap: () => print('FLUTTER!!!'),
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'voice': HighlightedWord(
      onTap: () => print('voice'),
      textStyle: const TextStyle(
        color: Colors.purple,
        fontWeight: FontWeight.bold,
      ),
    ),
    'angry': HighlightedWord(
      onTap: () => print('angry'),
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    'like': HighlightedWord(
      onTap: () => print('like'),
      textStyle: const TextStyle(
        color: Colors.pink,
        fontWeight: FontWeight.bold,
      ),
    ),
    'jealous': HighlightedWord(
      onTap: () => print('jealous'),
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    'wethinkcode': HighlightedWord(
      onTap: () => print('WeThinkCode'),
      textStyle: const TextStyle(
        color: Colors.lightBlueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
    'sad': HighlightedWord(
      onTap: () => print('sad'),
      textStyle: const TextStyle(
        color: Colors.blueGrey,
        fontWeight: FontWeight.bold,
      ),
    ),
    'showcase': HighlightedWord(
      onTap: () => print('showcase'),
      textStyle: const TextStyle(
        color: Colors.yellow,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    getUserData();
    helper = new DiaryDbHelper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          icon: const BackButtonIcon(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
              child: TextHighlight(
                text: _text,
                words: _highlights,
                textStyle: const TextStyle(
                  fontSize: 32.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      saveEntry(_conUserName.value.text, _text);
                    },
                    child: Text("Save entry?"))
              ],
            )
          ],
        ),
      ),
    );
  }

  String getDate() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(now);
    return formatted;
  }

  void saveEntry(String uname, String text) async {
    if (text.isNotEmpty) {
      DiaryModel testData = new DiaryModel(uname, text, getDate());
      await helper.saveDiary(testData);
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          // listenMode: ListenMode,
          // listenFor: Duration(seconds: 30),
          partialResults: true,
          pauseFor: Duration(seconds: 15),
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}

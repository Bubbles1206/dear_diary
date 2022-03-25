import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../DatabaseHandler/DiaryDBHelper.dart';
import '../Model/DiaryModel.dart';
import 'HomeScreen.dart';

class TestTalk extends StatefulWidget {
  @override
  _TestTalkState createState() => _TestTalkState();
}

class _TestTalkState extends State<TestTalk> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final _conUserName = TextEditingController();
  bool _hasSpeech = false;
  bool _logEvents = true;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  DiaryDbHelper helper;
  // String lastError = '';
  // String lastStatus = '';
  // String _currentLocaleId = '';
  // List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      _conUserName.text = sp.getString("user_name");
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    helper = new DiaryDbHelper();
  }

  Future<void> initSpeechState() async {
    _logEvent('Initialize');
    var hasSpeech = await speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'));
    // if (hasSpeech) {
    //   _localeNames = await speech.locales();
    //
    //   var systemLocale = await speech.systemLocale();
    //   _currentLocaleId = systemLocale?.localeId ?? '';
    // }

    if (!mounted) return;

    setState(() {
      _hasSpeech = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Speech to Text Example'),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            icon: const BackButtonIcon(),
          ),
        ),
        body: Column(children: [
          Center(
            child: Text(
              'Speech recognition available',
              style: TextStyle(fontSize: 22.0),
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _hasSpeech ? null : initSpeechState,
                      child: Text('Initialize'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: !_hasSpeech || speech.isListening
                          ? null
                          : startListening,
                      child: Text('Start'),
                    ),
                    ElevatedButton(
                      onPressed: speech.isListening ? stopListening : null,
                      child: Text('Stop'),
                    ),
                    ElevatedButton(
                      onPressed: speech.isListening ? cancelListening : null,
                      child: Text('Cancel'),
                    )
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: <Widget>[
                //     Row(
                //       children: [
                //         Text('Language: '),
                //         // DropdownButton(
                //         //   onChanged: (selectedVal) => _switchLang(selectedVal),
                //         //   value: _currentLocaleId,
                //         //   items: _localeNames
                //         //       .map(
                //         //         (localeName) => DropdownMenuItem(
                //         //           value: localeName.localeId,
                //         //           child: Text(localeName.name),
                //         //         ),
                //         //       )
                //         //       .toList(),
                //         // ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         Text('Log events: '),
                //         Checkbox(
                //             value: _logEvents,
                //             onChanged: (val) => setState(() {
                //                   _logEvents = val ?? false;
                //                 })),
                //       ],
                //     )
                //   ],
                // )
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Recognized Words',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Theme.of(context).selectedRowColor,
                        child: Center(
                          child: Text(
                            lastWords,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        bottom: 10,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: .26,
                                    spreadRadius: level * 1.5,
                                    color: Colors.black.withOpacity(.05))
                              ],
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.mic),
                              onPressed: () => null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                Center(
                  child: Text(
                    'Error Status',
                    style: TextStyle(fontSize: 22.0),
                  ),
                ),
                // Center(
                //   child: Text(lastError),
                // ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Theme.of(context).backgroundColor,
            child: Center(
              child: speech.isListening
                  ? Text(
                      "I'm listening...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      'Not listening',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    saveEntry(_conUserName.value.text, lastWords);
                  },
                  child: Text("Save entry?"))
            ],
          )
        ]),
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

  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    // lastError = '';
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 500),
        partialResults: true,
        // localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      lastWords = '${result.recognizedWords} - ${result.finalResult}';
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
    }
  }
}

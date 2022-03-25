import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../DatabaseHandler/DiaryDBHelper.dart';
import '../Model/DiaryModel.dart';
import '../Widgets/DiaryListTile.dart';
import 'ProfileForm.dart';
import 'SpeechScreen.dart';
import 'TestScrene.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<String> months = ['jan','feb','mar']
  DateTime _currentDate;
  DateTime _currentDate2;
  String _currentMonth;
  DateTime _targetDateTime;
  DiaryDbHelper helper;
  List<DiaryModel> _diaries = [];
  List<DiaryModel> _filteredDiaries = [];
  EventList<EventInterface> _markedDays;
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  final _conUserName = TextEditingController();

  final dates = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
    helper = new DiaryDbHelper();
    // fakeData();
    // _currentDate = DateTime.now();
    // _currentMonth = DateFormat.yMMM().format(_currentDate);
    // _targetDateTime = _currentDate;
    // _currentDate2 = _currentDate;
    // print(_conUserName.value);
    // _loadDiary(_conUserName.text);
    print("Diaries : " + _diaries.toString());
  }

  // String getMonth() {
  //   final DateTime now = DateTime.now();
  //   final DateFormat formatter = DateFormat('MM');
  //   final String formatted = formatter.format(now);
  //   return formatted;
  // }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      _conUserName.text = sp.getString("user_name");
      _currentDate = DateTime.now();
      // dates.elementAt(getDate(widget.diaryModel.date).month - 1)
      _currentMonth = dates.elementAt(DateTime.now().month - 1);
      _targetDateTime = _currentDate;
      _currentDate2 = _currentDate;
      // print(_conUserName.value);
      _loadDiary(_conUserName.text);
    });
  }

  // static Widget _eventIcon = new Container(
  //   decoration: new BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.all(Radius.circular(1000)),
  //       border: Border.all(color: Colors.blue, width: 2.0)),
  //   child: new Icon(
  //     Icons.person,
  //     color: Colors.amber,
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    final _calendarCarouselNoHeader = CalendarCarousel(
      todayBorderColor: Colors.green,
      onDayPressed: _dayPressed,
      daysHaveCircularBorder: true,
      showOnlyCurrentMonthDate: false,
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      thisMonthDayBorderColor: Colors.grey,
      weekFormat: false,
      firstDayOfWeek: 4,
      markedDatesMap: _markedDays,
      height: 250.0,
      selectedDateTime: _currentDate,
      targetDateTime: _targetDateTime,
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      markedDateCustomShapeBorder:
          CircleBorder(side: BorderSide(color: Colors.yellow)),
      markedDateCustomTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.blue,
      ),
      showHeader: false,
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
      markedDateShowIcon: true,
      markedDateIconMaxShown: 2,
      markedDateIconBuilder: (event) {
        return event.icon;
      },
      markedDateMoreShowTotal: true,
      todayButtonColor: Colors.yellow,
      selectedDayTextStyle: TextStyle(
        color: Colors.yellow,
      ),
      // minSelectedDate: _currentDate.subtract(Duration(days: 360)),
      // maxSelectedDate: _currentDate.add(Duration(days: 360)),
      prevDaysTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.pinkAccent,
      ),
      inactiveDaysTextStyle: TextStyle(
        color: Colors.tealAccent,
        fontSize: 16,
      ),
      onCalendarChanged: (DateTime date) {
        this.setState(() {
          _targetDateTime = date;
          _currentMonth = DateFormat.yMMM().format(_targetDateTime);
        });
      },
      onDayLongPressed: (DateTime date) {
        print('long pressed date $date');
      },
    );

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Dear Diary"),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileForm()),
              );
            },
            icon: Icon(Icons.account_circle_outlined),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 5.0,
                  bottom: 5.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: new Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      _currentMonth,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24.0,
                      ),
                    )),
                    ElevatedButton(
                      child: Text('PREV'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(
                              _targetDateTime.year, _targetDateTime.month - 1);
                          _currentMonth =
                              DateFormat.yMMM().format(_targetDateTime);
                        });
                      },
                    ),
                    ElevatedButton(
                      child: Text('NEXT'),
                      onPressed: () {
                        setState(() {
                          _targetDateTime = DateTime(
                              _targetDateTime.year, _targetDateTime.month + 1);
                          _currentMonth =
                              DateFormat.yMMM().format(_targetDateTime);
                        });
                      },
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: _calendarCarouselNoHeader,
              ),
              Center(
                child: Container(
                  width: 800,
                  height: MediaQuery.of(context).size.height / 4,
                  // padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredDiaries.length,
                    itemBuilder: (context, index) {
                      DiaryModel diaryModel = _filteredDiaries[index];
                      return DiaryListTile(
                        diaryModel: diaryModel,
                      );
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => SpeechScreen()),
                        );
                      },
                      child: Text("STT-1")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => TestTalk()),
                        );
                      },
                      child: Text("STT-2"))
                ],
              )
            ],
          ),
        ));
  }

  EventList<EventInterface> _markedDaysMap() {
    EventList<EventInterface> eventsList = EventList(events: Map());

    _diaries.forEach((element) {
      DateTime diaryDate = DateTime.parse(element.text);
      Event event = Event(
        date: diaryDate,
        title: 'Diary Entry',
      );
      eventsList.add(diaryDate, event);
    });
    print("EventList : " + eventsList.toString());
    return eventsList;
  }

//      Function to load the future data of all Diaries for Username given
  Future<void> _loadDiary(String username) async {
    try {
      List<DiaryModel> diaryForUser = await helper.getDiaries(username);
      setState(() {
        _diaries = diaryForUser;
        _filteredDiaries = diaryForUser;
        _markedDays = _markedDaysMap();
      });
    } catch (e) {
      print(e);
    }
  }

  /// Function for on pressed of calendar days. If the user selects a day a list of the Diaries present
  /// on that day will be returned to the user.
  ///
  /// If no Diary entries are present on that day the function will return null
  /// and the option to select that day will be disabled.
  dynamic _dayPressed(DateTime dateTime, List<EventInterface> events) {
    // print(_diaries);

    List<DiaryModel> diaryList = [];
    for (DiaryModel diaryModel in _diaries) {
      // print("Date:" + diaryModel.text);
      DateTime diaryTime = DateTime.parse(diaryModel.date);
      if (_compareDateTime(dateTime, diaryTime)) {
        print(diaryModel.text);
        diaryList.add(diaryModel);
      }
    }
    if (diaryList.isEmpty) {
      return null;
    }

    setState(() {
      this._currentDate = dateTime;
      _filteredDiaries = diaryList;
    });
  }

  /// Method will compare two given dateTimes, if they are the same the function will
  /// return [True] else the function will return [False].
  bool _compareDateTime(DateTime dateTime1, DateTime dateTime2) {
    String firstDate = DateFormat("dd-MM-yyyy").format(dateTime1);
    String secondDate = DateFormat("dd-MM-yyyy").format(dateTime2);

    if (firstDate == secondDate) {
      return true;
    } else {
      return false;
    }
  }

  void fakeData() async {
    DiaryModel testData =
        new DiaryModel("Jason", "This is a TEST", "2022-04-26");
    // await helper.saveData(testData);
    await helper.saveDiary(testData);
    // var some;
    // some = await helper.getDiaries("Jason Kokot");
    // print("MY FAKE DATA:" + some.toString());
  }

  // navigationItem(String title, Function onPresed, EdgeInsets padding) {
  //   return GestureDetector(
  //     onTap: onPresed,
  //     child: Padding(
  //       padding: padding,
  //       child: Text(
  //         title,
  //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }
}

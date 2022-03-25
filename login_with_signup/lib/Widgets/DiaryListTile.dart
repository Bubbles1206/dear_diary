import 'package:flutter/material.dart';
import 'package:login_with_signup/Model/DiaryModel.dart';

class DiaryListTile extends StatefulWidget {
  final DiaryModel diaryModel;

  DiaryListTile({this.diaryModel});

  @override
  _DiaryListTileState createState() => _DiaryListTileState();
}

DateTime getDate(String date) {
  var parsedDate = DateTime.parse(date);
  return parsedDate;
}

class _DiaryListTileState extends State<DiaryListTile> {
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
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        tileColor: Colors.transparent.withOpacity(0.1),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date of Entry : " +
                getDate(widget.diaryModel.date).day.toString() +
                " " +
                dates.elementAt(getDate(widget.diaryModel.date).month - 1))
            // Text('${widget.diaryModel.createdAt.day.toString()} ${widget.dates[widget.diaryModel.createdAt.month - 1]}'),
            // Text(widget.diaryModel.category),
          ],
        ),
        subtitle: widget.diaryModel.username != null
            ? Text(
                widget.diaryModel.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              )
            : null,
        trailing: Wrap(
          children: [Icon(Icons.wysiwyg_sharp)],
        ),
        onTap: () {
          showDialog(
              context: context, builder: (BuildContext context) => ViewDiary());
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ViewDiary() {
    double diaWidth = MediaQuery.of(context).size.width;
    double diaHeight = MediaQuery.of(context).size.height;
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        width: diaWidth / 3,
        height: diaHeight / 2,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Date: " +
                      getDate(widget.diaryModel.date).day.toString() +
                      " " +
                      dates.elementAt(
                          getDate(widget.diaryModel.date).month - 1) +
                      " " +
                      getDate(widget.diaryModel.date).year.toString(),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                )
              ],
            ),
            Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  widget.diaryModel.username,
                  softWrap: true,
                )),
            Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  widget.diaryModel.text,
                  softWrap: true,
                )),
          ],
        ),
      ),
    );
  }
}

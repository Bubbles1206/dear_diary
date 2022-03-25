class DiaryModel {
  String username;
  String text;
  String date;

  DiaryModel(this.username, this.text, this.date);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_name': username,
      'text': text,
      'date': date
    };
    return map;
  }

  DiaryModel.fromMap(Map<String, dynamic> map) {
    username = map['user_name'];
    text = map['text'];
    date = map['date'];
  }
}

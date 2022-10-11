//时间转换
class TimeChange {
  timeStamp(String time) {
    final _time = DateTime.fromMillisecondsSinceEpoch(int.parse(time) * 1000)
        .toString()
        .substring(0, 16);
    return _time;
  }
}

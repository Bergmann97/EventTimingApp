import 'package:flutter/material.dart';


class TimerView extends StatefulWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerViewState();

}

class _TimerViewState extends State<TimerView> {

  @override
  Widget build(BuildContext context) {
    return Text("Timer");
  }
}
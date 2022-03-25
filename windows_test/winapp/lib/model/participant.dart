import 'package:winapp/controllers/utils.dart';

import 'dart:developer';


class Participant {
  int _number       = -1;
  EventState _state = EventState.none;
  String _pid       = "";

  Participant(int number, EventState state, String pid) {
    _number = number;
    _state = state;
    _pid = pid;
  }

  int getNumber() => _number;
  EventState getState() => _state;
  String getPID() => _pid;

  setState(EventState state) {
    _state = state;
  }
  setPID(String pid) {
    _pid = pid;
  }

  @override
  String toString() {
    return 'Nr.: ' + _number.toString() + ' (' + _state.toString() + ') | pid: ' + _pid;
  }

  Map<String, dynamic> toJSON() {
    return {
      'number': _number,
      'state': _state.index,
      'uid': _pid,
    };
  }
}

class ResultParticipant extends Participant {
  int _place    = -1;
  String _time  = "";
  Sex _sex      = Sex.none;
  int _age      = 0;

  ResultParticipant(
    int number, 
    EventState state, 
    String pid,
    int place,
    String time, 
    Sex sex,
    int age,
  ) : super(number, state, pid) {
    _place = place;
    _time = time;
    _sex = sex;
    _age = age;
  }


  @override
  String toString() {
    return 'Nr.: ' + _number.toString() + ' (' + _state.toString() + ') | pid: ' + _pid;
  }

  @override
  Map<String, dynamic> toJSON() {
    return {
      'number': _number,
      'state': _state.index,
      'uid': _pid,
      'place': _place,
      'sex': _sex.index,
      'time': _time,
      'age': _age,
    };
  }
}

class CreatedParticipant{
  String _cid        = '';
  String _pid        = '';
  String _firstname  = '';
  String _secondname = '';
  Sex _sex	         = Sex.none;
  String _birthdate  = '';
  String _email      = '';
  List<String> _events = [];

  CreatedParticipant(
    String cid,
    String pid,
    String firstname,
    String secondname,
    Sex sex,
    String birthdate,
    String email,
    List<String> events,
  ) {
    _cid = cid;
    _pid = pid;
    _firstname = firstname;
    _secondname = secondname;
    _sex = sex;
    _birthdate = birthdate;
    _email = email;
    _events = events;
  }

  String getCID() => _cid;
  String getPID() => _pid;
  String getFirstname() => _firstname;
  String getSecondname() => _secondname;
  String getName() => _firstname + ' ' + _secondname;
  Sex getSex() => _sex;
  String getBirthdate() => _birthdate;
  int getAge() {
    DateTime now = DateTime.now();
    DateTime birth = DateTime(
      int.parse(_birthdate.split(".")[2]),
      int.parse(_birthdate.split(".")[1]),
      int.parse(_birthdate.split(".")[0]),
    );

    if ((now.month < birth.month) || (now.month == birth.month && now.day < birth.day)) {
      return now.year-birth.year-1;
    } else {
      return now.year-birth.year;
    }
  }
  String getEmail() => _email;
  List<String> getEvents() => _events;

  setCID(String cid) {
    _cid = cid;
  }
  setPID(String pid) {
    _pid = pid;
  }
  setFirstname(String firstname) {
    _firstname = firstname;
  }
  setSecondname(String secondname) {
    _secondname = secondname;
  }
  setSex(Sex sex) {
    _sex = sex;
  }
  setBirthdate(String birthdate) {
    _birthdate = birthdate;
  }
  setEmail(String email) {
    _email = email;
  }

  addEvent(String eid) {
    if (!_events.contains(eid)) {
      _events.add(eid);
    } else {
      log('Event with eid: ' + eid + ' already exists for participant!');
    }
  }
  addEvents(List<String> eids) {
    for (String eid in eids) {
      addEvent(eid);
    }
  }
  removeEvent(String eid) {
    if (_events.contains(eid)) {
      _events.remove(eid);
    } else {
      log("Event with eid: " + eid + " does not exist within Participant!");
    }
  }
  removeEvents(List<String> eids) {
    for (String eid in eids) {
      removeEvent(eid);
    }
  }

  @override
  String toString() {
    return _pid + ': ' +
      _firstname + ' ' + _secondname + 
      ' (' + _sex.getSexLetter() + '/' + getAge().toString() + ')' +
      ' | Events: ' + _events.toString();
  }

  Map<String, dynamic> toJSON() {
    return {
      'cid': _cid,
      'pid': _pid,
      'firstname': _firstname,
      'secondname': _secondname,
      'sex': _sex.index,
      'birthdate': _birthdate,
      'email': _email,
      'events': _events,
    };
  }
}

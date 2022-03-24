import 'package:intl/intl.dart';

class EventDate {
  String _date = "";
  String _time = "";

  EventDate();

  EventDate.fromEventDate(date, time) {
    _date = date;
    _time = time;
  }

  String getDate() => _date;
  String getTime() => _time;

  toJSON() {
    return {
      'date': _date,
      'time': _time,
    };
  }

  @override
  String toString() {
    return _date + " " + _time;
  }

  EventDate fromSnapshot(Map snapshot) {
    return EventDate.fromEventDate(
      snapshot["date"],
      snapshot["time"],
    );
  }
}


class Event {
  String _eid = "";
  String _uid = "";
  String _name = "";
  EventDate _startdate = EventDate.fromEventDate(
    DateFormat('dd.MM.yy').format(DateTime.now()),
    DateFormat.Hm().format(DateTime.now()),
  );
  EventDate _enddate = EventDate.fromEventDate(
    DateFormat('dd.MM.yy').format(DateTime.now()),
    DateFormat.Hm().format(DateTime.now()),
  );
  int _maxNumParticipants = 0;
  List<dynamic> _participants = [];
  bool _generatedParticipants = true;
  bool _started = false;

  Event(
    String eid,
    String uid,
    String name,
    EventDate startdate,
    EventDate enddate,
    int maxNumParticipants,
    List<dynamic> participants,
    bool generatedParticipants
  ) {
    _eid = eid;
    _uid = uid;
    _name = name;
    _startdate = startdate;
    _enddate = enddate;
    _maxNumParticipants = maxNumParticipants;
    _generatedParticipants = generatedParticipants;
    if (_generatedParticipants && participants.isEmpty) {
      _participants = List<dynamic>.generate(_maxNumParticipants, (i) => (i+1).toString());    
    } else {
      _participants = participants;
    }
  }


// --------------- GETTER ---------------
  String getEid() => _eid;
  String getUid() => _uid;
  String getName() => _name;
  EventDate getStartdate() => _startdate;
  EventDate getEnddate() => _enddate;
  int getMaxNumParticipants() => _maxNumParticipants;
  List<dynamic> getParticipants() => _participants;

  bool isGenerated() => _generatedParticipants;
  bool isStarted() => _started;

// --------------- SETTER ---------------
  setName(String name) {
    _name = name;
  }
  setStartdate(EventDate startdate) {
    _startdate = startdate;
  }
  setEnddate(EventDate enddate) {
    _enddate = enddate;
  }
  setMaxNumParticipants(int maxNumParticipants) {
    _maxNumParticipants = maxNumParticipants;
  }
  setParticipants(List<dynamic> participants) {
    _participants = participants;
  }
  setStarted(bool started) {
    _started = started;
  }

// --------------- ADDER/REMOVER ---------------
  addParticipant(int pid) {
    // TODO
  }

  addParticipants(List<dynamic> participants) {
    // TODO
  }

  removeParticipant(int pid) {
    // TODO
  }

  removeParticipants(List<dynamic> participants) {
    // TODO
  }


  @override
  String toString() {
    return _name;
  }

  Map<String, dynamic> toJSON() {
    // log(_participants.toString());
    // log(_generatedParticipants.toString());
    // log(_participants.map((e) {
    //     return _generatedParticipants ? e : e.getUID();
    //   }).toList().toString());
    return {
      'eid': _eid,
      'uid': _uid,
      'name': _name,
      'startdate': _startdate.toJSON(),
      'enddate': _enddate.toJSON(),
      'maxNumParticipants': _maxNumParticipants,
      // 'participants': _participants,
      'participants': _participants.map((e) {
        return _generatedParticipants ? e : e.getPID();
      }).toList(),
      'generatedParticipants': _generatedParticipants,
    };
  }

  Event fromSnapshot(Map snapshot) {
    return Event(
      snapshot["eid"],
      snapshot["uid"],
      snapshot["name"],
      snapshot["startdate"],
      snapshot["enddate"],
      snapshot["maxNumParticipants"],
      snapshot["participants"].map((e) => e.fromSnapshot()).toList(),
      snapshot["generatedParticipants"],
    );
  }
}
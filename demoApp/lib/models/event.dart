class Event {
  String _eid = "";
  String _uid = "";
  String _name = "";
  DateTime _startdate = DateTime.now();
  DateTime _enddate = DateTime.now();
  int _maxNumParticipants = 0;
  List<dynamic> _participants = [];

  Event(
    String eid,
    String uid,
    String name,
    DateTime startdate,
    DateTime enddate,
    int maxNumParticipants,
    List<dynamic> participants
  ) {
    _eid = eid;
    _uid = uid;
    _name = name;
    _startdate = startdate;
    _enddate = enddate;
    _maxNumParticipants = maxNumParticipants;
    _participants = _participants;
  }


// --------------- GETTER ---------------
  String getEid() => _eid;
  String getUid() => _uid;
  String getName() => _name;
  DateTime getStartdate() => _startdate;
  DateTime getEnddate() => _enddate;
  int getMaxNumParticipants() => _maxNumParticipants;
  List<dynamic> getParticipants() => _participants;

// --------------- SETTER ---------------
  setName(String name) {
    _name = name;
  }
  setStartdate(DateTime startdate) {
    _startdate = startdate;
  }
  setEnddate(DateTime enddate) {
    _enddate = enddate;
  }
  setMaxNumParticipants(int maxNumParticipants) {
    _maxNumParticipants = maxNumParticipants;
  }
  setParticipants(List<dynamic> participants) {
    _participants = participants;
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

  toJSON() {
    return {
      'eid': _eid,
      'uid': _uid,
      'name': _name,
      'startdate': _startdate,
      'enddate': _enddate,
      'maxNumParticipants': _maxNumParticipants,
      'participants': _participants
    };
  }

  Event fromSnapshot(Map snapshot) {
    return Event(
      snapshot["eid"],
      snapshot["uid"],
      snapshot["name"],
      DateTime.parse(snapshot["startdate"]),
      DateTime.parse(snapshot["enddate"]),
      snapshot["maxNumParticipants"],
      snapshot["participants"],
    );
  }
}
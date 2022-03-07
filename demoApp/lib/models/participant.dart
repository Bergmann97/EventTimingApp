enum EventState {
  dns,
  dnf,
  running, 
  finished,
  none
}

extension ParseToString on EventState {
  String stateToString() {
    switch (index) {
      case 0:
        return "DNS";
      case 1:
        return "DNF";
      case 2:
        return "RUNNING";
      case 3:
        return "FINISHED";
      default: 
        return "UNKNOWN";
    }
  }
}

enum Sex {
  male,
  female,
  diverse,
  none
}

extension ParseToString2 on Sex {
  String sexToString() {
    switch (index) {
      case 0:
        return "male";
      case 1:
        return "female";
      case 2:
        return "diverse";
      default: 
        return "UNKNOWN";
    }
  }
}

class Participant {
  late int? _number;
  late EventState? _state;

  int getState() {
    if (_state != null) {
      return _state!.index;
    } else {
      return 0;
    }
  }

  setState(EventState state) {
    _state = state;
  }

  toJSON() {
    return {
      'startnumber': _number,
      'state': _state!.index,
    };
  }
}

class GeneratedParticipant extends Participant {
  GeneratedParticipant(int number, EventState state) {
    _number = number;
    _state = state;
  }

  setState(EventState state) {
    _state = state;
  }

  @override
  Map toJSON() {
    return {
      'number': _number,
      'eventState': _state!.index,
    };
  }

  GeneratedParticipant fromSnapshot(Map snapshot) {
    return GeneratedParticipant(
      snapshot["startnumber"], 
      snapshot["eventState"], 
    );
  }
}

class CreatedParticipant extends Participant{
  late String _firstName;
  late String _secondName;
  late String _birthdate;
  late Sex _sex;
  String _time = "00:00:00";
  String _place = "DNS";
  String _email = "";

  CreatedParticipant(
    int number,
    Sex sex,
    String firstName,
    String secondName,
    String birthdate,
    EventState state,
    String? email,
  ) {
    _number = number;
    _sex = sex;
    _birthdate = birthdate;
    _firstName = firstName;
    _secondName = secondName;
    _state = state;
    if (email != null) {
      _email = email;
    }
  }

  String getFirstname() => _firstName;
  String getSecondname() => _secondName;
  Sex getSex() => _sex;
  String getBirthDate() => _birthdate;
  String getEmail() => _email;

  int getAge(){
    var now = DateTime.now();
    var birth = DateTime(
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

  @override
  toJSON() {
    return {
      'firstname': _firstName,
      'secondname': _secondName,
      'number': _number,
      'sex': _sex.sexToString(),
      'birthdate': _birthdate,
      'time': _time,
      'place': _place,
      'state': _state!.stateToString(),
      'email': _email
    };
  }
}
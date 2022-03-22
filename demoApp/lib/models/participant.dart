
enum EventState {
  none,
  dns,
  dnf,
  running, 
  finished,
}

extension ParseToString on EventState {
  String stateToString() {
    switch (index) {
      case 0:
        return "NONE";
      case 1:
        return "DNS";
      case 2:
        return "DNF";
      case 3:
        return "RUNNING";
      case 4:
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


class Participant{
  late String _uid;
  late String _firstName;
  late String _secondName;
  late String _birthdate;
  late Sex _sex;
  final String _time = "00:00:00";
  final String _place = "DNS";
  String _email = "";

  Participant(
    String uid, 
    Sex sex,
    String firstName,
    String secondName,
    String birthdate,
    String? email,
  ) {
    _uid = uid;
    _sex = sex;
    _birthdate = birthdate;
    _firstName = firstName;
    _secondName = secondName;
    if (email != null) {
      _email = email;
    }
  }

  String getFirstname() => _firstName;
  String getSecondname() => _secondName;
  Sex getSex() => _sex;
  String getBirthDate() => _birthdate;
  String getEmail() => _email;
  String getUID() => _uid;

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

  toJSON() {
    return {
      'firstname': _firstName,
      'secondname': _secondName,
      'sex': _sex.sexToString(),
      'birthdate': _birthdate,
      'time': _time,
      'place': _place,
      'email': _email
    };
  }

  @override
  String toString() {
    return _firstName + " " + _secondName;
  }
}
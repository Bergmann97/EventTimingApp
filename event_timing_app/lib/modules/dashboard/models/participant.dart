enum Sex {
  Male,
  Female,
  Diverse,
  None
}

extension ParseToString on Sex {
  String toJSONString() {
    return toString().split('.').last;
  }
}

class Participant {
  String _firstName = "";
  String _secondName = "";
  Sex _sex = Sex.None;
  int _age = -1;
  String _email = "";
  int _startNum = -1;
  String _time = "00:00:00";
  String _place = "DNS";

  Participant(
    String firstName, 
    String secondName, 
    Sex sex, 
    int age, 
    String? email, 
    int startNum) {
      setFirstName(firstName);
      setSecondName(secondName);
      setSex(sex);
      setAge(age);
      if (email != null) {
        setEmail(email);
      }
      setStartNum(startNum);
  }

// --------------- GETTER ---------------

  String getName() {
    return _firstName + " " + _secondName;
  }

  String getSecondName() {
    return _secondName;
  }

  Sex getSex() {
    return _sex;
  }

  int getAge() {
    return _age; 
  }

  String getEmail() {
    return _email;
  }

  int getStartNum() {
    return _startNum;
  }

  String getTime() {
    return _time;
  }

  String getPlace() {
    return _place;
  }

// --------------- SETTER ---------------

  setFirstName(String firstName) {
    _firstName = firstName;
  }

  setSecondName(String secondName) {
    _secondName = secondName;
  }

  setSex(Sex sex) {
    _sex = sex;
  }

  setAge(int age) {
    _age = age;
  }

  setEmail(String email) {
    _email = email;
  }

  setStartNum(int startNum) {
    _startNum = startNum;
  }

  setTime(String time) {
    _time = time;
  }

  setPlace(String place) {
    _place = place;
  }

// --------------- TOSTRING ---------------

  @override
  String toString() {
    // TODO: implement toString
    return _firstName + " " + _secondName + " (" + _startNum.toString() + ")";
  }

  toJSON() {
    return {
      'firstName': _firstName,
      'secondName': _secondName,
      'sex': _sex.toJSONString(),
      'age': _age,
      'email': _email,
      'startNum': _startNum,
      'time': _time,
      'place': _place,
    };
  }

}


// TODO
List<Participant> generateParticipantList(int maxNumParticipants) {
  List<Participant> participants = [];

  for (int i=1; i <= maxNumParticipants; i++) {
    participants.add(Participant("", "", Sex.None, 0, "", i));
  }

  return participants;
}
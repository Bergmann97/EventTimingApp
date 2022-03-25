import 'package:winapp/model/participant.dart';


enum EventState {
  none,
  dns,
  dnf,
  running, 
  finished,
}

extension EventStateHelper on EventState {
  String getStringState() {
    switch (this) {
      case EventState.none:
        return "NONE";
      case EventState.dns:
        return "DNS";
      case EventState.dnf:
        return "DNF";
      case EventState.running:
        return "RUNNING";
      case EventState.finished:
        return "FINISHED";
    }
  }
}

enum Sex {
  male,
  female,
  diverse,
  none
}

extension SexHelper on Sex {
  String getStringSex() {
    switch (this) {
      case Sex.none:
        return "NONE";
      case Sex.male:
        return "MALE";
      case Sex.female:
        return "FEMALE";
      case Sex.diverse:
        return "DIVERSE";
    }
  }

  String getSexLetter() {
    switch (this) {
      case Sex.none:
        return "N";
      case Sex.male:
        return "M";
      case Sex.female:
        return "F";
      case Sex.diverse:
        return "D";
    }
  }
}

int getNextAvailableNumber(List<Participant> participants) {
  List<int> numbers = participants.map((e) => e.getNumber()).toList();
  numbers.sort();
  int checker = 1;
  for (int number in numbers) {
    if (number != checker) {
      return checker;
    } else {
      checker++;
    }
  }
  if (numbers.isNotEmpty) {
    return numbers.length+1;
  } else {
    return checker;
  }
}

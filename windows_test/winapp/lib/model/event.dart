import 'package:winapp/controllers/utils.dart';
import 'package:winapp/model/participant.dart';

import 'package:flutter/material.dart';
import 'dart:developer';


class EventDate {
  String _date = '';
  String _time = '';

  EventDate(String date, String time) {
    _date = date;
    _time = time;
  }

  DateTime? getDate() {
    if (_date.isNotEmpty) {
      return DateTime(
        int.parse(_date.split('.')[2]),
        int.parse(_date.split('.')[1]),
        int.parse(_date.split('.')[0]),
      );
    } else {
      return null;
    }
  }
  TimeOfDay? getTime() {
    if (_time.isNotEmpty) {
      return TimeOfDay(
        hour: int.parse(_time.split(':')[0]),
        minute: int.parse(_time.split(':')[1]),
      );
    } else {
      return null;
    }
  }

  String getStringDate() => _date;
  String getStringTime() => _time;

  setDateFromString(String date) {
    _date = date;
  }
  setTimeFromString(String time) {
    _time = time;
  }
  setDateAndTimeFromDateTime(DateTime date) {
    _date = date.day.toString() + '.' + 
            date.month.toString() + '.' + 
            date.year.toString();
    _time = date.hour.toString() + ':' +
            date.minute.toString() + ':' +
            date.second.toString();
  }

  @override
  String toString() {
    return _date + ' ' + _time;
  }

  Map<String, dynamic> toJSON() {
    return {
      'date': getStringDate(),
      'time': getStringTime(),
    };
  }
}


class Event {
  String _eid                 = '';
  String _cid                 = '';
  String _title               = '';
  bool _started               = false;
  bool _finished              = false;
  bool _generatedParticipants = true;
  int _maxNumParticipants     = 0;
  List<Participant> _participants = [];
  final List<ResultParticipant> _result = [];

  EventDate _planedStartDate  = EventDate('', '');
  EventDate _endDate          = EventDate('', '');
  EventDate _startDate        = EventDate('', '');
  EventDate _finishedDate     = EventDate('', '');

  Event(
    String eid,
    String cid,
    String title,
    int maxNumParticipants,
    List<Participant> participants,
    EventDate planedStartDate,
    EventDate endDate,
    bool generatedParticipants
  ) {
    _eid = eid;
    _cid = cid;
    _title = title;
    _maxNumParticipants = maxNumParticipants;
    _participants = participants;
    _planedStartDate = planedStartDate;
    _endDate = endDate;
    _generatedParticipants = generatedParticipants;
    if (generatedParticipants) {
      for (int i = 0; i < maxNumParticipants; i++) {
        _participants.add(
          Participant(
            i+1, 
            EventState.none, 
            ''
          )
        );
      }
    }
  }

  String getEID() => _eid;
  String getCID() => _cid;
  String getTitle() => _title;
  List<ResultParticipant> getResult() => _result;
  bool hasStarted() => _started;
  bool isFinished() => _finished;
  bool hasGeneratedParticipants() => _generatedParticipants;
  int getMaxNumParticipants() => _maxNumParticipants;
  List<Participant> getParticipants() => _participants;
  EventDate getPlanedStartDate() => _planedStartDate;
  EventDate getEndDate() => _endDate;
  EventDate getStartDate() => _startDate;
  EventDate getFinishedDate() => _finishedDate;

  setEID(String eid) {
    _eid = eid;
  }
  setCID(String cid) {
    _cid = cid;
  }
  setTitle(String title) {
    _title = title;
  }
  setStarted() {
    _started = true;
  }
  setFinished() {
    _finished = true;
  }
  setMaxNumParticipants(int maxNumParticipants) {
    _maxNumParticipants = maxNumParticipants;
  }
  setGeneratedParticipants(bool generatedParticipants) {
    _generatedParticipants = generatedParticipants;
  }

  addParticipant(CreatedParticipant participant) {
    if (_participants.length < _maxNumParticipants && !_generatedParticipants && !_started) {
      if (!_participants.any((element) => element.getPID() == participant.getPID())) {
        _participants.add(
          Participant(
            getNextAvailableNumber(_participants),
            EventState.none, 
            participant.getPID(),
          )
        );
        participant.addEvent(_eid);
      } else {
        log('Participant with pid: ' + participant.getPID() + ' already exists in event');
      }
    } else {
      log('You cannot add more Participants or its an event with generated participants or the event already started!');
    }
  }
  addParticipants(List<CreatedParticipant> participants) {
    if (!_generatedParticipants) {
      for (CreatedParticipant participant in participants) {
        addParticipant(participant);
      }
    } else {
      log('The event has generated Participants! You cannot add some manually!');
    }
  }
  removeParticipant(CreatedParticipant participant) {
    if (_participants.any((element) => element.getPID() == participant.getPID()) && !_started) {
      _participants.removeWhere((element) => element.getPID() == participant.getPID());
      participant.removeEvent(_eid);
    } else {
      log('There was no Participant with pid: ' + participant.getPID() + ' or the event already started!');
    }
  }
  removeParticipants(List<CreatedParticipant> participants) {
    for (CreatedParticipant participant in participants) {
      removeParticipant(participant);
    }
  }

  addResult(ResultParticipant result) {
    if (_result.length < _participants.length && _started) {
      if (!_result.contains(result)) {
        _result.add(result);
      } else {{
        log('The Participant was already in Result-List!');
      }}
    } else {
      log('The Result list has already as many results as number of participants');
    }
  }
  addResults(List<ResultParticipant> results) {
    if (_started) {
      for (ResultParticipant result in results) {
        addResult(result);
      }
    } else {
      log('The Event did not start yet!');
    }
  }

  setPlanedStartDate(EventDate planedStartDate) {
    _planedStartDate = planedStartDate;
  }
  setStartDate(EventDate startDate) {
    _startDate = startDate;
  }
  setEndDate(EventDate endDate) {
    _endDate = endDate;
  }
  setFinishedDate(EventDate finishedDate) {
    _finishedDate = finishedDate;
  }

  @override
  String toString() {
    return _title +  '(' + _planedStartDate.toString() + ')';    
  }

  Map<String, dynamic> toJSON() {
    return {
      'eid': _eid,
      'cid': _cid,
      'title': _title,
      'planedStartDate': _planedStartDate.toJSON(),
      'endDate': _endDate.toJSON(),
      'startDate': _startDate.toJSON(),
      'finishedDate': _finishedDate.toJSON(),
      'started': _started,
      'finished': _finished,
      'maxNumParticipants': _maxNumParticipants,
      'participants': _participants.map((e) => e.toJSON()).toList(),
      'result': _result.map((e) => e.toJSON()).toList(),
      'generatedParticipants': _generatedParticipants,
    };
  }
}

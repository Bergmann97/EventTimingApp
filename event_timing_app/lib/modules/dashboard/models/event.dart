
import 'package:event_timing_app/modules/dashboard/models/participant.dart';
import 'package:flutter/material.dart';

class Event {
  String _ownerID = "";
  String _name = "";
  String _startDate = "01.01.1900";
  String _endDate = "01.01.1900";
  int _maxNumParticipants  = -1;
  List<Participant> _participants = [];
  TimeOfDay _startTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay? _endTime;
  bool _generatedParticipants = false;

  // TODO add participants
  // TODO add started

  Event(
    String ownerId, 
    String name,
    String startDate,
    String endDate,
    int maxNumParticipants,
    bool generatedParticipants) {
      _ownerID = ownerId;
      _name = name;
      _startDate = startDate;
      _endDate = endDate;
      _maxNumParticipants = maxNumParticipants;
      _generatedParticipants = generatedParticipants;
  }

// --------------- GETTER ---------------

  String getOwner() {
    return _ownerID;
  }

  String getName() {
    return _name;
  }

  String getStartDate() {
    return _startDate;
  }

  String getEndDate() {
    return _endDate;
  }

  int getMaxNumParticipants() {
    return _maxNumParticipants;
  }

  List<Participant> getParticipants()  {
    return _participants;
  }

  String getStartTime(context) {
    return _startTime.format(context);
  }

  String getEndTime(context) {
    if (_endTime != null) {
      return _endTime!.format(context);
    } else {
      return "";
    }
  }

  bool hasGeneratedStartNum() {
    return _generatedParticipants;
  }

// --------------- SETTER ---------------

  setName(String name) {
    _name = name;
  }

  setStartDate(String date) {
    _startDate = date;
  }

  setEndDate(String date) {
    _endDate = date;
  }

  setmaxNumParticipants(int maxNumParticipants) {
    _maxNumParticipants = maxNumParticipants;
  }

  setStartTime(TimeOfDay startTime) {
    _startTime = startTime;
  }

  setEndTime(TimeOfDay endTime) {
    _endTime = endTime;
  }

// --------------- ADDER/REMOVER ---------------

  addParticipant(Participant participant) {
    _participants.add(participant);
  }

  addParticipants(List<Participant> participants) {
    for (int i = 0; i < participants.length; i++) {
      addParticipant(participants[i]);
    }
  }

  removeParticipant(Participant participant) {
    _participants.remove(participant);
  }

// --------------- TOSTRING ---------------

  @override
  String toString() {
    return "Event '" + _name + "' from UID: " + _ownerID + "! Starting " + _startDate;
  }

  toJSON() {
    return {
      'name': _name,
      'ownerID': _ownerID,
      'startDate': _startDate,
      'endDate': _endDate,
      'startTime': _startTime,
      'endTime': _endTime,
      'maxNumParticipants': _maxNumParticipants,
      'generatedParticipants': _generatedParticipants
    };
  }

}
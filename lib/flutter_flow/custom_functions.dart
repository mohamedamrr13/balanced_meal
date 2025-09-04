import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

bool? disableButton(
  String? gender,
  String? age,
  String? height,
  String? weight,
) {
  return gender == null ||
      gender.trim().isEmpty ||
      age == null ||
      age.trim().isEmpty ||
      height == null ||
      height.trim().isEmpty ||
      weight == null ||
      weight.trim().isEmpty;
}

int calculateCalories(
  String gender,
  double weight,
  double height,
  double age,
) {
  if (gender.toLowerCase() == 'female') {
    return (655.1 + (9.56 * weight) + (1.85 * height) - (4.67 * age)).toInt();
  } else {
    return (666.47 + (13.75 * weight) + (5 * height) - (6.75 * age)).toInt();
  }
}

// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> apiCall() async {
  try {
    final cartSnapshot =
        await FirebaseFirestore.instance.collection('cart').get();

    final items = cartSnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "name": data['food_name'] ?? data['name'] ?? 'Unnamed',
        "total_price": (data['price'] ?? 0) * (data['quantity'] ?? 1),
        "quantity": data['quantity'] ?? 1,
      };
    }).toList();

    final payload = {
      "items": items,
    };

    final response = await http.post(
      Uri.parse('https://uz8if7.buildship.run/placeOrder'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print(" Sent: ${jsonEncode(payload)}");
    print(" Response: ${response.statusCode} → ${response.body}");

    return response.statusCode == 200 && response.body.contains("true");
  } catch (e) {
    print(" API Error: $e");
    return false;
  }
}

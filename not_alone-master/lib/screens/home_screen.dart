import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';
import 'package:not_alone/model/nearby_response.dart' hide Location;

import 'package:http/http.dart' as http;

import 'package:flutter_sms/flutter_sms.dart';
import 'package:not_alone/screens/welcome_screen.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location location = Location();
  late LocationData locationData;
  String _address = '';
  double? latitude = 0;
  double? longitude = 0;
  bool showAddress = false;

  void getLocation() async {
    try {
      locationData = await location.getLocation();

      double? lat = locationData.latitude;
      double? long = locationData.longitude;

      setState(() {
        latitude = lat;
        longitude = long;
      });

      List<Placemark> placeMark = await placemarkFromCoordinates(lat!, long!);

      Placemark place = placeMark[0];

      _address =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  getNearbyPlacesContacts(double latitude, double longitude) async {
    String apiKey = "";
    String radius = "10000";

    // Use nearby-search to get the list of nearby places based on the latitude and longitude
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&keyword=hotel&key=$apiKey');

    var response = await http.post(url);

    NearbyPlacesResponse nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));

    // Extract the place_id from the response
    List<String> placeIds = [];
    nearbyPlacesResponse.results?.forEach((element) {
      placeIds.add(element.placeId.toString());
    });

    List<String> phoneNumbers = [];

    // Loop all place_ids to get the contact details of the places
    for (int i = 0; i < placeIds.length; i++) {
      var url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeIds[i]}&key=$apiKey');

      var response = await http.post(url);

      // Parse the response body into a JSON object
      var data = jsonDecode(response.body);

      if (data.containsKey('result') &&
          data['result'].containsKey('formatted_phone_number')) {
        // Access the formatted_phone_number
        var contact = data['result']['formatted_phone_number'];

        log(contact);

        phoneNumbers.add(contact);
      } else {
        log("No contact found");
      }
    }

    // Send the phone numbers to the messageThePhoneNumbers function
    // Using test phone numbers when in debug mode
    messageThePhoneNumbers(
        isInDebugMode ? ["7877944392"] : phoneNumbers, latitude, longitude);

    setState(() {});
  }

  messageThePhoneNumbers(
      List<String> phoneNumbers, double latitude, double longitude) async {
    // Use the phoneNumbers list to send messages to the nearby places

    // Clean the phone numbers list such as remove all non numeric characters and
    // spaces from the phone numbers.
    phoneNumbers = phoneNumbers.map((e) {
      return e.replaceAll(RegExp(r'[^0-9]'), '');
    }).toList();

    String message =
        "This is an emergency! My location https://maps.google.com/maps?q=$latitude,$longitude";
    List<String> recipents = phoneNumbers;

    try {
      String result = await sendSMS(
          message: message, recipients: recipents, sendDirect: true);
      log(result);
    } catch (error) {
      log(error.toString());
    }
  }

  requestSMSPermission() async {
    var status = await permission_handler.Permission.sms.status;
    if (status.isDenied) {
      await permission_handler.Permission.sms.request();
    } else if (status.isPermanentlyDenied) {
      await permission_handler.openAppSettings();
    }
  }

  requestLocationPermission() async {
    var status = await permission_handler.Permission.location.status;
    if (status.isDenied) {
      await permission_handler.Permission.location.request();
    } else if (status.isPermanentlyDenied) {
      await permission_handler.openAppSettings();
    }
  }

  requestPermissions() async {
    await requestSMSPermission();
    await requestLocationPermission();
    getLocation();
  }

  @override
  void initState() {
    requestPermissions();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // firebase logout button
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'Send Emergency Message',
                  style: TextStyle(
                    // color: Colors.white,
                    fontFamily: 'Montserrat-Bold',
                    fontSize: 35,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: latitude != null && longitude != null
                    ? () {
                        try {
                          FirebaseFirestore.instance
                              .collection('User')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .collection('locations')
                              .add({
                            'address': _address,
                            'time': FieldValue.serverTimestamp(),
                          });

                          getNearbyPlacesContacts(latitude!, longitude!);
                        } catch (e) {
                          log(e.toString());
                        }
                        setState(() {
                          showAddress = true;
                        });
                      }
                    : null,
                child: const Text(
                  'Help',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Visibility(
                visible: showAddress,
                child: Column(
                  children: [
                    Text(_address),
                    Text('Latitude: $latitude, Longitude: $longitude'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

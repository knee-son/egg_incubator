import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Database Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Egg Monitoring and Candling'),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              StreamBuilder<DocumentSnapshot>(
                stream: db.collection('data').doc('camera').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  try {
                    final storageRef = FirebaseStorage.instance.ref();
                    const filesize = 15 * 1024 * 1024;
                    var data = snapshot.data?.data() as Map<String, dynamic>;
                    final imageReference = storageRef.child(data['filename']);

                    return FutureBuilder<Uint8List?>(
                      future: imageReference.getData(filesize),
                      builder: (context, imageDataSnapshot) {
                        if (imageDataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (imageDataSnapshot.hasError) {
                          return Text(
                              'Error fetching image: ${imageDataSnapshot.error}');
                        }
                        Uint8List? imageData = imageDataSnapshot.data;

                        if (imageData != null) {
                          return Column(
                            children: <Widget>[
                              Image.memory(imageData),
                              Text('file name: ${data['filename']}'),
                            ],
                          );
                        } else {
                          return const Text('Error: No image data found');
                        }
                      },
                    );
                  } on FirebaseException catch (e) {
                    // Handle specific storage errors (e.g., StorageException)
                    return Text('Firebase error: ${e.message}');
                  }
                },
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: db.collection('data').doc('sensor').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  var data = snapshot.data?.data() as Map<String, dynamic>;
                  if (data['message'] == '') {
                    data['message'] = 'DHT sensor is working fine.';
                  }

                  DateTime time = (data['time'] as Timestamp).toDate();
                  String formattedTime =
                      DateFormat('MMMM d, h:mm:ss a').format(time);

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(children: <Widget>[
                            Text(
                                'Humidity: ${data['humidity'].toStringAsFixed(4)}%'),
                            Text(
                                'Temperature: ${data['temperature'].toStringAsFixed(4)}°C'),
                            Text('Time of retrieval: $formattedTime'),
                            Text('Message: ${data['message']}'),
                          ])),
                    ],
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  db
                      .collection("data")
                      .doc("camera")
                      .update({"capturing": true});
                },
                child: const Text('click to candle eggs'),
              ),
            ])));
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart'; // Import the intl package

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
        title: const Text('Firebase Database Implementation'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: db.collection('data').doc('mydata').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var data = snapshot.data?.data() as Map<String, dynamic>;
          if(data['message']=='') {
            data['message']='DHT sensor is working fine.';
          }
          DateTime time = (data['time'] as Timestamp).toDate();
          String formattedTime = DateFormat('MMMM d, h:mm:ss a').format(time);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Humidity: ${data['humidity']}%'),
                Text('Temperature: ${data['temperature']}°C'),
                Text('Time of retrieval: $formattedTime'),
                Text('Message: ${data['message']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

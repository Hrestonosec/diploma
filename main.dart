import 'package:diplom/tracking_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const TrackingScreen(),
    );
  }
}

/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
*/
/*final ph = PermissionHandler();
final requested = await ph.requestPermissions([
PermissionGroup.locationAlways,
PermissionGroup.locationWhenInUse
]);

final alwaysGranted = requested[PermissionGroup.locationAlways] == PermissionStatus.granted;
final whenInUseGranted = requested[PermissionGroup.locationWhenInUse] == PermissionStatus.granted;*//*


Future<bool> requestTrackingPermission() async {
  PermissionStatus result;
  result = await Permission.locationAlways.request();
  if (result.isGranted) {
    return true;
  }
  return false;
}



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late LatLng currentLatLng = const LatLng(48.8566, 2.3522);
  final Completer<GoogleMapController> _controller = Completer();

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
    return;
  }

  @override
  void initState() {
    super.initState();
  }

  late Set<Circle> _circles = {
    Circle(
      circleId: CircleId(
        'myCircle',
      ),
      center: LatLng(
        48.8566,
        2.3522,
      ),
      radius: 1500,
      fillColor: Colors.red.withOpacity(.25),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
  };

  @override
  Widget build(BuildContext context) {
    print("Current Location --------> " + currentLatLng.latitude.toString() + " " + currentLatLng.longitude.toString());
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(target: currentLatLng, zoom: 5),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          circles: _circles,
          markers: <Marker>{
            Marker(
              draggable: true,
              markerId: const MarkerId("1"),
              position: currentLatLng,
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: const InfoWindow(
                title: 'My Location',
              ),
            ),
            Marker(
              draggable: true,
              markerId: const MarkerId("1"),
              position: currentLatLng,
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: const InfoWindow(
                title: 'My Location',
              ),
            ),
          },
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToCurrentLocation,
          label: const Text('Home'),
          icon: const Icon(Icons.home),
        ),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: currentLatLng, zoom: 3)));
  }
}*/

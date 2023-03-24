import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:location/location.dart';
import 'dart:math';

import 'package:diplom/tracking_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with WidgetsBindingObserver {
  late final TrackingModel _model;
  bool _detectPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _model = TrackingModel();
    _checkPermissionsAndPick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // This block of code is used in the event that the user
  // has denied the permission forever. Detects if the permission
  // has been granted when the user returns from the
  // permission system screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _detectPermission &&
        (_model.trackingSection == TrackingSection.noTrackingPermissionPermanent)) {
      _detectPermission = false;
      _model.requestLocationPermission();
    } else if (state == AppLifecycleState.paused &&
        _model.trackingSection == TrackingSection.noTrackingPermissionPermanent) {
      _detectPermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<TrackingModel>(
        builder: (context, model, child) {
          Widget widget;

          switch (model.trackingSection) {
            case TrackingSection.noTrackingPermission:
              widget = TrackingPermissions(
                  isPermanent: false, onPressed: _checkPermissionsAndPick);
              break;
            case TrackingSection.noTrackingPermissionPermanent:
              widget = TrackingPermissions(
                  isPermanent: true, onPressed: _checkPermissionsAndPick);
              break;
            case TrackingSection.trackingStarted:
              widget = TrackingStarted(title: '');
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Handle permissions'),
            ),
            body: widget,
          );
        },
      ),
    );
  }

  /// Check if the pick file permission is granted,
  /// if it's not granted then request it.
  /// If it's granted then invoke the file picker
  Future<void> _checkPermissionsAndPick() async {
    final hasLocationPermission = await _model.requestLocationPermission();
    if (hasLocationPermission) {
      try {
        await _model.startTracking();
      } on Exception catch (e) {
        debugPrint('Error when picking a file: $e');
        // Show an error to the user if the pick file failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred when picking a file'),
          ),
        );
      }
    }
  }
}

/// This widget will serve to inform the user in
/// case the permission has been denied. There is a
/// variable [isPermanent] to indicate whether the
/// permission has been denied forever or not.
class TrackingPermissions extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const TrackingPermissions({
    Key? key,
    required this.isPermanent,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              'Read files permission',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'We need to request your permission to read '
                  'local files in order to load it in the app.',
              textAlign: TextAlign.center,
            ),
          ),
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'You need to give this permission from the system settings.',
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
                left: 16.0, top: 24.0, right: 16.0, bottom: 24.0),
            child: ElevatedButton(
              child: Text(isPermanent ? 'Open settings' : 'Allow access'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}

/// This widget is used once the permission has
/// been granted and a file has been selected.
/// Load the Tracking and display it in the center.
class TrackingStarted extends StatefulWidget {
  const TrackingStarted({Key? key, required this.title,}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TrackingStarted> createState() => _TrackingStartedState();
}

class _TrackingStartedState extends State<TrackingStarted> {

  AudioPlayer player = AudioPlayer();
  int maxduration = 100;
  int currentpos = 0;
  String currentpostlabel = "00:00";
  bool isplaying = false;
  bool audioplayed = false;
  LocationData? currentLocation;
  Map<String, List<double>> succesfullLocation = {};
  Map<String, List<double>> waitingLocation = {"google":[37.4219986, -122.0839998],"home":[47.654765, 33.897735],"stepova":[47.655042, 33.898345],"road":[47.655495, 33.898199],"peace":[47.655495, 33.897468]};
  Map<String,String> locations = {"google":"hahahaha it's google","home":"it's home","stepova":"it's stepova","road":"it's road","peace":"it's peace"};



  void getCurrentLocation() async {

    Location location = Location();
    location.changeSettings(interval: 5000);
    location.getLocation().then((location) {
      currentLocation = location;
      setState(() {
      });
    },);
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
          (newLoc) async{
            currentLocation = newLoc;

            for (var item in waitingLocation.entries) {
              if (!accessStart(newLoc.latitude, newLoc.longitude))
                break;
              if (pow(newLoc.latitude! - item.value[0], 2) + pow(newLoc.longitude! - item.value[1], 2) <= pow(0.0001794000000003848, 2)){
                _showToast(locations[item.key]);
                player.pause();
                await player.play(UrlSource('http://audioguide.great-site.net/all%20good.mp3'));
                succesfullLocation[item.key] = item.value;
                break;
              }
            }
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 20,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }
  late LatLng currentLatLng = const LatLng(48.8566, 2.3522);
  final Completer<GoogleMapController> _controller = Completer();

  bool accessStart(double? lat, double? long){
    for (var item in succesfullLocation.entries) {
      if (succesfullLocation.isNotEmpty){
        if (pow(lat! - item.value[0], 2) + pow(long! - item.value[1], 2) <= pow(0.0001794000000003848, 2)){
          return false;
        }
      }
    }
    return true;
  }
  Future<void> _determinePosition() async {

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
    });
    return;
  }
  void _showToast(String? message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message!),
        action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  late Set<Circle> _circles = {
    Circle(
      circleId: CircleId(
        'home',
      ),
      center: LatLng(
        47.654765,
        33.897735,
      ),
      radius: 20,
      fillColor: Colors.red.withOpacity(.25),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
    Circle(
      circleId: CircleId(
        'peace',
      ),
      center: LatLng(
        47.655495,
        33.897468,
      ),
      radius: 20,
      fillColor: Colors.red.withOpacity(.25),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
    Circle(
      circleId: CircleId(
        'road',
      ),
      center: LatLng(
        47.655495,
        33.898199,
      ),
      radius: 20,
      fillColor: Colors.red.withOpacity(.25),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
    Circle(
      circleId: CircleId(
        'stepova',
      ),
      center: LatLng(
        47.655042,
        33.898345,
      ),
      radius: 20,
      fillColor: Colors.red.withOpacity(.25),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
    Circle(
      circleId: CircleId(
        'google',
      ),
      center: LatLng(
        37.4219986,
        -122.0839998,
      ),
      radius: 20,
      fillColor: Colors.red.withOpacity(.25),
      strokeColor: Colors.red,
      strokeWidth: 2,
    ),
  };
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: currentLocation == null
            ? const Center(child: Text("Loading"))
            : Container(
            margin: EdgeInsets.only(top:50),
            child: Column(
              children: [

                Container(
                  child: Text(currentpostlabel, style: TextStyle(fontSize: 25),),
                ),

                Container(
                    child: Slider(
                      value: double.parse(currentpos.toString()),
                      min: 0,
                      max: double.parse(maxduration.toString()),
                      divisions: maxduration,
                      label: currentpostlabel,
                      onChanged: (double value) async {
                        int seekval = value.round();
                        int result = await player.seek(Duration(milliseconds: seekval));
                        if(result == 1){ //seek successful
                          currentpos = seekval;
                        }else{
                          print("Seek unsuccessful.");
                        }
                      },
                    )
                ),

                Container(
                  child: Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            if(!isplaying && !audioplayed){
                              int result = await player.playBytes(audiobytes);
                              if(result == 1){ //play success
                                setState(() {
                                  isplaying = true;
                                  audioplayed = true;
                                });
                              }else{
                                print("Error while playing audio.");
                              }
                            }else if(audioplayed && !isplaying){
                              int result = await player.resume();
                              if(result == 1){ //resume success
                                setState(() {
                                  isplaying = true;
                                  audioplayed = true;
                                });
                              }else{
                                print("Error on resume audio.");
                              }
                            }else{
                              int result = await player.pause();
                              if(result == 1){ //pause success
                                setState(() {
                                  isplaying = false;
                                });
                              }else{
                                print("Error on pause audio.");
                              }
                            }
                          },
                          icon: Icon(isplaying?Icons.pause:Icons.play_arrow),
                          label:Text(isplaying?"Pause":"Play")
                      ),

                      ElevatedButton.icon(
                          onPressed: () async {
                            int result = await player.stop();
                            if(result == 1){ //stop success
                              setState(() {
                                isplaying = false;
                                audioplayed = false;
                                currentpos = 0;
                              });
                            }else{
                              print("Error on stop audio.");
                            }
                          },
                          icon: Icon(Icons.stop),
                          label:Text("Stop")
                      ),
                    ],
                  ),
                ),
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(target: currentLatLng, zoom: 15),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  circles: _circles,
                  markers: <Marker>{
                    Marker(
                      draggable: true,
                      markerId: const MarkerId("google"),
                      position: LatLng(37.654764, -121.654764),
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                    Marker(
                      draggable: true,
                      markerId: const MarkerId("google"),
                      position: LatLng(37.422007570000005, -122.0839998),
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: LatLng(
                          currentLocation!.latitude!, currentLocation!.longitude!),
                      infoWindow: const InfoWindow(
                        title: 'My Location',
                      ),
                    ),
                  },
                ),
              ],
            )

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
}
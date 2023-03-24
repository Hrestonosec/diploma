import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// This enum will manage the overall state of the app
enum TrackingSection {
  noTrackingPermission, // Permission denied, but not forever
  noTrackingPermissionPermanent, // Permission denied forever
  //allowTracking, // The UI shows the button to pick files
  trackingStarted, // File picked and shown in the screen
}

class TrackingModel extends ChangeNotifier {
  TrackingSection _trackingSection = TrackingSection.trackingStarted;

  TrackingSection get trackingSection => _trackingSection;

  set trackingSection(TrackingSection value) {
    if (value != _trackingSection) {
      _trackingSection = value;
      notifyListeners();
    }
  }

  /// Request the files permission and updates the UI accordingly
  Future<bool> requestLocationPermission() async {
    PermissionStatus result;
    // In Android we need to request the storage permission,
    // while in iOS is the photos permission
      result = await Permission.location.request();


    if (result.isGranted) {
      trackingSection = TrackingSection.trackingStarted;
      return true;
    } else if (Platform.isIOS || result.isPermanentlyDenied) {
      trackingSection = TrackingSection.noTrackingPermissionPermanent;
    } else {
      trackingSection = TrackingSection.noTrackingPermission;
    }
    return false;
  }

  /// Invoke the file picker
  Future<void> startTracking() async {
    trackingSection = TrackingSection.trackingStarted;
  }
}
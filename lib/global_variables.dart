import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dataModels/User1.dart';

String mapKey = 'AIzaSyD6S8Rfq4Sr4FW0lvWUwj5KDbIeD_sYBeo';

 final CameraPosition Plex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);

User currentUser;

User1 currentUserInfo;
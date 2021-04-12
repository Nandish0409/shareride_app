
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shareride_app/DataProvider/appData.dart';
import 'package:shareride_app/dataModels/User1.dart';
import 'package:shareride_app/dataModels/address.dart';
import 'package:shareride_app/dataModels/directionDetails.dart';
import 'package:shareride_app/global_variables.dart';
import 'package:shareride_app/helper/Network_Request.dart';
import 'package:provider/provider.dart';

class HelperMethods{

  static void getCurrentUserInfo() async {

    currentUser = await FirebaseAuth.instance.currentUser;
    String userID = currentUser.uid;

    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/$userID');
    userRef.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){
         currentUserInfo = User1.fromSnapshot(snapshot);
      }
    });
  }

  static Future<String> findCordinateAddress(Position position, context) async {

    String placeAddress;


    var connectivityResult =  await Connectivity().checkConnectivity();
    if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
      return placeAddress;
    }

    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapKey}';

    var response = await RequestHelper.getRequest(url);
    print(response);

    if(response != 'failed'){

      placeAddress = response['results'][0]['formatted_address'];

      Address pickupAddress = new Address();
      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;
      print(placeAddress);

      Provider.of<AppData>(context, listen: false).updatePickupAddress(pickupAddress);
    }
  }

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {

    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if(response == 'failed'){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];
    return directionDetails;
  }

  static int estimateFares(DirectionDetails details)  {
    if (details != null) {
      double base = 50;
      double distanceFare = (details.distanceValue / 1000) * 5.5;
      double timeFare = (details.durationValue / 60) * 2.5;

      double totalFare = base + distanceFare + timeFare;
      print(totalFare);
      return totalFare.truncate();
    }
    else {
      print('error in price method');
      return 0;
    }
  }


}
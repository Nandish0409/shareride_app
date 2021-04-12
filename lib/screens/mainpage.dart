
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:shareride_app/DataProvider/appData.dart';
import 'package:shareride_app/dataModels/directionDetails.dart';
import 'package:shareride_app/design_resource/app_colors.dart';
import 'package:shareride_app/design_resource/styles/styles.dart';
import 'package:shareride_app/design_resource/widget/AppDivider.dart';
import 'package:shareride_app/design_resource/widget/App_Button2.dart';
import 'package:shareride_app/global_variables.dart';
import 'package:shareride_app/helper/Network_Helper.dart';
import 'package:shareride_app/screens/searchPage.dart';


class MainPage extends StatefulWidget {

  static const String id = 'main';
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();
  double searchSheetHeight = (Platform.isIOS) ? 300:275;
  double rideDetails = 0;
  double requestingHeight = 0; // 195:260


  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapButtonPadding = 0;
  String mapStyle;

  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> _polyline = {};
  Set<Marker> _marker = {};
  Set<Circle> _circle = {};

  Position currentPosition;
  LatLng currentPosition1;

  DirectionDetails tripDirectionDetails;

  bool openDrawer = true;

  DatabaseReference rideRef;

  void setPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;

    LatLng pos = LatLng(position.latitude, position.longitude);

    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));


    String address = await HelperMethods.findCordinateAddress(position, context);
  }

  void showDetailSheet() async {

    await getDirection();
    setState(() {

    searchSheetHeight = 0;
    rideDetails = (Platform.isAndroid) ? 235 : 260;
    mapButtonPadding = (Platform.isAndroid) ?235 : 295;
    openDrawer = false;
    });
  }

  void showRequestingSheet(){
    setState(() {
      rideDetails = 0;
      requestingHeight = (Platform.isAndroid) ? 195 : 220;
      mapButtonPadding = (Platform.isAndroid) ? 195 : 250;

      openDrawer = true;
    });

    createRideRequest();
  }

  @override
  void initState(){
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    rootBundle.loadString('_mapStyle.txt').then((string) {
      mapStyle = string;
    });
    return Scaffold(
      key: scaffoldkey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[
              Container(
                color: Colors.white,
                height: 160,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset('images/user_icon.png', height: 60, width: 60,),
                      SizedBox(width: 15,),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Nandish Trivedi',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Brand-Bold',
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text('View Profile'),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              AppDivider(),

              SizedBox(height: 10,),

              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text('Free Rides',
                  style: DrawerItemStyle,
                ),
              ),

              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text('Payments',
                  style: DrawerItemStyle,
                ),
              ),

              ListTile(
                leading: Icon(OMIcons.history),
                title: Text('Past Rides',
                  style: DrawerItemStyle,
                ),
              ),

              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text('Support',
                  style: DrawerItemStyle,
                ),
              ),

              ListTile(
            leading: Icon(OMIcons.info),
            title: Text('About',
              style: DrawerItemStyle,
               ),
              )
            ],
          ),
        ),
      ),
      body:Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapButtonPadding),
            mapType: MapType.normal,

            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            polylines: _polyline,
            markers: _marker,
            circles: _circle,
            initialCameraPosition: Plex,
            onMapCreated: (GoogleMapController cotroller) {
              _controller.complete(cotroller);
              mapController = cotroller;
              mapController.setMapStyle(mapStyle);

              setState(() {
                mapButtonPadding = (Platform.isAndroid)? 275 : 295;
              });
              setPositionLocator();
            },
          ),

          //Drawer Button
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: (){
                if(openDrawer) {
                  scaffoldkey.currentState.openDrawer();
                }
                else{
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7
                      )
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon((openDrawer)?Icons.menu : Icons.arrow_back, color: Colors.black87,),
                ),
              ),
            ),
          ),

          //Search Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchSheetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)
                  ),
                ),
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 5,),
                      Text('Nice To See You',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text('Want To Go Somewhere?',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Brand-Bold'
                        ),
                      ),
                      SizedBox(height: 20,),

                      GestureDetector (
                        onTap: () async {
                          var response = await Navigator.push(context, MaterialPageRoute(
                              builder: (context)=> SearchPage()
                          ));

                          if(response == 'getDirection'){
                            showDetailSheet();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                )
                              )
                            ]
                          ),
                          child: Padding(
                            padding:  EdgeInsets.all(12.0),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                    Icons.search,
                                    color: Colors.blueAccent,
                                ),
                                SizedBox(width: 18,),
                                Text('Where to?'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                OMIcons.home,
                                color: AppColors.colorDimText,
                              ),
                              SizedBox(width: 12,),
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text((Provider.of<AppData>(context).pickupAddress != null)
                                  ?Provider.of<AppData>(context).pickupAddress.placeName
                                  : 'Add Home',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                     SizedBox(height: 3,),
                                    Text('Residential Address',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.colorDimText,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),


                      AppDivider(),

                      SizedBox(height: 20,),

                      Row(
                        children: <Widget>[
                          Icon(
                            OMIcons.workOutline,
                            color: AppColors.colorDimText,
                          ),
                          SizedBox(width: 12,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Add Work'),
                              SizedBox(height: 3,),
                              Text('Work Address',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.colorDimText,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    )
                  ],
                ),
                height: rideDetails,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        color: AppColors.colorAccent1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              Image.asset('images/taxi.png', height: 70, width: 70,),
                              SizedBox(width: 16,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('SmallCar', style: TextStyle(fontSize: 18,fontFamily: 'Bran-Bold'),),
                                  Text((tripDirectionDetails != null)?tripDirectionDetails.distanceText:'', style: TextStyle(fontSize: 16, color:  AppColors.colorTextLight),)
                                ],
                              ),
                              Expanded(child: Container(),),
                              Text((tripDirectionDetails != null) ? '\₹${HelperMethods.estimateFares(tripDirectionDetails)}' : '', style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 22,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.moneyBillAlt,size: 18,color: AppColors.colorTextLight,),
                            SizedBox(width: 16,),
                            Text('Cash'),
                            SizedBox(width: 5,),
                            Icon(Icons.keyboard_arrow_down, color: AppColors.colorTextLight, size: 16,),
                          ],
                        ),
                      ),

                      SizedBox(height: 22,),

                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 16),
                        child: AppButton1(
                          title: 'CONFIRM BOOKING',
                          color: Colors.black87,
                          onPressed: (){
                            showRequestingSheet();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:  BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)
                  ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          )
                      )
                    ]
                ),
                height: requestingHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24,vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      SizedBox(height: 10,),

                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting A Ride',
                          waveColor: AppColors.colorTextLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Brand-Bold'
                          ),
                          boxHeight: 40.0,
                        ),
                      ),

                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: (){
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1.0, color: AppColors.colorLightGrayFair),
                          ),
                          child: Icon(Icons.close, size: 25,),
                        ),
                      ),

                      SizedBox(height: 10,),

                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel Ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection() async {

    var pickUp = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickUp.latitude, pickUp.longitude);
    var destLatLng = LatLng(destination.latitude, destination.longitude);

    var thisRideDetails = await HelperMethods.getDirectionDetails(pickLatLng, destLatLng);
    print(thisRideDetails.distanceValue);

    setState(() {
      tripDirectionDetails = thisRideDetails;
    });

    print(tripDirectionDetails.distanceValue);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisRideDetails.encodedPoints);

    polyLineCoordinates.clear();

    if(results.isNotEmpty){
      results.forEach((PointLatLng point) {
        polyLineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polyline.clear();

    setState(() {
    Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Colors.black87,
      points: polyLineCoordinates,
      jointType: JointType.mitered,
      width: 4,
      startCap: Cap.squareCap,
      endCap: Cap.squareCap,
      geodesic: true,
    );

      _polyline.add(polyline);
    });

    LatLngBounds bounds;

    if(pickLatLng.latitude > destLatLng.latitude && pickLatLng.longitude > destLatLng.longitude){
      bounds = LatLngBounds(southwest: destLatLng, northeast:  pickLatLng);
    }

    else if(pickLatLng.longitude > destLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(pickLatLng.latitude, destLatLng.longitude),
        northeast: LatLng(destLatLng.latitude, pickLatLng.longitude),
      );
    }
    else if(pickLatLng.latitude > destLatLng.latitude){
      bounds = LatLngBounds(
        southwest: LatLng(destLatLng.latitude, pickLatLng.longitude),
        northeast:  LatLng(pickLatLng.latitude, destLatLng.longitude),
      );
    }
    else{
      bounds = LatLngBounds(southwest: pickLatLng, northeast: destLatLng);
    }

     mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 70));


    Marker pickUpMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickUp.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    _marker.clear();

    setState(() {
    _marker.add(pickUpMarker);
    _marker.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
        circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: AppColors.colorGreen,
    );

    Circle destCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: AppColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destLatLng,
      fillColor: AppColors.colorAccentPurple,
    );

    _circle.clear();

    setState(() {
      _circle.add(pickupCircle);
      _circle.add(destCircle);
    });
  }

  void createRideRequest(){
    rideRef = FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destination = Provider.of<AppData>(context, listen: false).destinationAddress;


    Map pickUpMap = {
      'latitude' : pickUp.latitude.toString(),
      'longitude' : pickUp.longitude.toString(),
    };

    Map destinationMap = {
      'latitude' : destination.latitude.toString(),
      'longitude' : destination.longitude.toString(),
    };
    Map rideMap = {
      'created_At' : DateTime.now().toString(),
      'rider_fname' : currentUserInfo.firstName,
      'rider_lname' : currentUserInfo.lastName,
      'rider_email' : currentUserInfo.email,
      'rider_phone' : currentUserInfo.phone,
      'pickup_addres' : pickUp.placeName,
      'destination_addres' : destination.placeName,
      'location':pickUpMap,
      'destination':destinationMap,
      'payment_method':'Cash',
      'driver': 'waiting',
    };

    rideRef.set(rideMap);
  }

  void cancelRequest(){
    rideRef.remove();
  }

  resetApp(){
    setState(() {

    polyLineCoordinates.clear();
    _polyline.clear();
    _marker.clear();
    _circle.clear();
    requestingHeight = 0;
    rideDetails = 0;
    searchSheetHeight = (Platform.isAndroid)? 300 : 295;
    mapButtonPadding = (Platform.isAndroid)? 300 : 295;
    });

    setPositionLocator();
  }
}

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shareride_app/design_resource/app_colors.dart';
import 'package:shareride_app/design_resource/widget/App_Button.dart';
import 'package:shareride_app/design_resource/widget/ProgressDialog.dart';
import 'package:shareride_app/screens/login_page.dart';
import 'package:shareride_app/screens/mainpage.dart';

class RegistrationPage extends StatefulWidget {

  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
        content: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15
          ),
        ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  var FirstNameController = TextEditingController();

  var LastNameController = TextEditingController();

  var EmailController = TextEditingController();

  var PhoneController = TextEditingController();

  var PasswordController = TextEditingController();

  void registerUser() async {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Registering User',),
    );
    final User user = (await _firebaseAuth.createUserWithEmailAndPassword(
        email: EmailController.text,
        password: PasswordController.text
    ).catchError((ex){
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    })).user;

    if(user != null){
      DatabaseReference dbref = FirebaseDatabase.instance.reference().child('users/${user.uid}');

      Map userMap = {
       'first name': FirstNameController.text,
        'last name': LastNameController.text,
        'email': EmailController.text,
        'phone': PhoneController.text,
      };

      dbref.set(userMap);

      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 70,),
                Image(
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                  image: AssetImage('images/logo.png'),
                ),
                SizedBox(height: 40,),

                Text("Create Rider's Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'Brand-Bold'
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      //First Name
                      TextField(
                        controller: FirstNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0,),
                      ),

                      SizedBox(height: 5,),

                      //Last Name
                      TextField(
                        controller: LastNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0,),
                      ),

                      SizedBox(height: 5,),

                      //Email Address
                      TextField(
                        controller: EmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0,),
                      ),

                      SizedBox(height: 5,),

                      //Phone Number
                      TextField(
                        controller: PhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0,),
                      ),

                      SizedBox(height: 5,),

                      //Password
                      TextField(
                        controller: PasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 14.0,
                          ),
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0,),
                      ),

                      SizedBox(height: 40,),

                      //Register Button
                      AppButton(
                        title: 'REGISTER',
                        color: AppColors.colorGreen,
                        onPressed: () async {

                          var connectivityResult =  await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet! Please Connect To Your WiFi/Cellular Network');
                            return;
                          }
                          if(FirstNameController.text.length < 3){
                            showSnackBar('Please Provide Valid FirstName');
                            return;
                          }
                          if(PhoneController.text.length != 10){
                            showSnackBar('Please Enter Valid Phone Number');
                            return;
                          }
                          if(!EmailController.text.contains('@')){
                            showSnackBar('Please Enter Valid Email Address');
                            return;
                          }

                          if(PasswordController.text.length < 8){
                            showSnackBar('Password Must Have Atleast 8 Characters');
                            return;
                          }
                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                  },
                  child: Text('Already have a RIDER account? , Login Here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

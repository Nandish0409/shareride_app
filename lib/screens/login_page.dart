
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shareride_app/design_resource/app_colors.dart';
import 'package:shareride_app/design_resource/widget/App_Button.dart';
import 'package:shareride_app/design_resource/widget/ProgressDialog.dart';
import 'package:shareride_app/screens/mainpage.dart';
import 'package:shareride_app/screens/registration_page.dart';

class LoginPage extends StatefulWidget {

  static const String id = 'login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void login() async {
    
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Logging You In',),
    );

    final User user = (await _firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text
    ).catchError((ex){
      Navigator.pop(context);
      PlatformException thisEx = ex;
      showSnackBar(thisEx.message);
    })).user;

    if(user != null){
      DatabaseReference dbref = FirebaseDatabase.instance.reference().child('users/${user.uid}');

      dbref.once().then((DataSnapshot snapshot) => {
        if(snapshot.value != null){
          Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false)
        }
      });

      print('Login Successful');
    }

  }

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

                Text("Sign In As A Rider",
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
                      TextField(
                        controller: emailController,
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

                      SizedBox(height: 10,),

                      TextField(
                        controller: passwordController,
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

                      AppButton(
                        title: 'LOGIN',
                        color: AppColors.colorGreen,
                        onPressed: () async {
                          var connectivityResult =  await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet! Please Connect To Your WiFi/Cellular Network');
                            return;
                          }
                          if(!emailController.text.contains('@')){
                            showSnackBar('Please Enter Valid Email Address');
                            return;
                          }

                          if(passwordController.text.length < 8){
                            showSnackBar('Password Must Have Atleast 8 Characters');
                            return;
                          }

                          login();
                        },
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                  },
                  child: Text('Don\'t have an account , sign up here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


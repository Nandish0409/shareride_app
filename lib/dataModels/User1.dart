import 'package:firebase_database/firebase_database.dart';

class User1{
  String firstName;
  String lastName;
  String email;
  String phone;
  String iD;

  User1({
    this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.iD,
});

  User1.fromSnapshot(DataSnapshot snapshot){
    iD = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    firstName = snapshot.value['first name'];
    lastName = snapshot.value['last name'];

  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nft_proj/components/textformfirelds.dart';
import 'package:nft_proj/constants.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding * 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              decoration: plainTextFieldwBorder("First Name", 30),
              controller: _firstName,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(
              height: Constants.kPadding,
            ),
            TextFormField(
              decoration: plainTextFieldwBorder("Last Name", 30),
              controller: _lastName,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(
              height: Constants.kPadding,
            ),
            TextFormField(
              decoration: plainTextFieldwBorder("Phone Number", 30),
              controller: _phoneNumber,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
            ),
            const SizedBox(
              height: Constants.kPadding,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  var uid = _auth.currentUser!.uid;
                  var email = _auth.currentUser!.email;
                  _database.ref("USERS").child(uid).set({
                    "first_name": _firstName.text,
                    "last_name": _lastName.text,
                    "phone": _phoneNumber.text,
                    "email": email
                  });
                }
              },
              child: const Text(
                "Save",
              ),
            )
          ],
        ),
      ),
    );
  }
}

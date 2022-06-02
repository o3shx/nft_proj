import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nft_proj/app/loading_screen.dart';
import 'package:nft_proj/constants.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class ButtonsInfo {
  String title;
  IconData icon;

  ButtonsInfo({
    required this.title,
    required this.icon,
  });
}

bool adminUser = true;

int _currentIndex = 0;

List<ButtonsInfo> _unAuthButtonNames = [
  ButtonsInfo(title: "Log Out", icon: Icons.logout),
];

class _DrawerPageState extends State<DrawerPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String firstName, lastName, phone, email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserAccount();
  }

  getUserAccount() async {
    var uid = _auth.currentUser!.uid.toString();
    DatabaseEvent _dbRead =
        await FirebaseDatabase.instance.ref("USERS").child(uid).once();
    var _firstName = _dbRead.snapshot.child("first_name").value;
    var _lastName = _dbRead.snapshot.child("last_name").value;
    var _phone = _dbRead.snapshot.child("phone").value;
    var _email = _dbRead.snapshot.child("email").value;
    setState(() {
      firstName = _firstName.toString();
      lastName = _lastName.toString();
      phone = _phone.toString();
      email = _email.toString();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Constants.blackDark,
      child: Padding(
        padding: const EdgeInsets.all(Constants.kPadding),
        child: _isLoading
            ? const LoadingScreen(loadingText: "Loading")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        margin:
                            const EdgeInsets.only(bottom: Constants.kPadding),
                        padding: const EdgeInsets.all(Constants.kPadding * 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Constants.redDark.withOpacity(0.9),
                              Constants.orangeDark.withOpacity(0.9)
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.currency_bitcoin_rounded),
                            ),
                            const SizedBox(
                              height: Constants.kPadding * 2,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$firstName $lastName",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: Constants.kPadding / 2,
                                ),
                                Text(
                                  "Email: $email",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                const SizedBox(
                                  height: Constants.kPadding / 2,
                                ),
                                Text(
                                  "Phone: $phone",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        )),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 0.1,
                  ),
                  ...List.generate(
                    _unAuthButtonNames.length,
                    (index) => Column(
                      children: [
                        Container(
                          margin:
                              const EdgeInsets.only(top: Constants.kPadding),
                          decoration: index == _currentIndex
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Constants.redDark.withOpacity(0.9),
                                      Constants.orangeDark.withOpacity(0.9)
                                    ],
                                  ),
                                )
                              : null,
                          child: ListTile(
                            title: Text(
                              _unAuthButtonNames[index].title,
                              style: const TextStyle(color: Colors.white),
                            ),
                            leading: Padding(
                              padding: const EdgeInsets.all(Constants.kPadding),
                              child: Icon(
                                _unAuthButtonNames[index].icon,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                                FirebaseAuth.instance.signOut();
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // const Divider(
                        //   color: Colors.white,
                        //   thickness: 0.1,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

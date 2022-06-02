import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nft_proj/app/loading_screen.dart';
import 'package:nft_proj/constants.dart';
import 'package:nft_proj/screens/device_pairing/device_pairing.dart';
import 'package:nft_proj/screens/drawer/drawer.dart';
import 'package:nft_proj/screens/user_registration/registration_screen.dart';
import 'package:nft_proj/services/open_sea_api.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'package:nft_proj/screens/wallet_linking/wallet_linking.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({
    Key? key,
  }) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _currentIndex = 0;
  late PageController _pageController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  bool _isRegistered = false, _isLoading = true;
  late DatabaseReference dbRefData;
  late Stream<DatabaseEvent> streamData;
  late OpenSeaAPI openSeaAPI;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    setListners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  getUserAccount() async {
    var uid = _auth.currentUser!.uid.toString();
    DatabaseEvent _dbRead =
        await FirebaseDatabase.instance.ref("USERS").child(uid).once();

    if (_dbRead.snapshot.exists) {
      setState(() {
        _isRegistered = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isRegistered = false;
        _isLoading = false;
      });
    }
  }

  setListners() {
    var uid = _auth.currentUser!.uid.toString();
    dbRefData = database.ref();
    streamData = dbRefData.onValue;
    streamData.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot.child("USERS").child(uid);
      if (snapshot.exists) {
        setState(() {
          _isRegistered = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isRegistered = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRegistered) getUserAccount();
    return Scaffold(
      appBar: _isRegistered && !_isLoading
          ? PreferredSize(
              preferredSize: const Size(double.infinity, 60),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Constants.redDark.withOpacity(0.9),
                      Constants.orangeDark.withOpacity(0.9)
                    ],
                  ),
                ),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Row(
                    children: const [
                      CircleAvatar(
                        radius: 15,
                        child: Icon(Icons.currency_bitcoin_rounded),
                      ),
                      SizedBox(
                        width: Constants.kPadding,
                      ),
                      Text(
                        "NFT Proj",
                        style: TextStyle(
                          color: Constants.blackLight,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      drawer: const DrawerPage(),
      body: _isLoading
          ? const LoadingScreen(loadingText: "Loading")
          : !_isRegistered
              ? const RegistrationScreen()
              : SizedBox.expand(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    children: const [
                      WalletLinkingPage(),
                      DevicePairingPage(),
                    ],
                  ),
                ),
      bottomNavigationBar: _isRegistered && !_isLoading
          ? Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [
                    Constants.redDark.withOpacity(0.9),
                    Constants.orangeDark.withOpacity(0.9)
                  ],
                ),
              ),
              child: SalomonBottomBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                    _pageController.jumpToPage(index);
                  },
                  items: [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.account_balance_wallet_rounded),
                      title: const Text("My Wallet"),
                      unselectedColor: Colors.white,
                      selectedColor: Colors.black,
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.tablet_rounded),
                      title: const Text("My Device"),
                      unselectedColor: Colors.white,
                      selectedColor: Colors.black,
                    ),
                  ]),
            )
          : null,
    );
  }
}

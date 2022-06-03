import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nft_proj/app/loading_screen.dart';
import 'package:nft_proj/constants.dart';
import 'package:nft_proj/services/open_sea_api.dart';

class WalletLinkingPage extends StatefulWidget {
  const WalletLinkingPage({Key? key}) : super(key: key);

  @override
  State<WalletLinkingPage> createState() => _WalletLinkingPageState();
}

class _WalletLinkingPageState extends State<WalletLinkingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _walletId = TextEditingController();
  final FirebaseDatabase database = FirebaseDatabase.instance;

  late DatabaseReference dbRefData;
  late Stream<DatabaseEvent> streamData;
  late String _uid;
  bool isLoading = true;

  List _collection = [];
  var _count;
  var _last_update;

  setListners() {
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid;
    setState(() => _uid = uid);

    dbRefData = database.ref("ASSETS").child(uid);
    streamData = dbRefData.onValue;

    streamData.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        for (var element in snapshot.children) {
          var collection = element.child("collection").value as List<dynamic>;
          var count = element.child("count").value as int;
          var lastUpdate = element.child("last_update").value as String;

          setState(() {
            _collection = collection;
            _count = count;
            _last_update = lastUpdate;
            isLoading = false;
          });

          // print(collection['collection']);
          // for (var item in collection) {}
          // setState(() {
          //   // imageName.add(element.child("name").value);
          //   // imageUrl.add(element.child("img_url").value);
          //   setState(() {
          //     assets = element.value;
          //   });
          // });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setListners();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingScreen(loadingText: "Fetching Data");
    } else {
      if (_collection.isEmpty) {
        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(Constants.kPadding * 2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Please enter your wallet ID below",
                    style: TextStyle(
                      fontSize: Constants.kPadding * 2,
                    ),
                  ),
                  const SizedBox(
                    height: Constants.kPadding * 2,
                  ),
                  TextFormField(
                    controller: _walletId,
                  ),
                  const SizedBox(
                    height: Constants.kPadding * 2,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String userWalletAdd = _walletId.text;
                        OpenSeaAPI openSeaAPI = OpenSeaAPI();
                        await openSeaAPI.getUserAssests(userWalletAdd);
                        await database
                            .ref("USER_WALLETS")
                            .child(_uid)
                            .set([userWalletAdd]);
                      }
                    },
                    child: const Text("Link Wallet"),
                  )
                ],
              ),
            ),
          ),
        );
      } else {
        // return GridView.builder(
        //   gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        //       maxCrossAxisExtent: 200,
        //       childAspectRatio: 0.9,
        //       crossAxisSpacing: 20,
        //       mainAxisSpacing: 0),
        //   itemCount: imageName.length,
        //   itemBuilder: (context, index) {
        //     return Padding(
        //       padding: const EdgeInsets.all(Constants.kPadding * 2),
        //       child: Column(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.only(
        //                 bottom: Constants.kPadding,
        //                 right: Constants.kPadding,
        //                 left: Constants.kPadding),
        //             child: ClipRRect(
        //               borderRadius: BorderRadius.circular(20),
        //               child: Image.network(imageUrl[index]),
        //             ),
        //           ),
        //           Text(imageName[index]),
        //         ],
        //       ),
        //     );
        //   },
        // );
        // return Container();
        return ListView.builder(
          itemCount: _collection.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(Constants.kPadding * 2),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: Constants.kPadding,
                        right: Constants.kPadding,
                        left: Constants.kPadding),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _collection[index]['img_url'],
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Text(_collection[index]['name']),
                ],
              ),
            );
          },
        );
      }
    }
  }
}

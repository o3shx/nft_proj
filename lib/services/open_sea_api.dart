import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart';

class OpenSeaAPI {
  final String apiKey = "a725cfe850fc472db4c694d995ba1aab";

  FirebaseDatabase firebaseDatabase = FirebaseDatabase.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  getUserAssests(String userId) async {
    String url =
        "https://api.opensea.io/api/v1/assets?owner=$userId&order_direction=desc&limit=200&include_orders=false";

    var headers = {
      "Accept": "application/json",
      "X-API-KEY": "a725cfe850fc472db4c694d995ba1aab"
    };

    Uri uri = Uri.parse(url);

    try {
      var res = await get(uri, headers: headers);

      if (res.statusCode == 200) {
        var jsonData = jsonDecode(res.body);
        List assets = jsonData['assets'];
        List simpleAssets = [];
        int collectionCount = 0;
        String uid = firebaseAuth.currentUser!.uid;
        DatabaseReference dbRef = firebaseDatabase.ref("ASSETS").child(uid);

        for (var item in assets) {
          simpleAssets
              .add({"name": item['name'], "img_url": item['image_url']});
          collectionCount++;
        }

        // for (var item in assets) {
        dbRef.child(userId).set({
          "collection": simpleAssets,
          "count": collectionCount,
          "last_update": DateTime.now().toIso8601String(),
        });
        // {"name": item['name'], "img_url": item['image_url']},
        // );
        // }
      } else {
        print(res.body.toString());
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

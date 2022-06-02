import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:nft_proj/constants.dart';
import 'package:nft_proj/firebase_options.dart';
import 'package:nft_proj/app/widget_tree.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "NFT Proj",
          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Constants.blackDark,
              filled: true,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Constants.blueLight,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Constants.blueLight,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Constants.blueLight,
                  width: 3,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Constants.blackDark,
            canvasColor: Constants.blackLight,
          ),
          home: snapshot.data == null
              ? const SignInScreen(
                  providerConfigs: [
                    EmailProviderConfiguration(),
                  ],
                )
              : const WidgetTree(),
        );
      },
    );
  }
}

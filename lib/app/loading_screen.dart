import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nft_proj/constants.dart';

class LoadingScreen extends StatelessWidget {
  final String loadingText;

  const LoadingScreen({Key? key, required this.loadingText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Constants.kPadding * 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            loadingText,
            style: const TextStyle(
              color: Color.fromARGB(255, 125, 125, 125),
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: Constants.kPadding * 2,
          ),
          const SpinKitPianoWave(
            color: Constants.blueLight,
            size: 50,
          ),
        ],
      ),
    );
  }
}

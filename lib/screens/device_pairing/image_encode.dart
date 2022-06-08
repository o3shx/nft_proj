import 'dart:convert';
import 'dart:io';

import 'package:hex/hex.dart';
import 'package:http/http.dart';

void main(List<String> args) async {
  List<int> hexList = [];
  Uri url = Uri.parse(
      "https://lh3.googleusercontent.com/LM1nakX82b3z6fK5ii8gjQaVG7AwjCrMimmQ-f65pEk2fZ5CenZWGE9_pZrFoGEYKoaZKwUOTyLLuHnB5hcj1g8uugPvn_T_ZlEdJA"); // <-- 1
  var response = await get(url);
  final bytes = response.bodyBytes;
  String img64 = base64Encode(bytes);
  print(img64);
  // print(hex);
}

import 'package:flutter/material.dart';
import 'package:nft_proj/constants.dart';

InputDecoration plainTextFieldwBorder(String hint, double raduis) {
  return InputDecoration(
    hintText: hint,
    fillColor: Constants.blackLight,
    filled: true,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(raduis),
      borderSide: const BorderSide(
        color: Constants.blackLight,
        width: 3,
        style: BorderStyle.solid,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(raduis),
      borderSide: const BorderSide(
        color: Constants.blackDark,
        width: 3,
        style: BorderStyle.solid,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(raduis),
      borderSide: const BorderSide(
        color: Constants.blackDark,
        width: 3,
        style: BorderStyle.solid,
      ),
    ),
  );
}

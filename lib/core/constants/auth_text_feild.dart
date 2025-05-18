import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:flutter/material.dart';

final authFieldDecoration = InputDecoration(
  hintText: "Enter your email",
  hintStyle: style16,
  prefixIconColor: blackColor,
  suffixIconColor: blackColor,
  fillColor: fillColor,
  filled: true,
  border: InputBorder.none,
  enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: fillColor, width: 2.0),
      borderRadius: BorderRadius.circular(4)),
  focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: fillColor, width: 2.0),
      borderRadius: BorderRadius.circular(4)),
  errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: fillColor, width: 2.0),
      borderRadius: BorderRadius.circular(4)),
  disabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: fillColor, width: 2.0),
      borderRadius: BorderRadius.circular(4)),
  focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: fillColor, width: 2.0),
      borderRadius: BorderRadius.circular(4)),
);

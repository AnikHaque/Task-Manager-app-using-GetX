import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:task_manager/data/utils/assets_utils.dart';

class Base64Image {
  static Future<String> base64EncodedString(image) async {
    List<int> imageBytes = await image!.readAsBytes();
    return base64Encode(imageBytes);
  }

  static ImageProvider<Object> imageFromBase64String(String str) {
    List<int> imageBytes = base64Decode(str);
    return Image.memory(
      Uint8List.fromList(imageBytes),
      fit: BoxFit.cover,
    ).image;
  }

  static bool isBase64String(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Get the image for UI
  static ImageProvider<Object> getBase64Image(String base64String) {
    if (base64String.isNotEmpty) {
      print("Base64String: $base64String");

      if (isBase64String(base64String)) {
        try {
          return imageFromBase64String(base64String);
        } catch (e) {
          print("Error decoding base64 string: $e");
          return Image.asset(AssetsUtils.placeholderPNG).image;
        }
      } else {
        return Image.network(base64String).image;
      }
    } else {
      return Image.asset(AssetsUtils.placeholderPNG).image;
    }
  }
}

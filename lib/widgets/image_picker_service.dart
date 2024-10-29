import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {

  Future<void> openImagePicker(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Use the picked file (upload it, display it, etc.)
      print('Image picked: ${pickedFile.path}');
    } else {
      print('No image picked');
    }
  }
}

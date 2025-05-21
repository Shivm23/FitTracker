import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class PhotoPickerButton extends StatefulWidget {
  final void Function(String imagePath) onImagePicked;
  final String? initialImagePath;

  const PhotoPickerButton({
    super.key,
    required this.onImagePicked,
    this.initialImagePath,
  });

  @override
  State<PhotoPickerButton> createState() => _PhotoPickerButtonState();
}

class _PhotoPickerButtonState extends State<PhotoPickerButton> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _takeAndStorePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final appDir = await getApplicationDocumentsDirectory();

      final now = DateTime.now();
      final formattedTime =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
      final fileName =
          'selected_photo_$formattedTime${extension(pickedFile.path)}';
      final savedPath = '${appDir.path}/$fileName';

      final savedImage = await imageFile.copy(savedPath);

      setState(() {
        _imagePath = savedImage.path;
      });

      widget.onImagePicked(savedImage.path);
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _takeAndStorePhoto,
      icon: _imagePath == null
          ? const Icon(Icons.camera_alt, size: 40)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_imagePath!),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
      tooltip: _imagePath == null ? "Prendre une photo" : "Changer la photo",
    );
  }
}

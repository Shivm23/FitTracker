import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:opennutritracker/core/utils/path_helper.dart';

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
    if (widget.initialImagePath != null) {
      PathHelper.localImagePath(widget.initialImagePath!).then((path) {
        if (mounted) {
          setState(() {
            _imagePath = path;
          });
        }
      });
    }
  }

  Future<void> _takeAndStorePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (_imagePath != null) {
        final oldFile = File(_imagePath!);
        if (await oldFile.exists()) {
          try {
            await oldFile.delete();
          } catch (_) {}
        }
      }
      final now = DateTime.now();
      final formattedTime =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
      final fileName =
          'selected_photo_$formattedTime${extension(pickedFile.path)}';
      final savedPath = await PathHelper.localImagePath(fileName);

      final savedImage = await imageFile.copy(savedPath);

      setState(() {
        _imagePath = savedImage.path;
      });

      widget.onImagePicked(fileName);
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

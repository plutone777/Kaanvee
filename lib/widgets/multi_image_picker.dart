import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MultiImagePicker extends StatefulWidget {
  final List<XFile> selectedImages;
  final ValueChanged<List<XFile>> onImagesChanged;
  final int maxImages;

  const MultiImagePicker({
    super.key,
    required this.selectedImages,
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  @override
  State<MultiImagePicker> createState() =>
      _MultiImagePickerState();
}

class _MultiImagePickerState
    extends State<MultiImagePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final remaining =
        widget.maxImages - widget.selectedImages.length;

    if (remaining <= 0) {
      _showMessage(
        'You can select up to ${widget.maxImages} images.',
      );
      return;
    }

final images = await _picker.pickMultiImage(
  imageQuality: 75,
  maxWidth: 1200,
  maxHeight: 1200,
);
    if (images.isEmpty) {
      return;
    }

    final newImages = images.take(remaining).toList();

    widget.onImagesChanged([
      ...widget.selectedImages,
      ...newImages,
    ]);

    if (images.length > remaining) {
      _showMessage(
        'Only ${widget.maxImages} images can be selected.',
      );
    }
  }

  void _removeImage(int index) {
    final images =
        List<XFile>.from(widget.selectedImages);

    images.removeAt(index);

    widget.onImagesChanged(images);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),

        OutlinedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.image_outlined),
          label: const Text('Add Images'),
        ),

        if (widget.selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),

          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  widget.selectedImages.length,
              itemBuilder: (context, index) {
                final image =
                    widget.selectedImages[index];

                return Padding(
                  padding:
                      const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8),
                        child: Image.file(
                          File(image.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              _removeImage(index),
                          child: Container(
                            padding:
                                const EdgeInsets.all(2),
                            decoration:
                                const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
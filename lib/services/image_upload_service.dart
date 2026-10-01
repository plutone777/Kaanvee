import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<String>> uploadImages({
    required List<XFile> images,
    required String folder,
  }) async {
    final List<String> imageUrls = [];

    for (final image in images) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      final ref = _storage
          .ref()
          .child(folder)
          .child(fileName);

      await ref.putData(
        await image.readAsBytes(),
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      final url = await ref.getDownloadURL();

      imageUrls.add(url);
    }

    return imageUrls;
  }
}
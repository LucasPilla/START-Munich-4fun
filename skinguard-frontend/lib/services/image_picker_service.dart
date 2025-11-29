import 'package:image_picker/image_picker.dart';

/// Service class for handling image picking functionality
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the camera
  /// 
  /// Returns the picked [XFile] if successful, null if user cancels
  /// Throws an exception if an error occurs
  Future<XFile?> pickImageFromCamera({
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
      );
      return pickedFile;
    } catch (e) {
      rethrow;
    }
  }

  /// Picks an image from the gallery
  /// 
  /// Returns the picked [XFile] if successful, null if user cancels
  /// Throws an exception if an error occurs
  Future<XFile?> pickImageFromGallery({
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
      );
      return pickedFile;
    } catch (e) {
      rethrow;
    }
  }

  /// Checks if camera source is supported
  bool supportsCamera() {
    return _picker.supportsImageSource(ImageSource.camera);
  }

  /// Checks if gallery source is supported
  bool supportsGallery() {
    return _picker.supportsImageSource(ImageSource.gallery);
  }
}



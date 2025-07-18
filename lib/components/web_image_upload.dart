// 웹 전용 이미지 업로드 기능
import 'dart:html' as html;

class WebImageUpload {
  static void uploadImage(Function(String) onImageSelected) {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) {
          onImageSelected(reader.result as String);
        });
      }
    });
  }
} 
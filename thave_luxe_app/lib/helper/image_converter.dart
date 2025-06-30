import 'dart:convert'; // Untuk base64Encode
import 'dart:typed_data'; // Untuk Uint8List
import 'package:http/http.dart'
    as http; // Pastikan package:http sudah ditambahkan

/// Converts a network image from a given URL to a Base64 encoded string.
/// Returns the Base64 string if successful, null otherwise.
Future<String?> networkImageToBase64(String imageUrl) async {
  try {
    http.Response response = await http.get(Uri.parse(imageUrl));

    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      Uint8List imageBytes = response.bodyBytes;
      String base64String = base64Encode(imageBytes);
      return base64String;
    } else {
      print(
        'Failed to load image from $imageUrl. Status code: ${response.statusCode}',
      );
      return null;
    }
  } catch (e) {
    print('Error converting network image to base64: $e');
    return null;
  }
}

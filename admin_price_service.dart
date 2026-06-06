// admin_price_service.dart - G7GFT Admin Panel
// يعدّل السعر الداخلي على GitHub عبر API

import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminPriceService {
  static const String _owner = 'G-GFT';
  static const String _repo = 'g7gft-config';
  static const String _filePath = 'price.json';
  static const String _branch = 'main';
  // احفظ التوكن في Flutter Secure Storage
  static const String _token = 'YOUR_GITHUB_TOKEN_HERE';
  static const String _apiBase = 'https://api.github.com';

  // تحديث السعر من Admin Panel
  static Future<bool> updatePrice({
    required double newPrice,
    required String updatedBy,
  }) async {
    try {
      final String? sha = await _getFileSha();
      if (sha == null) return false;

      final now = DateTime.now();
      final String date = now.toIso8601String().split('T')[0];

      final Map<String, dynamic> newContent = {
        'internal_price': newPrice,
        'currency': 'USD',
        'symbol': 'G7GFT',
        'updated_at': date,
        'updated_by': updatedBy,
        'note': 'Internal trading price - managed by admin panel',
      };

      final String contentBase64 = base64Encode(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(newContent))
      );

      final response = await http.put(
        Uri.parse('$_apiBase/repos/$_owner/$_repo/contents/$_filePath'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Update price to $newPrice USD by $updatedBy',
          'content': contentBase64,
          'sha': sha,
          'branch': _branch,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[AdminPrice] Exception: $e');
      return false;
    }
  }

  static Future<String?> _getFileSha() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBase/repos/$_owner/$_repo/contents/$_filePath'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/vnd.github+json',
        },
      );
      if (response.statusCode == 200) {
        return (jsonDecode(response.body))['sha'] as String?;
      }
    } catch (e) { print(e); }
    return null;
  }

  static Future<Map<String, dynamic>?> getCurrentPrice() async {
    try {
      final response = await http.get(
        Uri.parse('https://raw.githubusercontent.com/$_owner/$_repo/main/$_filePath'),
        headers: {'Cache-Control': 'no-cache'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print(e); }
    return null;
  }
}
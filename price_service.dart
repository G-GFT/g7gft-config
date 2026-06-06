// ============================================================
// price_service.dart - G7GFT Flutter App
// يقرأ السعر الداخلي من GitHub كل دقيقتين
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceService {
    // رابط الملف على GitHub Raw
    static const String _priceUrl =
            'https://raw.githubusercontent.com/G-GFT/g7gft-config/main/price.json';

    // السعر الحالي
    static double _internalPrice = 0.85;
    static String _currency = 'USD';
    static String _updatedAt = '';
    static String _updatedBy = '';

    // Timer للتحديث التلقائي كل دقيقتين
    static Timer? _timer;

    // Getters
    static double get internalPrice => _internalPrice;
    static String get currency => _currency;
    static String get updatedAt => _updatedAt;
    static String get updatedBy => _updatedBy;
    static String get displayPrice => '$_internalPrice $_currency';

    // بدء الخدمة - استدعيها عند فتح التطبيق
    static Future<void> startService() async {
          // اقرأ السعر فوراً عند البدء
          await fetchPrice();

          // ثم كرر كل دقيقتين
          _timer = Timer.periodic(const Duration(minutes: 2), (_) {
                  fetchPrice();
          });
    }

    // إيقاف الخدمة عند إغلاق التطبيق
    static void stopService() {
          _timer?.cancel();
    }

    // جلب السعر من GitHub
    static Future<bool> fetchPrice() async {
          try {
                  final response = await http.get(
                            Uri.parse(_priceUrl),
                            headers: {'Cache-Control': 'no-cache'},
                          ).timeout(const Duration(seconds: 10));

                  if (response.statusCode == 200) {
                            final Map<String, dynamic> data = json.decode(response.body);
                            _internalPrice = (data['internal_price'] as num).toDouble();
                            _currency = data['currency'] ?? 'USD';
                            _updatedAt = data['updated_at'] ?? '';
                            _updatedBy = data['updated_by'] ?? '';
                            print('[PriceService] Price updated: $_internalPrice $_currency');
                            return true;
                  }
          } catch (e) {
                  print('[PriceService] Error fetching price: $e');
          }
          return false;
    }
}

// ============================================================
// الاستخدام في main.dart
// ============================================================
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await PriceService.startService(); // ابدأ الخدمة
//   runApp(MyApp());
// }
//
// ============================================================
// الاستخدام في أي Widget
// ============================================================
//
// Text('السعر: ${PriceService.displayPrice}')
// Text('آخر تحديث: ${PriceService.updatedAt}')
// Text('بواسطة: ${PriceService.updatedBy}')
//
// ============================================================
// pubspec.yaml - أضف هذا
// ============================================================
//
// dependencies:
//   http: ^1.1.0
//

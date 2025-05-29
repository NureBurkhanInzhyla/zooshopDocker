import 'dart:convert';
import 'package:http/http.dart' as http;

class MonobankService {
  static const String _baseUrl = 'https://api.monobank.ua';
  static const String _token = 'uk3jwFlUJ7IEO0t5qSRImzYLoFnvrgiEBE9HQidh2ytk';

  Future<String> createInvoice({
    required int amount,
    required int currency, // Изменено на int
    required String description,
    String? redirectUrl,
    String? webhookUrl,
    String? reference
  }) async {
    final url = Uri.parse('$_baseUrl/api/merchant/invoice/create');
    final headers = {
      'X-Token': _token,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'amount': amount, // Сумма в копейках (например, 4200 = 42 UAH)
      'ccy': currency, // Код валюты (980 для UAH, передается как int)
      'description': description, // Описание платежа
      if (redirectUrl != null) 'redirectUrl': redirectUrl, // URL для редиректа после оплаты
      if (webhookUrl != null) 'webHookUrl': webhookUrl, // URL для уведомлений
      if (reference != null) 'reference': reference, // URL для уведомлений
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pageUrl']; // Возвращаем ссылку на оплату
    } else {
      throw Exception('Failed to create invoice: ${response.body}');
    }
  }
}
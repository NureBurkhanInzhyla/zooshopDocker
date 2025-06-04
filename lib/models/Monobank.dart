import 'dart:convert';
import 'package:http/http.dart' as http;

class MonobankService {
  static const String _baseUrl = 'https://api.monobank.ua';
  static const String _token = 'uk3jwFlUJ7IEO0t5qSRImzYLoFnvrgiEBE9HQidh2ytk';

  Future<String> createInvoice({
    required int amount,
    required int currency, 
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
      'amount': amount, 
      'ccy': currency, 
      'description': description, 
      if (redirectUrl != null) 'redirectUrl': redirectUrl, 
      if (webhookUrl != null) 'webHookUrl': webhookUrl, 
      if (reference != null) 'merchantPaymInfo': {'reference': reference}, 
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pageUrl']; 
    } else {
      throw Exception('Failed to create invoice: ${response.body}');
    }
  }
}
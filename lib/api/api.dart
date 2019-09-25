import 'dart:convert' show json, utf8;
import 'dart:io';

const apiCategory = {
  'name': 'Currency',
  'route': 'currency',
};

class Api {
  final HttpClient _httpClient = HttpClient();
  final String _url = 'flutter.udacity.com';

  Future<List> getUnits(String category) async {
    final uri = Uri.https(_url, '/$category');
    final response = await _getJson(uri);
    if (response == null || response['units'] == null) {
      print('Error units');
      return null;
    }

    return response['units'];
  }

  Future<double> convert(String category, String amount, String from, String to) async {
    final uri = Uri.https(_url, '/$category/convert',
        {'amount': amount, 'from': from, 'to': to});
    final response = await _getJson(uri);

    if (response == null || response['status'] == null) {
      print('Error convert');
      return null;
    }

    if (response['status'] == 'error') {
      print('${response['message']}');
      return null;
    }

    return response['conversion'].toDouble();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final request = await _httpClient.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.OK) {
        return null;
      }

      final body = await response.transform(utf8.decoder).join();
      return json.decode(body);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future getChartData() async {
    http.Response response = await http
        .get(Uri.parse("https://619e-41-220-231-175.ngrok.io/payload"));

    var data = json.decode(response.body);
    return data["Charts"];
  }
}

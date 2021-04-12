
import 'dart:convert';

import 'package:http/http.dart' as http;
class RequestHelper{

  static Future<dynamic> getRequest(String url) async {

    String data;
    http.Response response = await http.get(Uri.parse(url));
    print(response.statusCode);
    try {
      if (response.statusCode == 200) {
         data = response.body;
         var datadecoded = jsonDecode(data);
         return datadecoded;
      }
      else {
        return 'failed';
      }
    }
    catch(e){
      return 'failed';
    }
  }

}
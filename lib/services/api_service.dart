import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future getItems() async {
    return await http.get(Uri.parse('$baseUrl/items'));
  }

  static Future borrowItem({
    required String userId,
    required String itemId,
    required String name,
    required String phone,
    required String borrowDate,
    required String returnDate,
    required int quantity,
  }) async {
    return await http.post(
      Uri.parse('$baseUrl/borrow'),
      body: {
        "user_id": userId,
        "item_id": itemId,
        "borrower_name": name,
        "borrower_phone": phone,
        "borrow_date": borrowDate,
        "return_date": returnDate,
        "quantity": quantity.toString(),
      },
    );
  }

  //Announcements
  static Future getAnnouncements() async {
    return await http.get(Uri.parse('$baseUrl/announcements'));
  }

  //Events
  static Future getEvents() async {
    return await http.get(Uri.parse('$baseUrl/events'));
  }
}

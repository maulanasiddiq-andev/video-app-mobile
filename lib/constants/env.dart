import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiPoint {
  static String baseUrl = dotenv.env["BASE_URL"] ?? "DEFAULT_API_URL";
  static String url = "$baseUrl/api/";
}
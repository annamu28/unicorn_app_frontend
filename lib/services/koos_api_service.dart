import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/program.dart';
import '../models/token_balance.dart';

class KoosApiService {
  final String baseUrl = 'https://api.koos.io';
  late final String apiKey;

  KoosApiService() {
    apiKey = dotenv.env['KOOS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('KOOS_API_KEY not found in environment variables');
    }
  }

  Future<Program> getProgram(String programId) async {
    try {
      print('Fetching program with ID: $programId');
      final response = await http.get(
        Uri.parse('$baseUrl/programs/$programId'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      print('Program API Response: ${response.body}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody);
        if (jsonResponse == null) {
          throw Exception('Received null response from API');
        }
        return Program.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load program: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getProgram: $e');
      rethrow;
    }
  }

  Future<TokenBalance> getTokenBalance(String programId, String username) async {
    try {
      print('Fetching token balance for program: $programId, user: $username');
      final encodedUsername = Uri.encodeComponent(username);
      final response = await http.get(
        Uri.parse('$baseUrl/programs/$programId/recipients/$encodedUsername/balance'),
        headers: {
          'x-api-key': apiKey,
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      print('Token Balance API Response: ${response.body}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final jsonResponse = json.decode(decodedBody);
        if (jsonResponse == null) {
          throw Exception('Received null response from API');
        }
        return TokenBalance.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load token balance: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getTokenBalance: $e');
      rethrow;
    }
  }
} 
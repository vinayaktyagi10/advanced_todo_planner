import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class SpotifyAuth {
  // Replace these with your values:
  static const String clientId = 'YOUR_CLIENT_ID_HERE';
  static const String redirectUri = 'http://127.0.0.1:8080/callback';
  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    // add more scopes as needed
  ];

  late String _codeVerifier;

  /// Generates a new PKCE code verifier (random string)
  String generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(64, (i) => random.nextInt(256));
    _codeVerifier = base64UrlEncode(values).replaceAll('=', '');
    return _codeVerifier;
  }

  /// Generates the code challenge based on the verifier
  String generateCodeChallenge(String codeVerifier) {
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Builds the Spotify authorization URL with PKCE challenge
  Uri getAuthorizationUrl() {
    final verifier = generateCodeVerifier();
    final challenge = generateCodeChallenge(verifier);
    final scopesString = scopes.join(' ');

    final queryParams = {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'scope': scopesString,
    };

    return Uri.https('accounts.spotify.com', '/authorize', queryParams);
  }

  /// Get the current code verifier (needed later to exchange code for tokens)
  String get codeVerifier => _codeVerifier;
}


import 'package:flutter/material.dart';
import '../services/spotify_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyLoginScreen extends StatefulWidget {
  const SpotifyLoginScreen({super.key});

  @override
  State<SpotifyLoginScreen> createState() => _SpotifyLoginScreenState();
}

class _SpotifyLoginScreenState extends State<SpotifyLoginScreen> {
  final SpotifyAuth spotifyAuth = SpotifyAuth();

  void _loginWithSpotify() async {
    final authUrl = spotifyAuth.getAuthorizationUrl();

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } else {
      // Could not launch URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Spotify login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spotify Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _loginWithSpotify,
          child: const Text('Login with Spotify'),
        ),
      ),
    );
  }
}

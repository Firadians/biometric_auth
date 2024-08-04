import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authorized_page.dart';

class BiometricAuth extends StatefulWidget {
  @override
  _BiometricAuthState createState() => _BiometricAuthState();
}

class _BiometricAuthState extends State<BiometricAuth> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;
  String _authorized = 'Not Authorized';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _checkAuthenticationState();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _checkAuthenticationState() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    if (isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthorizedPage()),
      );
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });
      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthorizedPage()),
        );
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.toString()}';
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Can check biometrics: $_canCheckBiometrics\n'),
            Text('Current State: $_authorized\n'),
            _isAuthenticating
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Authenticate'),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'client/home_client.dart';
import 'admin/home_admin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Wait for AuthProvider to finish initialization then navigate
    final auth = Provider.of<AuthProvider>(context);
    if (!auth.isInitialized) {
      // listen for changes
      auth.addListener(_checkAuth);
    } else {
      _navigateBasedOnAuth(auth);
    }
  }

  void _checkAuth() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isInitialized) {
      auth.removeListener(_checkAuth);
      _navigateBasedOnAuth(auth);
    }
  }

  void _navigateBasedOnAuth(AuthProvider auth) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (auth.isAuthenticated) {
        if (auth.currentUser?.role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeAdmin()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeClient()));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[SplashScreen] build called');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}

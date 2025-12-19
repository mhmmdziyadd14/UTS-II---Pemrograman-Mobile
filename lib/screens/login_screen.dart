import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'client/home_client.dart';
import 'admin/home_admin.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If already authenticated (persisted), redirect immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        if (auth.currentUser?.role == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeAdmin()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeClient()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mosque, size: 80, color: Colors.teal),
              SizedBox(height: 20),
              Text("TrueDeen", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
              SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
                SizedBox(height: 24),
                if (authProvider.lastError != null) ...[
                  Text(authProvider.lastError!, style: TextStyle(color: Colors.red)),
                  SizedBox(height: 8),
                ],
                authProvider.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                          final username = _usernameController.text.trim();
                          final password = _passwordController.text.trim();
                          if (username.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Username dan password tidak boleh kosong")),
                            );
                            return;
                          }

                          bool success = await authProvider.login(
                            username,
                            password,
                          );

                          if (success) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              if (authProvider.currentUser?.role == 'admin') {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeAdmin()));
                              } else {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeClient()));
                              }
                            });
                          }
                        },
                        child: Text("MASUK", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
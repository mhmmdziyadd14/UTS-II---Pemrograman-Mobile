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
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal.shade700, Colors.teal.shade200],
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.15),
              // Logo Area
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(Icons.mosque_outlined, size: 80, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "TrueDeen",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "Teman Ibadah Anda",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 40),
              
              // Login Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person_outline, color: Colors.teal),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      authProvider.isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () async {
                                bool success = await authProvider.login(
                                  _usernameController.text,
                                  _passwordController.text,
                                );

                                if (success) {
                                  if (authProvider.currentUser?.role == 'admin') {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeAdmin()));
                                  } else {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeClient()));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Login Gagal. Cek username/password")),
                                  );
                                }
                              },
                              child: Text(
                                "MASUK",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
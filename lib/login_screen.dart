import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_list/services/auth_services.dart';
import 'package:flex_list/sign_up_screen.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthServices _auth = AuthServices();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  LoginScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1d2630),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1d2630),
        foregroundColor: Colors.white,
        title: const Text("Sign In"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Login Here",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white60),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Email",
                    labelStyle: const TextStyle(
                      color: Colors.white60,
                    )
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white60),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: "Password",
                    labelStyle: const TextStyle(
                      color: Colors.white60,
                    )
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 55,
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 1.5,
                child: ElevatedButton(onPressed: () async {
                  User? user = await _auth.signInWithEmailAndPassword(
                    _emailController.text,
                    _passController.text,
                  );

                  if (user != null) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
                  }
                },
                    child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 18,
                        )
                    )),
              ),
              const SizedBox(height: 20),
              const Text("OR", style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUpScreen()));
                  },
                  child: const Text("Create Account",
                    style: TextStyle(fontSize: 18),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

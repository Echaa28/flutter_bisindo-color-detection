import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:colordetection/login.dart';

class halaman_daftar extends StatelessWidget {
  const halaman_daftar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(69, 79, 130, 1),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Daftar(),
        ],
      ),
    );
  }
}

final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController = TextEditingController();
final TextEditingController verificationCodeController =
    TextEditingController();

Future<void> signup(BuildContext context) async {
  final String name = nameController.text;
  final String email = emailController.text;
  final String password = passwordController.text;
  final String confirmPassword = confirmPasswordController.text;

  if (name.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Silahkan isi bidang yang kosong')),
    );
    return;
  }

  if (password.length < 8) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kata sandi harus minimal 8 karakter')),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password Salah')),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://194.31.53.102:21059/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      showVerificationCodeDialog(context);
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}

Future<void> verifyCode(BuildContext context) async {
  final String verificationCode = verificationCodeController.text;
  final String email = emailController.text;

  if (verificationCode.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Masukkan kode verifikasi')),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://194.31.53.102:21059/confirm_email/<token>'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'verificationCode': verificationCode,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifikasi berhasil.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => halaman_login(),
        ),
        (route) => false,
      );
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'])),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}

void showVerificationCodeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Masukkan Kode Verifikasi'),
        content: TextField(
          controller: verificationCodeController,
          decoration: InputDecoration(hintText: "Kode Verifikasi"),
        ),
        actions: [
          TextButton(
            onPressed: () => verifyCode(context),
            child: Text('Verifikasi'),
          ),
        ],
      );
    },
  );
}

class Daftar extends StatefulWidget {
  @override
  _DaftarState createState() => _DaftarState();
}

class _DaftarState extends State<Daftar> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 50),
        Text(
          'DAFTAR AKUN SEKARANG',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.048,
            fontFamily: 'ABeeZee',
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        inputFile(
          label: "Username",
          controller: nameController,
        ),
        inputFile(
          label: "Email",
          controller: emailController,
        ),
        inputFile(
          label: "Password",
          obscureText: _obscurePassword,
          controller: passwordController,
          togglePasswordVisibility: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        inputFile(
          label: "Konfirmasi Password",
          obscureText: _obscureConfirmPassword,
          controller: confirmPasswordController,
          togglePasswordVisibility: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => signup(context),
          style: ElevatedButton.styleFrom(
            foregroundColor:
                const Color.fromRGBO(69, 79, 130, 1).withOpacity(0.5),
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
              side: BorderSide(color: Color(0xFFD8D0E3)),
            ),
          ),
          child: Text(
            'DAFTAR',
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontFamily: 'ABeeZee',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Sudah Punya Akun?"),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => halaman_login(),
                  ),
                );
              },
              child: Text(
                "Login Sekarang",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.043,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget inputFile({
  required String label,
  bool obscureText = false,
  required TextEditingController controller,
  VoidCallback? togglePasswordVisibility,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
      SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          hintText: 'Enter your $label',
          hintStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          border: OutlineInputBorder(),
          suffixIcon: togglePasswordVisibility != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: togglePasswordVisibility,
                )
              : null,
        ),
        style: TextStyle(color: Colors.white),
      ),
      SizedBox(height: 10),
    ],
  );
}

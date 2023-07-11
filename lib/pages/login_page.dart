import 'package:flutter/material.dart';
import '../connections/connect.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

TextEditingController _usercontroller = TextEditingController();
TextEditingController _passwordcontroller = TextEditingController();
final formKey = GlobalKey<FormState>();

Connect connect = Connect();

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    login() async {
      await connect.loginUser(
        user: _usercontroller.text,
        password: _passwordcontroller.text,
        context: context,
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              //username
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter valid user detail";
                  } else {
                    return null;
                  }
                },
                controller: _usercontroller,
                decoration: InputDecoration(
                    hintText: "username/ email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),

              const SizedBox(height: 10),
              //password
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 2) {
                    return "enter longer password";
                  } else {
                    return null;
                  }
                },
                controller: _passwordcontroller,
                decoration: InputDecoration(
                    hintText: "password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  child: const Text("Login User"))
            ],
          )),
    );
  }
}

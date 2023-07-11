import 'package:flutter/material.dart';
import 'package:rocketchat/connections/connect.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

TextEditingController _namecontroller = TextEditingController();
TextEditingController _usernamecontroller = TextEditingController();
TextEditingController _emailcontroller = TextEditingController();
TextEditingController _passcontroller = TextEditingController();
final formKey = GlobalKey<FormState>();

Connect connect = Connect();

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    register() {
      connect.registerUser(
        username: _usernamecontroller.text,
        email: _emailcontroller.text,
        pass: _passcontroller.text,
        name: _namecontroller.text,
        context: context,
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Form(
          key: formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              //name
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter valid name";
                  } else {
                    return null;
                  }
                },
                controller: _namecontroller,
                decoration: InputDecoration(
                    hintText: "name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              //username
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter valid username";
                  } else {
                    return null;
                  }
                },
                controller: _usernamecontroller,
                decoration: InputDecoration(
                    hintText: "username",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              //email
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "enter valid email";
                  } else {
                    return null;
                  }
                },
                controller: _emailcontroller,
                decoration: InputDecoration(
                    hintText: "email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              //pass
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 4) {
                    return "enter longer password";
                  } else {
                    return null;
                  }
                },
                controller: _passcontroller,
                decoration: InputDecoration(
                    hintText: "password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      register();
                    }
                  },
                  child: const Text("Register User"))
            ],
          )),
    );
  }
}

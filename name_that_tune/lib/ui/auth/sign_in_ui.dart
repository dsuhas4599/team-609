import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:core';
import 'package:get/get.dart';
import 'package:flutter_starter/localizations.dart';
import 'package:flutter_starter/ui/auth/auth.dart';
import 'package:flutter_starter/ui/components/components.dart';
import 'package:flutter_starter/helpers/helpers.dart';
import 'package:flutter_starter/controllers/controllers.dart';

class SignInUI extends StatelessWidget {
  final AuthController authController = AuthController.to;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);

    return Scaffold(
      //backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Text('Name That Tune!',
                              textScaleFactor: 4,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                // color: Colors.black
                              ))),
                    ],
                  ),
                  LogoGraphicHeader(),
                  SizedBox(height: 48.0),
                  Padding(
                      padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                      child: FormInputFieldWithIcon(
                        controller: authController.emailController,
                        iconPrefix: Icons.email,
                        labelText: labels?.auth?.emailFormField,
                        validator: Validator(labels).email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => null,
                        onSaved: (value) =>
                            authController.emailController.text = value,
                        onFieldSubmitted: (value) => {
                          if (_formKey.currentState.validate())
                            {authController.signInWithEmailAndPassword(context)}
                        },
                      )),
                  FormVerticalSpace(),
                  Padding(
                      padding: EdgeInsets.fromLTRB(100, 0, 100, 0),
                      child: FormInputFieldWithIcon(
                        controller: authController.passwordController,
                        iconPrefix: Icons.lock,
                        labelText: labels?.auth?.passwordFormField,
                        validator: Validator(labels).password,
                        obscureText: true,
                        onChanged: (value) => null,
                        onSaved: (value) =>
                            authController.passwordController.text = value,
                        onFieldSubmitted: (value) => {
                          if (_formKey.currentState.validate())
                            {authController.signInWithEmailAndPassword(context)}
                        },
                        maxLines: 1,
                      )),
                  FormVerticalSpace(),
                  PrimaryButton(
                      labelText: labels?.auth?.signInButton,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          authController.signInWithEmailAndPassword(context);
                        }
                      }),
                  FormVerticalSpace(),
                  LabelButton(
                    labelText: labels?.auth?.resetPasswordLabelButton,
                    onPressed: () => Get.to(ResetPasswordUI()),
                  ),
                  LabelButton(
                    labelText: labels?.auth?.signUpLabelButton,
                    onPressed: () => Get.to(SignUpUI()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

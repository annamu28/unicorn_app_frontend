import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/state/auth_result.dart';
import 'package:unicorn_app_frontend/state/auth_state.dart';
import 'package:unicorn_app_frontend/views/authentication/validators/validator.dart';
import 'package:unicorn_app_frontend/views/constants/colors.dart';
import 'package:unicorn_app_frontend/views/constants/strings.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      //controller is given to provider function
      final authProvider = ref.read(authenticationProvider.notifier);
      await authProvider.loginWithEmailAndPassword(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authenticationProvider);

    ref.listen(authenticationProvider,
        (AuthState? previous, AuthState current) {
      // We check if the state is not loading and login failed
      if (current.result == AuthResult.failure && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(Strings.wrongEmailOrPass),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Header text
              Text(
                Strings.appName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                Strings.logIntoYourAccount,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              // Email field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    validateEmail, //-> (String? value) => _validateEmail(value)
              ),
              const SizedBox(height: 16),
              // Password field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                obscureText: true,
                validator: validatePassword,
              ),
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                  foregroundColor: AppColors.loginButtonTextColor,
                ),
                onPressed: authProvider.isLoading
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        _attemptLogin();
                      },
                child: authProvider.isLoading
                    ? CircularProgressIndicator()
                    : Text(Strings.logIn),
              ),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      Strings.or,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                  foregroundColor: AppColors.loginButtonTextColor,
                ),
                onPressed: () => context.push('/register'),
                child: Text(Strings.register),
              ),
              //const LoginViewSignupLinks(),
            ],
          ),
        ),
      ),
    );
  }
}

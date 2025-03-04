import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/state/auth_result.dart';
import 'package:unicorn_app_frontend/state/auth_state.dart';
import 'package:unicorn_app_frontend/views/authentication/validators/validator.dart';
import 'package:unicorn_app_frontend/views/constants/colors.dart';
import 'package:unicorn_app_frontend/views/constants/strings.dart';


class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptRegister() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      //controller is given to provider function
      final authProvider = ref.read(authenticationProvider.notifier);
      await authProvider.registerWithEmailAndPassword(
          firstName, lastName, email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authenticationProvider);
    ref.listen(isLoggedInProvider, (_, isLoggedIn) {
      context.pop();
    });

    ref.listen(authenticationProvider,
        (AuthState? previous, AuthState current) {
      // We check if the state is not loading and login failed
      if (current.result == AuthResult.alreadyExists && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(Strings.emailAlreadyExist),
            backgroundColor: Colors.red,
          ),
        );
      } else if (current.result == AuthResult.success && !current.isLoading) {
        context.go('/avatar'); // Navigate to AvatarView
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
                Strings.signUpOn,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                validator:
                    validateName, //-> (String? value) => _validateEmail(value)
              ),

              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last name',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                validator:
                    validateName, //-> (String? value) => _validateEmail(value)
              ),
              const SizedBox(height: 16),
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
                validator: validateName,
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
                        _attemptRegister();
                      },
                child: authProvider.isLoading
                    ? CircularProgressIndicator()
                    : Text(Strings.register),
              ),
              //const LoginViewSignupLinks(),
            ],
          ),
        ),
      ),
    );
  }
}

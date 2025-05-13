import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/state/auth_result.dart';
import 'package:unicorn_app_frontend/state/auth_state.dart';
import 'package:unicorn_app_frontend/views/authentication/validators/validator.dart';
import 'package:unicorn_app_frontend/views/constants/colors.dart';
import 'package:unicorn_app_frontend/views/constants/strings.dart';
import 'package:unicorn_app_frontend/views/authentication/register/terms_and_agreement.dart';


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
  DateTime? _selectedDate;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _attemptRegister() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions to register'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;
      final birthdate = _selectedDate!;
      
      final authProvider = ref.read(authenticationProvider.notifier);
      await authProvider.registerWithEmailAndPassword(
        firstName, 
        lastName, 
        email, 
        password,
        birthdate,
      );
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthdate'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authenticationProvider);
    ref.listen(authenticationProvider, (_, state) {
      if (state.isAuthenticated) {
        context.pop();
      }
    });

    ref.listen(authenticationProvider, (AuthState? previous, AuthState current) {
      if (current.result == AuthResult.alreadyExists && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(Strings.emailAlreadyExist),
            backgroundColor: Colors.red,
          ),
        );
      } else if (current.result == AuthResult.success && !current.isLoading) {
        // Navigate to avatar view after successful registration
        context.go('/avatar');
      } else if (current.result == AuthResult.failure && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              // Add birthdate field
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Birthdate',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: Colors.black),
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select your birthdate',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showTermsAndAgreement(context);
                      },
                      child: Text(
                        'I agree to the terms and conditions',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                  foregroundColor: AppColors.loginButtonTextColor,
                ),
                onPressed: _attemptRegister,
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

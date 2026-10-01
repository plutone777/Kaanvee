import 'package:flutter/material.dart';
import 'package:fyp_application/constants/lists.dart';
import 'package:fyp_application/models/user.dart';
import 'package:fyp_application/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

class EditAccountView extends StatefulWidget {
  final UserModel user;

  const EditAccountView({
    super.key,
    required this.user,
  });

  @override
  State<EditAccountView> createState() =>
      _EditAccountViewState();
}

class _EditAccountViewState extends State<EditAccountView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late String? _selectedLocation;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(
      text: widget.user.username,
    );

    _emailController = TextEditingController(
      text: widget.user.email,
    );

    _selectedLocation =
        AppLists.locations.contains(widget.user.location)
            ? widget.user.location
            : null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userViewModel = context.read<UserViewModel>();

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    if (username != widget.user.username) {
      final usernameTaken =
          await userViewModel.isUsernameTaken(username);

      if (!mounted) return;

      if (usernameTaken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username is already taken.'),
          ),
        );
        return;
      }
    }

    final updatedUser = UserModel(
      userId: widget.user.userId,
      username: username,
      email: email,
      role: widget.user.role,
      points: widget.user.points,
      location: _selectedLocation!,
      preferences: widget.user.preferences,
    );

    final success = await userViewModel.updateAccount(
      updatedUser,
      newEmail: email,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account updated successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userViewModel.errorMessage ??
                'Failed to update account.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),

      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return Form(
            key: _formKey,

            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                24,
                16,
                32,
              ),

              children: [

                const SizedBox(height: 28),

                // =====================================================
                // USERNAME
                // =====================================================

                TextFormField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    final username = value?.trim() ?? '';

                    if (username.isEmpty) {
                      return 'Please enter a username.';
                    }

                    if (username.length < 3) {
                      return 'Username must be at least 3 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // EMAIL
                // =====================================================

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Please enter an email.';
                    }

                    final emailRegex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    );

                    if (!emailRegex.hasMatch(email)) {
                      return 'Please enter a valid email.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // LOCATION
                // =====================================================

                DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Select your location',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                  ),

                  items: AppLists.locations.map((location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),

                  onChanged: viewModel.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedLocation = value;
                          });
                        },

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a location.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // =====================================================
                // SAVE BUTTON
                // =====================================================

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        viewModel.isLoading
                            ? null
                            : _saveChanges,

                    child: viewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

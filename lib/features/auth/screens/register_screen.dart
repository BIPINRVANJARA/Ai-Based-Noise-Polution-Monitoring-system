import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:noiseguard/shared/widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _orgController = TextEditingController();
  String _selectedRole = 'User';
  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _roles = ['User', 'Admin', 'Researcher', 'Authority'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join NoiseGuard Platform',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Register to monitor IoT sensors, configure thresholds, and receive real-time noise violation alerts.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 24),

              // Form Glass Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _inputDecoration('Full Name', Icons.person_outline),
                        validator: (val) => val == null || val.isEmpty ? 'Enter full name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _inputDecoration('Email Address', Icons.email_outlined),
                        validator: (val) => val == null || val.isEmpty ? 'Enter valid email' : null,
                      ),
                      const SizedBox(height: 16),

                      // Organization (Optional)
                      TextFormField(
                        controller: _orgController,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _inputDecoration('Organization / Department (Optional)', Icons.business_outlined),
                      ),
                      const SizedBox(height: 16),

                      // Role Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        dropdownColor: const Color(0xFF1E1E2C),
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _inputDecoration('Account Role', Icons.badge_outlined),
                        items: _roles
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r, style: GoogleFonts.inter(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedRole = val ?? 'User'),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: GoogleFonts.inter(color: Colors.white),
                        decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) => val == null || val.length < 6 ? 'Password must be 6+ chars' : null,
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _onRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA3E635),
                            foregroundColor: const Color(0xFF0F0F1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF0F0F1A),
                                  ),
                                )
                              : Text(
                                  'Complete Registration',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA3E635),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFFA3E635), size: 20),
      filled: true,
      fillColor: const Color(0xFF141422),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2A2A3C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFA3E635)),
      ),
    );
  }
}

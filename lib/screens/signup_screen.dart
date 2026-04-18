import 'package:flutter/material.dart';
import 'donor/donor_home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  // Tracks which role the user picked: null = none chosen yet
  String? _selectedRole; // 'donor' or 'ngo'

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final org = _orgController.text.trim();

    if (name.isEmpty) {
      _showSnack('Please enter your name');
      return;
    }
    if (_selectedRole == null) {
      _showSnack('Please select your role');
      return;
    }
    if (_selectedRole == 'ngo' && org.isEmpty) {
      _showSnack('Please enter your organization name');
      return;
    }

    // For now, just print. Firestore save comes later.
    debugPrint('Name: $name | Role: $_selectedRole | Org: $org');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DonorHomeScreen()),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTopBar(),
              const SizedBox(height: 32),
              _buildNameField(),
              const SizedBox(height: 28),
              _buildRoleSelector(),
              const SizedBox(height: 28),

              // Only show org field when NGO is selected
              if (_selectedRole == 'ngo') ...[
                _buildOrgField(),
                const SizedBox(height: 28),
              ],

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Top heading
  // ─────────────────────────────────────────
  Widget _buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('♻️', style: TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create your account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tell us a little about yourself',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Name input
  // ─────────────────────────────────────────
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your name',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Ramesh Kumar',
            prefixIcon: const Icon(Icons.person_outline,
                color: Color(0xFF2E7D32)),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF2E7D32), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Role selector — two large tappable cards
  // ─────────────────────────────────────────
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I am a...',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _roleCard(
                role: 'donor',
                icon: '🍱',
                label: 'Donor',
                subtitle: 'Hotel / Hall / Individual',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _roleCard(
                role: 'ngo',
                icon: '🤝',
                label: 'NGO',
                subtitle: 'Collect & distribute food',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // A single role card widget
  Widget _roleCard({
    required String role,
    required String icon,
    required String label,
    required String subtitle,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F5E9)   // light green when selected
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2E7D32)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? const Color(0xFF388E3C)
                    : Colors.grey,
              ),
            ),

            // Checkmark when selected
            const SizedBox(height: 10),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.check_circle,
                  color: Color(0xFF2E7D32), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Organization name (NGO only)
  // ─────────────────────────────────────────
  Widget _buildOrgField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Organization name',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _orgController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Helping Hands Foundation',
            prefixIcon: const Icon(Icons.apartment_outlined,
                color: Color(0xFF2E7D32)),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF2E7D32), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 10),

        // Info note for NGOs about verification
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1), // light amber
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: Color(0xFFF9A825)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NGO accounts need admin verification before accepting food posts.',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF795548)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Submit button
  // ─────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  // We pass user data in — later this comes from Firestore
  final String name;
  final String phone;
  final String role; // 'donor' or 'ngo'
  final String? orgName;
  final String? verificationStatus; // 'pending', 'verified', 'rejected'
  final int totalPosts;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.role,
    this.orgName,
    this.verificationStatus,
    this.totalPosts = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildInfoCard(context),
              const SizedBox(height: 12),
              if (role == 'ngo') _buildVerificationNote(),
              if (role == 'ngo') const SizedBox(height: 12),
              _buildAboutCard(),
              const SizedBox(height: 12),
              _buildLogoutButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Green header with avatar + name + role
  // ─────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final isNgo = role == 'ngo';

    return Container(
      width: double.infinity,
      color: const Color(0xFF2E7D32),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          // Back button row
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 8),

          // Avatar circle
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                isNgo ? '🤝' : '🍱',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isNgo ? '🏢 NGO' : '🍱 Donor',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Main info card
  // ─────────────────────────────────────────
  Widget _buildInfoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
          ),
          _divider(),
          _infoRow(
            icon: Icons.person_outline,
            label: 'Role',
            value: role == 'ngo' ? 'NGO' : 'Donor',
          ),

          // NGO-only fields
          if (role == 'ngo' && orgName != null) ...[
            _divider(),
            _infoRow(
              icon: Icons.apartment_outlined,
              label: 'Organization',
              value: orgName!,
            ),
            _divider(),
            _verificationRow(),
          ],

          // Donor-only fields
          if (role == 'donor') ...[
            _divider(),
            _infoRow(
              icon: Icons.inventory_2_outlined,
              label: 'Total posts',
              value: '$totalPosts posts',
            ),
          ],
        ],
      ),
    );
  }

  // Single info row
  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // Verification status row with color badge
  Widget _verificationRow() {
    final status = verificationStatus ?? 'pending';

    Color badgeColor;
    Color bgColor;
    String label;
    IconData icon;

    switch (status) {
      case 'verified':
        badgeColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFFE8F5E9);
        label = 'Verified';
        icon = Icons.verified_outlined;
        break;
      case 'rejected':
        badgeColor = const Color(0xFFC62828);
        bgColor = const Color(0xFFFFEBEE);
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      default: // pending
        badgeColor = const Color(0xFFE65100);
        bgColor = const Color(0xFFFFF3E0);
        label = 'Pending verification';
        icon = Icons.hourglass_empty;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined,
              size: 20, color: Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verification',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, thickness: 0.5, color: Colors.grey.shade200,
      indent: 16, endIndent: 16);

  // ─────────────────────────────────────────
  // Verification warning (NGO pending only)
  // ─────────────────────────────────────────
  Widget _buildVerificationNote() {
    if (verificationStatus == 'verified') return const SizedBox.shrink();

    final isRejected = verificationStatus == 'rejected';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRejected
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRejected
              ? const Color(0xFFEF9A9A)
              : const Color(0xFFFFE082),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRejected
                ? Icons.error_outline
                : Icons.info_outline,
            size: 18,
            color: isRejected
                ? const Color(0xFFC62828)
                : const Color(0xFFF9A825),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isRejected
                  ? 'Your NGO account was rejected. Please contact support for more information.'
                  : 'Your account is pending admin verification. You can view posts but cannot accept them yet.',
              style: TextStyle(
                fontSize: 12,
                color: isRejected
                    ? const Color(0xFFC62828)
                    : const Color(0xFF795548),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // About card
  // ─────────────────────────────────────────
  Widget _buildAboutCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _aboutRow(
            icon: Icons.info_outline,
            label: 'About Waste to Taste',
            value: 'v1.0.0',
          ),
          _divider(),
          _aboutRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy policy',
            value: '',
            showArrow: true,
          ),
        ],
      ),
    );
  }

  Widget _aboutRow({
    required IconData icon,
    required String label,
    required String value,
    bool showArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14)),
          ),
          if (value.isNotEmpty)
            Text(value,
                style: const TextStyle(
                    fontSize: 13, color: Colors.grey)),
          if (showArrow)
            const Icon(Icons.chevron_right,
                color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Logout button
  // ─────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Firebase sign out goes here later
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Log out'),
              content:
                  const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to login after logout
                    debugPrint('Logging out...');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Log out',
                    style: TextStyle(color: Color(0xFFC62828)),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.logout,
            color: Color(0xFFE65100), size: 18),
        label: const Text(
          'Log out',
          style: TextStyle(
            color: Color(0xFFE65100),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFFFCC80)),
          backgroundColor: const Color(0xFFFFF3E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

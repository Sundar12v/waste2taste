import 'package:flutter/material.dart';
import 'post_food_screen.dart';
import '../profile_screen.dart';

class DonorHomeScreen extends StatelessWidget {
  const DonorHomeScreen({super.key});

  // Dummy posts to show the UI — replaced with Firestore data later
  static final List<Map<String, dynamic>> _dummyPosts = [
    {
      'foodType': 'Rice & Dal',
      'quantity': 50,
      'pickupTime': '6:00 PM',
      'expiryTime': '5:30 PM',
      'status': 'pending',
    },
    {
      'foodType': 'Biryani',
      'quantity': 120,
      'pickupTime': '8:00 PM',
      'expiryTime': '7:30 PM',
      'status': 'accepted',
    },
    {
      'foodType': 'Chapati & Sabzi',
      'quantity': 30,
      'pickupTime': '2:00 PM',
      'expiryTime': '1:30 PM',
      'status': 'completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSectionLabel(),
            Expanded(child: _buildPostList()),
          ],
        ),
      ),

      // Big floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostFoodScreen()),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Donate Food',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Green top header
  // ─────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2E7D32),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🍱 Waste to Taste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Placeholder avatar
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(
                        name: 'Ramesh Kumar',
                        phone: '+91 98765 43210',
                        role: 'donor',
                        totalPosts: 3,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Good to see you! 👋',
            style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 13),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Food Posts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // "My Posts" label
  // ─────────────────────────────────────────
  Widget _buildSectionLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        '${_dummyPosts.length} posts this week',
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Scrollable list of post cards
  // ─────────────────────────────────────────
  Widget _buildPostList() {
    if (_dummyPosts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _dummyPosts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _PostCard(post: _dummyPosts[index]);
      },
    );
  }

  // Shown when donor has no posts yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to donate food',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Individual post card
// ─────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  // Returns color + label based on status
  Map<String, dynamic> _statusStyle(String status) {
    switch (status) {
      case 'accepted':
        return {
          'color': const Color(0xFF1565C0),  // blue
          'bg': const Color(0xFFE3F2FD),
          'label': 'Accepted',
          'icon': Icons.check_circle_outline,
        };
      case 'completed':
        return {
          'color': const Color(0xFF2E7D32),  // green
          'bg': const Color(0xFFE8F5E9),
          'label': 'Completed',
          'icon': Icons.done_all,
        };
      case 'expired':
        return {
          'color': const Color(0xFFC62828),  // red
          'bg': const Color(0xFFFFEBEE),
          'label': 'Expired',
          'icon': Icons.timer_off_outlined,
        };
      default: // pending
        return {
          'color': const Color(0xFFE65100),  // amber/orange
          'bg': const Color(0xFFFFF3E0),
          'label': 'Pending',
          'icon': Icons.hourglass_empty,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(post['status']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: food name + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post['foodType'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: style['bg'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style['icon'],
                          size: 13, color: style['color']),
                      const SizedBox(width: 4),
                      Text(
                        style['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: style['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Info row: quantity, pickup, expiry
            Row(
              children: [
                _infoChip(Icons.people_outline, '${post['quantity']} meals'),
                const SizedBox(width: 10),
                _infoChip(Icons.access_time, post['pickupTime']),
                const SizedBox(width: 10),
                _infoChip(Icons.timer_outlined, 'Exp ${post['expiryTime']}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

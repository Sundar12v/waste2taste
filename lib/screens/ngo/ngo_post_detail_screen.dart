import 'package:flutter/material.dart';

class NgoPostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const NgoPostDetailScreen({super.key, required this.post});

  @override
  State<NgoPostDetailScreen> createState() => _NgoPostDetailScreenState();
}

class _NgoPostDetailScreenState extends State<NgoPostDetailScreen> {
  bool _accepted = false;
  bool _loading = false;

  Future<void> _acceptPost() async {
    setState(() => _loading = true);

    // Simulate network delay — Firestore update goes here later
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _loading = false;
      _accepted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post accepted! The donor has been notified.'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final minutes = post['minutesLeft'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Food Post Details',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeroCard(post),
            const SizedBox(height: 16),
            _buildDetailsCard(post),
            const SizedBox(height: 16),
            _buildTimingCard(post, minutes),
            const SizedBox(height: 28),
            _buildAcceptButton(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Big food type hero card
  // ─────────────────────────────────────────
  Widget _buildHeroCard(Map<String, dynamic> post) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(post['icon'], style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            post['foodType'],
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'by ${post['donorName']}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline,
                    color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text(
                  '${post['quantity']} meals available',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Donor + location details
  // ─────────────────────────────────────────
  Widget _buildDetailsCard(Map<String, dynamic> post) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pickup Details',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.apartment_outlined, 'Donor',
              post['donorName']),
          const SizedBox(height: 14),
          _detailRow(Icons.location_on_outlined, 'Location',
              post['location']),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Timing card with expiry countdown
  // ─────────────────────────────────────────
  Widget _buildTimingCard(Map<String, dynamic> post, int minutes) {
    Color urgColor;
    String urgLabel;

    if (minutes <= 20) {
      urgColor = const Color(0xFFC62828);
      urgLabel = 'Expiring very soon!';
    } else if (minutes <= 60) {
      urgColor = const Color(0xFFE65100);
      urgLabel = 'Expiring in $minutes minutes';
    } else {
      urgColor = const Color(0xFF2E7D32);
      urgLabel =
          'Expiring in ${minutes ~/ 60}h ${minutes % 60}m';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timing',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _detailRow(Icons.access_time, 'Pickup time',
              post['pickupTime']),
          const SizedBox(height: 14),
          _detailRow(Icons.timer_outlined, 'Post expires at',
              post['expiryTime']),
          const SizedBox(height: 16),

          // Countdown pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: urgColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: urgColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: urgColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  urgLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: urgColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable row for a label + value
  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // Accept button — changes state after tap
  // ─────────────────────────────────────────
  Widget _buildAcceptButton() {
    if (_accepted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E7D32)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle,
                color: Color(0xFF2E7D32), size: 20),
            SizedBox(width: 8),
            Text(
              'Post Accepted',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _acceptPost,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.check_circle_outline,
                color: Colors.white),
        label: Text(
          _loading ? 'Accepting...' : 'Accept This Post',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          disabledBackgroundColor:
              const Color(0xFF2E7D32).withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

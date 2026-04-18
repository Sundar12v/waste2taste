import 'package:flutter/material.dart';
import 'ngo_post_detail_screen.dart';
import '../profile_screen.dart';

class NgoHomeScreen extends StatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  State<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends State<NgoHomeScreen> {
  // Filter: 'all' or a food type string
  String _activeFilter = 'all';

  // Dummy posts — replaced with Firestore later
  // Only 'pending' posts are shown to NGOs (non-expired)
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'foodType': 'Rice & Dal',
      'icon': '🍚',
      'quantity': 80,
      'pickupTime': '6:00 PM',
      'expiryTime': '5:30 PM',
      'location': 'Hotel Royal, Anna Nagar',
      'donorName': 'Hotel Royal',
      'status': 'pending',
      'minutesLeft': 45,
    },
    {
      'id': '2',
      'foodType': 'Biryani',
      'icon': '🍛',
      'quantity': 150,
      'pickupTime': '8:00 PM',
      'expiryTime': '7:30 PM',
      'location': 'Grand Hall, T. Nagar',
      'donorName': 'Grand Banquet Hall',
      'status': 'pending',
      'minutesLeft': 110,
    },
    {
      'id': '3',
      'foodType': 'Chapati & Sabzi',
      'icon': '🫓',
      'quantity': 40,
      'pickupTime': '3:00 PM',
      'expiryTime': '2:30 PM',
      'location': 'Ramesh Home, Adyar',
      'donorName': 'Ramesh Kumar',
      'status': 'pending',
      'minutesLeft': 18,
    },
    {
      'id': '4',
      'foodType': 'Sweets / Desserts',
      'icon': '🍰',
      'quantity': 200,
      'pickupTime': '9:00 PM',
      'expiryTime': '8:30 PM',
      'location': 'Celebration Hall, Velachery',
      'donorName': 'Celebration Events',
      'status': 'pending',
      'minutesLeft': 160,
    },
  ];

  List<String> get _filterOptions {
    final types = _posts.map((p) => p['foodType'] as String).toSet().toList();
    return ['all', ...types];
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_activeFilter == 'all') return _posts;
    return _posts
        .where((p) => p['foodType'] == _activeFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            _buildUrgencyBanner(),
            Expanded(child: _buildPostList()),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────
  Widget _buildHeader() {
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
                '🤝 Waste to Taste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(
                        name: 'Helping Hands Foundation',
                        phone: '+91 99887 76655',
                        role: 'ngo',
                        orgName: 'Helping Hands Foundation',
                        verificationStatus: 'verified', // or 'pending'
                        totalPosts: 0,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.apartment, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Available Food Posts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_filteredPosts.length} posts near you',
            style: const TextStyle(
                color: Color(0xFFA5D6A7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Filter chips (All / food types)
  // ─────────────────────────────────────────
  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filterOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final option = _filterOptions[index];
            final isActive = _activeFilter == option;
            final label =
                option == 'all' ? 'All' : option;

            return GestureDetector(
              onTap: () => setState(() => _activeFilter = option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF2E7D32)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Urgency banner — warns if any post expires soon
  // ─────────────────────────────────────────
  Widget _buildUrgencyBanner() {
    final urgent =
        _posts.where((p) => (p['minutesLeft'] as int) <= 20).toList();
    if (urgent.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFC62828), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${urgent.length} post${urgent.length > 1 ? 's' : ''} expiring within 20 minutes!',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Post list
  // ─────────────────────────────────────────
  Widget _buildPostList() {
    final posts = _filteredPosts;

    if (posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🍽️', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('No posts available',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            Text('Check back soon',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _NgoPostCard(
          post: posts[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    NgoPostDetailScreen(post: posts[index]),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// NGO post card
// ─────────────────────────────────────────
class _NgoPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onTap;

  const _NgoPostCard({required this.post, required this.onTap});

  // Urgency color based on minutes left
  Color _urgencyColor(int minutes) {
    if (minutes <= 20) return const Color(0xFFC62828); // red
    if (minutes <= 60) return const Color(0xFFE65100); // orange
    return const Color(0xFF2E7D32);                    // green
  }

  String _urgencyLabel(int minutes) {
    if (minutes <= 20) return 'Urgent';
    if (minutes <= 60) return '$minutes min left';
    return '${minutes ~/ 60}h ${minutes % 60}m left';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = post['minutesLeft'] as int;
    final urgColor = _urgencyColor(minutes);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            // Top colored urgency strip
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: urgColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food icon + name + urgency badge
                  Row(
                    children: [
                      Text(post['icon'],
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['foodType'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              post['donorName'],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Urgency badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: urgColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 12, color: urgColor),
                            const SizedBox(width: 4),
                            Text(
                              _urgencyLabel(minutes),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: urgColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Info row
                  Row(
                    children: [
                      _chip(Icons.people_outline,
                          '${post['quantity']} meals'),
                      const SizedBox(width: 16),
                      _chip(Icons.access_time, post['pickupTime']),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _chip(Icons.location_on_outlined,
                            post['location'],
                            truncate: true),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View & Accept',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {bool truncate = false}) {
    final text = Text(
      label,
      style: const TextStyle(fontSize: 12, color: Colors.grey),
      overflow: truncate ? TextOverflow.ellipsis : null,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        truncate ? Expanded(child: text) : text,
      ],
    );
  }
}

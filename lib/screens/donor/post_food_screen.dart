import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({super.key});

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _customFoodController = TextEditingController();

  String? _selectedFoodType;
  TimeOfDay? _pickupTime;
  TimeOfDay? _expiryTime; // auto-calculated

  // Predefined food types — avoids typing for low-literacy users
  final List<Map<String, String>> _foodTypes = [
    {'icon': '🍚', 'label': 'Rice & Dal'},
    {'icon': '🍛', 'label': 'Biryani'},
    {'icon': '🫓', 'label': 'Chapati & Sabzi'},
    {'icon': '🥗', 'label': 'Salad / Snacks'},
    {'icon': '🍰', 'label': 'Sweets / Desserts'},
    {'icon': '🥘', 'label': 'Mixed Meals'},
    {'icon': '✍️', 'label': 'Custom'},
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _locationController.dispose();
    _customFoodController.dispose();
    super.dispose();
  }

  // Opens time picker and auto-calculates expiry = pickup - 30 mins
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        // Tint the time picker green
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Calculate expiry = pickup - 30 minutes
      final totalMinutes = picked.hour * 60 + picked.minute - 30;
      final expiryHour = totalMinutes ~/ 60;
      final expiryMinute = totalMinutes % 60;

      setState(() {
        _pickupTime = picked;
        _expiryTime = TimeOfDay(
          hour: expiryHour.clamp(0, 23),
          minute: expiryMinute.clamp(0, 59),
        );
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _submit() {
    if (_selectedFoodType == null) {
      _showSnack('Please select a food type');
      return;
    }

    String finalFoodType = _selectedFoodType!;
    if (_selectedFoodType == 'Custom') {
      finalFoodType = _customFoodController.text.trim();
      if (finalFoodType.isEmpty) {
        _showSnack('Please enter the custom food type');
        return;
      }
    }

    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (qty < 10) {
      _showSnack('Minimum quantity is 10 meals');
      return;
    }
    if (_pickupTime == null) {
      _showSnack('Please select a pickup time');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showSnack('Please enter a pickup location');
      return;
    }

    // All good — Firestore save goes here later
    debugPrint('Food type: $finalFoodType');
    debugPrint('Qty: $qty | Pickup: $_pickupTime | Expiry: $_expiryTime');

    // Show success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          'Donate Food',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFoodTypeSelector(),
            const SizedBox(height: 24),
            _buildQuantityField(),
            const SizedBox(height: 24),
            _buildTimePicker(),
            const SizedBox(height: 24),
            _buildLocationField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // Food type grid — tap to select
  // ─────────────────────────────────────────
  Widget _buildFoodTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What food are you donating?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _foodTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final item = _foodTypes[index];
            final isSelected = _selectedFoodType == item['label'];

            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedFoodType = item['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['icon']!,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 6),
                    Text(
                      item['label']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedFoodType == 'Custom') ...[
          const SizedBox(height: 16),
          TextField(
            controller: _customFoodController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Describe the food (e.g. 50 packets of biscuits)',
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
      ],
    );
  }

  // ─────────────────────────────────────────
  // Quantity input
  // ─────────────────────────────────────────
  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Number of meals',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          'Minimum 10 meals',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'e.g. 50',
            prefixIcon: const Icon(Icons.people_outline,
                color: Color(0xFF2E7D32)),
            suffixText: 'meals',
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
  // Pickup time + auto expiry display
  // ─────────────────────────────────────────
  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup time',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _pickupTime != null
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade300,
                width: _pickupTime != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time,
                    color: Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                Text(
                  _pickupTime != null
                      ? _formatTime(_pickupTime!)
                      : 'Tap to select time',
                  style: TextStyle(
                    fontSize: 15,
                    color: _pickupTime != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Auto-calculated expiry badge
        if (_expiryTime != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 16, color: Color(0xFFF9A825)),
                const SizedBox(width: 8),
                Text(
                  'Post expires at ${_formatTime(_expiryTime!)}  (30 min before pickup)',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF795548)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────
  // Location input
  // ─────────────────────────────────────────
  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup location',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _locationController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'e.g. Hotel Royal, Anna Nagar, Chennai',
            prefixIcon: const Icon(Icons.location_on_outlined,
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
  // Submit button
  // ─────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.volunteer_activism, color: Colors.white),
        label: const Text(
          'Post Food Donation',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
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

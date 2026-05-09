import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class _DaySchedule {
  bool isOpen;
  TimeOfDay from;
  TimeOfDay to;
  _DaySchedule({required this.isOpen, required this.from, required this.to});
}

class SetupBusinessProfileScreen extends StatefulWidget {
  const SetupBusinessProfileScreen({super.key});

  @override
  State<SetupBusinessProfileScreen> createState() =>
      _SetupBusinessProfileScreenState();
}

class _SetupBusinessProfileScreenState
    extends State<SetupBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _specialityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  int _providerId = 0;

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  late Map<String, _DaySchedule> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = {
      for (final d in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
        d: _DaySchedule(
            isOpen: true,
            from: const TimeOfDay(hour: 8, minute: 0),
            to: const TimeOfDay(hour: 22, minute: 0)),
      'Saturday': _DaySchedule(
          isOpen: true,
          from: const TimeOfDay(hour: 8, minute: 0),
          to: const TimeOfDay(hour: 14, minute: 0)),
      'Sunday': _DaySchedule(
          isOpen: false,
          from: const TimeOfDay(hour: 8, minute: 0),
          to: const TimeOfDay(hour: 22, minute: 0)),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerId == 0) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _providerId = (args['provider_id'] as int?) ?? 0;
        final businessName = (args['business_name'] as String?) ?? '';
        if (_serviceNameController.text.isEmpty && businessName.isNotEmpty) {
          _serviceNameController.text = businessName;
        }
      }
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _specialityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _buildHoursJson() {
    final map = <String, dynamic>{};
    for (final day in _days) {
      final s = _schedule[day]!;
      map[day] = {'open': s.isOpen, 'from': _formatTime(s.from), 'to': _formatTime(s.to)};
    }
    return jsonEncode(map);
  }

  Future<void> _pickTime(String day, bool isFrom) async {
    final s = _schedule[day]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? s.from : s.to,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _schedule[day] = _DaySchedule(
          isOpen: s.isOpen,
          from: isFrom ? picked : s.from,
          to: isFrom ? s.to : picked,
        );
      });
    }
  }

  Future<void> _handleFinish() async {
    if (!_formKey.currentState!.validate()) return;

    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    setState(() => _isLoading = true);
    try {
      final currentId = _providerId != 0
          ? _providerId
          : (await ApiService.getCurrentUserId() ?? 0);

      await ApiService.createService(
        providerId: currentId,
        namaJasa: _serviceNameController.text.trim(),
        kategori: _specialityController.text.trim(),
        deskripsi: _descriptionController.text.trim(),
        hargaMulai: price,
        location: _locationController.text.trim(),
        operationalHours: _buildHoursJson(),
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/business_profile', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: brandBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Set Up Business Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Center(
                  child: Text('Set up your business profile',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),

                _buildLabel('Service Name*'),
                _buildField(
                  controller: _serviceNameController,
                  hint: 'e.g. Buana Phone Service',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel('Speciality / Category*'),
                _buildField(
                  controller: _specialityController,
                  hint: 'e.g. Phone Repair, Website, AC Service',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel('Starting Price (Rp)*'),
                _buildField(
                  controller: _priceController,
                  hint: 'e.g. 50000',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return 'Required';
                    if (int.tryParse(v) == null) return 'Enter a number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Description*'),
                _buildField(
                  controller: _descriptionController,
                  hint: 'Describe your service...',
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel('Location (optional)'),
                _buildField(
                  controller: _locationController,
                  hint: 'e.g. Jl. Sudirman No.1, Jakarta',
                ),
                const SizedBox(height: 24),

                _buildLabel('Operational Hours'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children:
                        _days.map((day) => _buildDayRow(day)).toList(),
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Finish',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4981FB), width: 2),
        ),
      ),
    );
  }

  Widget _buildDayRow(String day) {
    final s = _schedule[day]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 24,
            child: Transform.scale(
              scale: 0.65,
              child: Switch(
                value: s.isOpen,
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() {
                  _schedule[day] =
                      _DaySchedule(isOpen: val, from: s.from, to: s.to);
                }),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 72,
            child: Text(day,
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ),
          if (s.isOpen) ...[
            _buildTimeTap(_formatTime(s.from), () => _pickTime(day, true)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('-', style: TextStyle(fontSize: 11)),
            ),
            _buildTimeTap(_formatTime(s.to), () => _pickTime(day, false)),
          ] else
            const Text('Closed',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTimeTap(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ),
    );
  }
}

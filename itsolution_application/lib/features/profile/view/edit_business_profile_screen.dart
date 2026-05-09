import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';

class _DaySchedule {
  bool isOpen;
  TimeOfDay from;
  TimeOfDay to;
  _DaySchedule({required this.isOpen, required this.from, required this.to});
}

class EditBusinessProfileScreen extends StatefulWidget {
  const EditBusinessProfileScreen({super.key});

  @override
  State<EditBusinessProfileScreen> createState() =>
      _EditBusinessProfileScreenState();
}

class _EditBusinessProfileScreenState
    extends State<EditBusinessProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialityController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  bool _isLoading = true;
  bool _isSaving = false;
  int? _userId;
  int? _jasaId;
  String _avatarUrl = '';
  File? _pickedImage;

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  late Map<String, _DaySchedule> _schedule;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _specialityController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    _locationController = TextEditingController();
    _schedule = _defaultSchedule();
    _loadData();
  }

  Map<String, _DaySchedule> _defaultSchedule() => {
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialityController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userId =
          await ApiService.getBusinessUserId() ?? await ApiService.getCurrentUserId();
      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      _userId = userId;

      final userResult = await ApiService.getUserProfile(userId: userId);
      final user = userResult['user'];

      // Also load service data
      Map<String, dynamic> service = {};
      try {
        final svc = await ApiService.getMyService(userId);
        service = svc['service'] ?? {};
      } catch (_) {}

      if (mounted) {
        setState(() {
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phone'] ?? '';
          _avatarUrl = user['avatar_url'] ?? '';

          if (service.isNotEmpty) {
            _jasaId = (service['JasaID'] as num?)?.toInt();
            final namaJasa = service['NamaJasa']?.toString() ?? '';
            if (namaJasa.isNotEmpty) _nameController.text = namaJasa;
            _specialityController.text = service['Kategori']?.toString() ?? '';
            _priceController.text = service['HargaMulai']?.toString() ?? '';
            _descController.text = service['DeskripsiJasa']?.toString() ?? '';
            _locationController.text = service['location']?.toString() ?? '';
            _parseHours(service['operational_hours']?.toString() ?? '');
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseHours(String hoursJson) {
    if (hoursJson.isEmpty) return;
    try {
      final Map<String, dynamic> parsed = jsonDecode(hoursJson);
      for (final day in _days) {
        if (parsed.containsKey(day)) {
          final d = parsed[day] as Map<String, dynamic>;
          _schedule[day] = _DaySchedule(
            isOpen: d['open'] == true,
            from: _parseTime(d['from'] as String? ?? '08:00'),
            to: _parseTime(d['to'] as String? ?? '22:00'),
          );
        }
      }
    } catch (_) {}
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 8,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
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

  Future<void> _save() async {
    if (_userId == null) return;
    setState(() => _isSaving = true);
    try {
      String? newAvatarUrl;
      if (_pickedImage != null) {
        newAvatarUrl = await ApiService.uploadAvatar(_pickedImage!);
      }

      // Save user profile
      await ApiService.updateUserProfile(
        userId: _userId!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: newAvatarUrl,
      );

      // Save service location + hours if service exists
      if (_jasaId != null) {
        await ApiService.updateService(
          jasaId: _jasaId!,
          namaJasa: _nameController.text.trim(),
          kategori: _specialityController.text.trim(),
          hargaMulai: int.tryParse(_priceController.text.trim()),
          deskripsi: _descController.text.trim(),
          location: _locationController.text.trim(),
          operationalHours: _buildHoursJson(),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4981FB);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: brandBlue,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Edit Business Profile'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: _isSaving ? null : _save,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  minimumSize: const Size(60, 32),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF4981FB)),
                      )
                    : const Text('Save',
                        style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: brandBlue))
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildAvatarRow(),
                    const SizedBox(height: 24),
                    const Divider(height: 1, thickness: 1, color: Colors.grey),

                    // --- USER FIELDS ---
                    _buildInputRow('Business Name*', _nameController),
                    _buildInputRow('Email', _emailController, readOnly: true),
                    _buildInputRow('Phone Number', _phoneController),

                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 1, color: Colors.grey),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text('Service Info',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black54)),
                    ),

                    // --- SERVICE FIELDS ---
                    _buildInputRow('Speciality', _specialityController,
                        hint: 'e.g. Phone Repair, Web Dev'),
                    _buildInputRow('Price (Rp)', _priceController,
                        hint: 'e.g. 50000',
                        keyboardType: TextInputType.number),
                    _buildInputRow('Description', _descController,
                        hint: 'Describe your service...', maxLines: 3),

                    // --- LOCATION ---
                    _buildInputRow('Location', _locationController,
                        hint: 'e.g. Jl. Sudirman No.1, Jakarta'),

                    // --- OPERATIONAL HOURS ---
                    _buildHoursSection(),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!) as ImageProvider
                      : (_avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null),
                  child: (_pickedImage == null && _avatarUrl.isEmpty)
                      ? const Icon(Icons.business, size: 40)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Color(0xFF4981FB), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Text('Tap to change photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller,
      {bool readOnly = false,
      String? hint,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: TextStyle(
                  fontSize: 14,
                  color: readOnly ? Colors.grey : Colors.black54),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 130,
            child: Text('Hours',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black)),
          ),
          Expanded(
            child: Column(
              children: _days.map((day) => _buildDayRow(day)).toList(),
            ),
          ),
        ],
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
            width: 68,
            child: Text(day,
                style: const TextStyle(fontSize: 11, color: Colors.black87)),
          ),
          if (s.isOpen) ...[
            _buildTimeTap(_formatTime(s.from), () => _pickTime(day, true)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('-', style: TextStyle(fontSize: 10)),
            ),
            _buildTimeTap(_formatTime(s.to), () => _pickTime(day, false)),
          ] else
            const Text('Closed',
                style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTimeTap(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class _DaySchedule {
  bool isOpen;
  TimeOfDay from;
  TimeOfDay to;
  _DaySchedule({required this.isOpen, required this.from, required this.to});
}

class EditBusinessDetailsScreen extends StatefulWidget {
  const EditBusinessDetailsScreen({super.key});

  @override
  State<EditBusinessDetailsScreen> createState() =>
      _EditBusinessDetailsScreenState();
}

class _EditBusinessDetailsScreenState
    extends State<EditBusinessDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _specialityController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  bool _isSaving = false;
  int? _jasaId;
  bool _initialized = false;

  final List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  late Map<String, _DaySchedule> _schedule;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _specialityController = TextEditingController();
    _priceController = TextEditingController();
    _descController = TextEditingController();
    _locationController = TextEditingController();
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
    if (!_initialized) {
      _initialized = true;
      final service =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (service != null) {
        _jasaId = (service['JasaID'] as num?)?.toInt();
        _nameController.text = service['NamaJasa']?.toString() ?? '';
        _specialityController.text = service['Kategori']?.toString() ?? '';
        _priceController.text = service['HargaMulai']?.toString() ?? '';
        _descController.text = service['DeskripsiJasa']?.toString() ?? '';
        _locationController.text = service['location']?.toString() ?? '';

        final hoursJson = service['operational_hours']?.toString() ?? '';
        if (hoursJson.isNotEmpty) {
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
      }
    }
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0);
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _buildHoursJson() {
    final Map<String, dynamic> map = {};
    for (final day in _days) {
      final s = _schedule[day]!;
      map[day] = {
        'open': s.isOpen,
        'from': _formatTime(s.from),
        'to': _formatTime(s.to),
      };
    }
    return jsonEncode(map);
  }

  Future<void> _pickTime(String day, bool isFrom) async {
    final s = _schedule[day]!;
    final initial = isFrom ? s.from : s.to;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isFrom) {
          _schedule[day] = _DaySchedule(isOpen: s.isOpen, from: picked, to: s.to);
        } else {
          _schedule[day] = _DaySchedule(isOpen: s.isOpen, from: s.from, to: picked);
        }
      });
    }
  }

  Future<void> _save() async {
    if (_jasaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service ID not found'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ApiService.updateService(
        jasaId: _jasaId!,
        namaJasa: _nameController.text.trim(),
        kategori: _specialityController.text.trim(),
        hargaMulai: int.tryParse(_priceController.text.trim()),
        deskripsi: _descController.text.trim(),
        location: _locationController.text.trim(),
        operationalHours: _buildHoursJson(),
      );
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
  void dispose() {
    _nameController.dispose();
    _specialityController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
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
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Edit Business Details'),
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
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.only(
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            ),
            children: [
              _buildFormRow('Service Name*', _buildInput(controller: _nameController)),
              _buildFormRow('Speciality*', _buildInput(controller: _specialityController)),
              _buildFormRow(
                'Price (Rp)*',
                _buildInput(
                    controller: _priceController,
                    keyboardType: TextInputType.number),
              ),
              _buildFormRow('Description*',
                  _buildInput(controller: _descController, lines: 4)),
              _buildFormRow('Location',
                  _buildInput(controller: _locationController, hint: 'e.g. Jl. Sudirman No.1, Jakarta')),
              _buildFormRow(
                'Operational\nHours',
                Column(
                  children: _days.map((day) => _buildDayRow(day)).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, Widget content) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    int lines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      maxLines: lines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            width: 40,
            height: 24,
            child: Transform.scale(
              scale: 0.65,
              child: Switch(
                value: s.isOpen,
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() {
                  _schedule[day] = _DaySchedule(
                      isOpen: val, from: s.from, to: s.to);
                }),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 70,
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
            const Expanded(
              child: Text('Closed',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeTap(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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

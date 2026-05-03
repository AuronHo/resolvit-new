import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

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

  bool _isLoading = false;

  int _providerId = 0;
  String _businessName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerId == 0) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        _providerId = (args['provider_id'] as int?) ?? 0;
        _businessName = (args['business_name'] as String?) ?? '';
        if (_serviceNameController.text.isEmpty && _businessName.isNotEmpty) {
          _serviceNameController.text = _businessName;
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
    super.dispose();
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: brandBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Set Up Business Profile',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
                child: Text(
                  "Set up your business profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
}

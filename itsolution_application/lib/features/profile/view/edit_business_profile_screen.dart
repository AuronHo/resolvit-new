import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/api_service.dart';

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

  bool _isLoading = true;
  bool _isSaving = false;
  int? _userId;
  String _avatarUrl = '';
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
      final data = await ApiService.getUserProfile(userId: userId);
      final user = data['user'];
      if (mounted) {
        setState(() {
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phone'] ?? '';
          _avatarUrl = user['avatar_url'] ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
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
      await ApiService.updateUserProfile(
        userId: _userId!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: newAvatarUrl,
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
                    const SizedBox(height: 30),
                    const Divider(height: 1, thickness: 1, color: Colors.grey),
                    _buildInputRow('Business Name*', _nameController),
                    _buildInputRow('Email', _emailController, readOnly: true),
                    _buildInputRow('Phone Number', _phoneController),
                    const SizedBox(height: 50),
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
                      : (_avatarUrl.isNotEmpty
                          ? NetworkImage(_avatarUrl)
                          : null),
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
      {bool readOnly = false}) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
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
              style: TextStyle(
                  fontSize: 14,
                  color: readOnly ? Colors.grey : Colors.black54),
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
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
}

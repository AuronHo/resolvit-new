import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class RateServiceScreen extends StatefulWidget {
  const RateServiceScreen({super.key});

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  int _rating = 0;
  bool _isSubmitting = false;
  bool _isLoadingService = true;
  final TextEditingController _commentController = TextEditingController();

  int? _jasaId;
  String _jasaName = '';
  String _imageUrl = '';
  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _argsLoaded = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _jasaId = (args['jasaId'] as num?)?.toInt();
        _jasaName = args['jasaName']?.toString() ?? '';
        _imageUrl = args['imageUrl']?.toString() ?? '';
      }
      _loadService();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    if (_jasaId == null) {
      setState(() => _isLoadingService = false);
      return;
    }
    if (_jasaName.isNotEmpty) {
      setState(() => _isLoadingService = false);
      return;
    }
    try {
      final data = await ApiService.getServiceById(_jasaId!);
      final service = data['service'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _jasaName = service['NamaJasa']?.toString() ?? '';
          _imageUrl = service['ImageUrl']?.toString() ?? '';
          _isLoadingService = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingService = false);
    }
  }

  Future<void> _submit() async {
    if (_jasaId == null) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final userId = await ApiService.getCurrentUserId();
      if (userId == null) throw Exception('Not logged in');
      await ApiService.postReview(
        jasaId: _jasaId!,
        userId: userId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Rate Service',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        body: _isLoadingService
            ? const Center(
                child: CircularProgressIndicator(color: brandBlue))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        _jasaName.isNotEmpty ? _jasaName : 'Service',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Service avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                          image: _imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageUrl.isEmpty
                            ? const Icon(Icons.business,
                                size: 48, color: Colors.grey)
                            : null,
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        'How helpful was it?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      // Star rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              color: index < _rating
                                  ? Colors.amber
                                  : Colors.grey[300],
                              size: 36,
                            ),
                            onPressed: () =>
                                setState(() => _rating = index + 1),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Comment box
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Leave some comments',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

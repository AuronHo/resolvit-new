import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy & Terms'),
        backgroundColor: const Color(0xFF4981FB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Privacy Policy & Terms of Service'),
            _BodyText('Effective Date: January 1, 2025\n'),

            _Heading('1. Introduction'),
            _BodyText(
              'Welcome to Resolv IT ("we", "our", or "us"). By registering and using our application, '
              'you agree to be bound by these Terms of Service and our Privacy Policy. '
              'Please read them carefully before creating an account.',
            ),

            _Heading('2. Data We Collect'),
            _BodyText(
              'We collect the following personal information when you register or use our services:\n\n'
              '• Full name and email address\n'
              '• Phone number\n'
              '• Profile photo (optional)\n'
              '• Location data (for service matching)\n'
              '• Device information and usage data\n'
              '• Messages exchanged through our in-app chat',
            ),

            _Heading('3. How We Use Your Data'),
            _BodyText(
              'Your data is used to:\n\n'
              '• Create and manage your account\n'
              '• Match customers with service providers\n'
              '• Send notifications about bookings and messages\n'
              '• Improve app performance and features\n'
              '• Comply with legal obligations\n\n'
              'We do not sell your personal data to third parties.',
            ),

            _Heading('4. Data Security'),
            _BodyText(
              'We implement industry-standard security measures including encryption in transit (HTTPS) '
              'and secure password hashing. However, no method of transmission over the internet '
              'is 100% secure. You are responsible for keeping your account credentials confidential.',
            ),

            _Heading('5. User Responsibilities'),
            _BodyText(
              'By using Resolv IT, you agree to:\n\n'
              '• Provide accurate and truthful information\n'
              '• Not impersonate other users or entities\n'
              '• Not use the platform for illegal activities\n'
              '• Treat other users with respect\n'
              '• Not attempt to reverse-engineer or hack the platform',
            ),

            _Heading('6. Service Provider Terms'),
            _BodyText(
              'Service providers registered on Resolv IT acknowledge that:\n\n'
              '• All listed services must be legal and accurately described\n'
              '• Pricing must be transparent and as listed\n'
              '• Resolv IT is a marketplace platform and is not liable for the quality of services rendered\n'
              '• Providers are independent contractors, not employees of Resolv IT',
            ),

            _Heading('7. Cookies & Tracking'),
            _BodyText(
              'Our app may use local storage and session tokens to maintain your login state '
              'and improve user experience. We do not use third-party advertising trackers.',
            ),

            _Heading('8. Data Retention'),
            _BodyText(
              'We retain your data for as long as your account is active. '
              'You may request deletion of your account and associated data by contacting us. '
              'Some data may be retained for legal compliance purposes.',
            ),

            _Heading('9. Third-Party Services'),
            _BodyText(
              'Our platform may integrate with third-party services such as Google Sign-In. '
              'Use of these services is subject to their respective privacy policies.',
            ),

            _Heading('10. Changes to This Policy'),
            _BodyText(
              'We may update this policy from time to time. We will notify you of significant changes '
              'via the app or email. Continued use of the app after changes constitutes acceptance.',
            ),

            _Heading('11. Contact Us'),
            _BodyText(
              'For privacy-related questions or data deletion requests, contact us at:\n\n'
              'Email: support@resolvit.com\n'
              'Website: https://resolvit.com\n',
            ),

            SizedBox(height: 32),
            Center(
              child: Text(
                '© 2025 Resolv IT. All rights reserved.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4981FB),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black54,
        ),
      ),
    );
  }
}

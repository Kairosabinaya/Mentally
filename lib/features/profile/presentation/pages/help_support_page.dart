import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Contact Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emergency, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency Support',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you\'re experiencing a mental health crisis or having thoughts of self-harm, please reach out for immediate help:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Emergency Services: 119',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '• Sejiwa Crisis Line: 119 ext 8',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    '• BISA Helpline: +62 811 385 5472',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQ Section
            _buildSection(context, 'Frequently Asked Questions', Icons.help_outline, [
              _buildFAQItem(
                'How do I track my mood?',
                'Navigate to the mood tracking page from the home screen. Select your current mood, add any notes or triggers, and save your entry. You can track your mood multiple times per day.',
              ),
              _buildFAQItem(
                'How does the AI consultation work?',
                'Our AI consultation feature provides supportive conversations based on your mood and concerns. It\'s designed to offer coping strategies and resources, but it\'s not a replacement for professional therapy.',
              ),
              _buildFAQItem(
                'Is my data private and secure?',
                'Yes, we take your privacy seriously. All your personal data is encrypted and stored securely. We never share your personal information with third parties without your consent.',
              ),
              _buildFAQItem(
                'Can I delete my account?',
                'Yes, you can delete your account at any time. This will permanently remove all your data from our servers. Contact our support team for assistance with account deletion.',
              ),
              _buildFAQItem(
                'How do I use the audio therapy features?',
                'Go to the Audio Therapy section to access guided meditations, breathing exercises, and relaxation sounds. You can adjust playback speed and create custom playlists.',
              ),
            ]),

            const SizedBox(height: 24),

            // Contact Support Section
            _buildSection(context, 'Contact Support', Icons.support_agent, [
              _buildContactItem(
                context,
                Icons.email,
                'Email Support',
                'support@mentallyapp.com',
                'We typically respond within 24 hours',
              ),
              _buildContactItem(
                context,
                Icons.chat,
                'Live Chat',
                'Available 9 AM - 6 PM WIB',
                'Chat with our support team in real-time',
              ),
              _buildContactItem(
                context,
                Icons.phone,
                'Phone Support',
                '021-800-MENTALLY',
                'Available Monday - Friday, 9 AM - 5 PM WIB',
              ),
            ]),

            const SizedBox(height: 24),

            // Indonesian Mental Health Services Section
            _buildSection(
              context,
              'Indonesian Mental Health Services',
              Icons.local_hospital,
              [
                _buildResourceItem(
                  'Emergency Services 119',
                  'National emergency number for ambulance and Ministry of Health',
                  '119',
                ),
                _buildResourceItem(
                  'Puskesmas (Community Health Centers)',
                  'Local health centers with mental health services (Rp 5,000 - Rp 30,000)',
                  'Visit your nearest Puskesmas',
                ),
                _buildResourceItem(
                  'Halo Kemenkes Call Center',
                  'Ministry of Health hotline for information and nearest services',
                  '1500 567 or WhatsApp +62 812 6050 0567',
                ),
                _buildResourceItem(
                  'Sejiwa Mental Health Service',
                  'Government mental health service by RSJ dr. Soeharto Heerdjan',
                  '119 ext 8',
                ),
                _buildResourceItem(
                  'Yayasan Pulih',
                  'Non-profit organization offering individual, couple, and family counseling',
                  'WhatsApp +62 811 8436 633',
                ),
                _buildResourceItem(
                  'BISA Helpline',
                  'Support for addiction, self-harm, and suicide prevention',
                  'WhatsApp +62 811 385 5472',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mental Health Hospitals Section
            _buildSection(
              context,
              'Mental Health Hospitals (RSJ)',
              Icons.medical_services,
              [
                _buildResourceItem(
                  'RSJ Amino Gondohutomo Semarang',
                  'Specialized mental health hospital in Central Java',
                  'Semarang, Central Java',
                ),
                _buildResourceItem(
                  'RSJ Marzoeki Mahdi Bogor',
                  'Specialized mental health hospital in West Java',
                  'Bogor, West Java',
                ),
                _buildResourceItem(
                  'RSJ Soeharto Heerdjan Jakarta',
                  'Specialized mental health hospital in Jakarta',
                  'Jakarta',
                ),
                _buildResourceItem(
                  'RSJ Prof Dr Soerojo Magelang',
                  'Specialized mental health hospital in Central Java',
                  'Magelang, Central Java',
                ),
                _buildResourceItem(
                  'RSJ Radjiman Wediodiningrat Malang',
                  'Specialized mental health hospital in East Java',
                  'Malang, East Java',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Information
            _buildSection(context, 'App Information', Icons.info_outline, [
              _buildInfoItem('Version', '1.0.0'),
              _buildInfoItem('Last Updated', 'December 2024'),
              _buildInfoItem('Platform', 'Android, iOS, Web'),
              _buildInfoItem('Developer', 'Mentally Team'),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem(String title, String description, String contact) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            contact,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

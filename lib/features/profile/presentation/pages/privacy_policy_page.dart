import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Privacy Matters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Last updated: July 2025',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'We are committed to protecting your privacy and ensuring the security of your personal information. This policy explains how we collect, use, and protect your data.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Information We Collect
            _buildSection(context, '1. Information We Collect', [
              _buildSubSection(
                'Personal Information',
                'We collect information you provide when creating an account, including:\n\n• Name and email address\n• Profile information\n• Account preferences and settings',
              ),
              _buildSubSection(
                'Health and Mood Data',
                'To provide personalized mental health support, we collect:\n\n• Mood tracking entries\n• Journal entries and notes\n• Audio therapy usage patterns\n• AI consultation interactions\n• Wellness goals and progress',
              ),
              _buildSubSection(
                'Usage Information',
                'We automatically collect certain information about how you use our app:\n\n• App usage patterns and features accessed\n• Device information and operating system\n• Log data and error reports\n• Analytics data to improve our services',
              ),
            ]),

            const SizedBox(height: 24),

            // How We Use Your Information
            _buildSection(context, '2. How We Use Your Information', [
              _buildBulletPoint(
                'Provide personalized mental health support and recommendations',
              ),
              _buildBulletPoint(
                'Track your mood patterns and wellness progress',
              ),
              _buildBulletPoint(
                'Improve our AI consultation and therapy features',
              ),
              _buildBulletPoint(
                'Send you important updates about our services',
              ),
              _buildBulletPoint(
                'Ensure the security and proper functioning of our app',
              ),
              _buildBulletPoint(
                'Comply with legal obligations and protect user safety',
              ),
            ]),

            const SizedBox(height: 24),

            // Data Protection
            _buildSection(context, '3. Data Protection & Security', [
              _buildSubSection(
                'Encryption',
                'All sensitive data is encrypted both in transit and at rest using industry-standard encryption protocols.',
              ),
              _buildSubSection(
                'Access Controls',
                'We implement strict access controls to ensure only authorized personnel can access your data for legitimate business purposes.',
              ),
              _buildSubSection(
                'Regular Audits',
                'Our security practices are regularly audited and updated to maintain the highest standards of data protection.',
              ),
              _buildSubSection(
                'HIPAA Compliance',
                'While we are not a covered entity under HIPAA, we follow HIPAA-level security practices to protect your health information.',
              ),
            ]),

            const SizedBox(height: 24),

            // Information Sharing
            _buildSection(context, '4. Information Sharing', [
              _buildImportantNote(
                'We never sell your personal information to third parties.',
              ),
              const SizedBox(height: 12),
              const Text(
                'We may share your information only in the following limited circumstances:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildBulletPoint('With your explicit consent'),
              _buildBulletPoint(
                'To comply with legal obligations or court orders',
              ),
              _buildBulletPoint('To protect the safety of users or the public'),
              _buildBulletPoint(
                'With service providers who help us operate our app (under strict confidentiality agreements)',
              ),
              _buildBulletPoint(
                'In case of a business transfer (with continued privacy protection)',
              ),
            ]),

            const SizedBox(height: 24),

            // Your Rights
            _buildSection(context, '5. Your Privacy Rights', [
              _buildRightItem('Access', 'Request a copy of your personal data'),
              _buildRightItem(
                'Correction',
                'Update or correct your information',
              ),
              _buildRightItem(
                'Deletion',
                'Request deletion of your account and data',
              ),
              _buildRightItem(
                'Portability',
                'Export your data in a readable format',
              ),
              _buildRightItem(
                'Opt-out',
                'Unsubscribe from marketing communications',
              ),
              _buildRightItem('Restriction', 'Limit how we process your data'),
            ]),

            const SizedBox(height: 24),

            // Data Retention
            _buildSection(context, '6. Data Retention', [
              const Text(
                'We retain your information only as long as necessary to provide our services and comply with legal obligations:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('Account data: Until you delete your account'),
              _buildBulletPoint(
                'Mood and health data: Until you delete your account or request removal',
              ),
              _buildBulletPoint(
                'Usage analytics: Up to 2 years for service improvement',
              ),
              _buildBulletPoint(
                'Legal compliance data: As required by applicable laws',
              ),
            ]),

            const SizedBox(height: 24),

            // Children's Privacy
            _buildSection(context, '7. Children\'s Privacy', [
              const Text(
                'Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13. If we become aware that we have collected such information, we will delete it immediately.',
                style: TextStyle(fontSize: 16),
              ),
            ]),

            const SizedBox(height: 24),

            // International Transfers
            _buildSection(context, '8. International Data Transfers', [
              const Text(
                'Your data may be transferred to and processed in countries other than your own. We ensure that such transfers comply with applicable privacy laws and provide adequate protection for your data.',
                style: TextStyle(fontSize: 16),
              ),
            ]),

            const SizedBox(height: 24),

            // Updates to Policy
            _buildSection(context, '9. Updates to This Policy', [
              const Text(
                'We may update this privacy policy from time to time. We will notify you of any material changes by email or through our app. Your continued use of our services after such changes constitutes acceptance of the updated policy.',
                style: TextStyle(fontSize: 16),
              ),
            ]),

            const SizedBox(height: 24),

            // Contact Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '10. Contact Us',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'If you have any questions about this privacy policy or our data practices, please contact us:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Email: privacy@mentallyapp.com',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'Address: Jl. Raya Kb. Jeruk No.27, RT.1/RW.9, Kemanggisan, Kec. Palmerah, Kota Jakarta Barat, Daerah Khusus Ibukota Jakarta 11530',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Text(
                    'Phone: 1-800-MENTALLY',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

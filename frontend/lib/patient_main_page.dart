import 'package:flutter/material.dart';
import 'patient_profile.dart';

class PatientMainPage extends StatelessWidget {
  const PatientMainPage({super.key});

  static const Color _primaryRed = Color(0xFFE24B4A);
  static const Color _darkRed = Color(0xFFC0392B);
  static const Color _deepRed = Color(0xFFA32D2D);
  static const Color _pinkTitle = Color(0xFFC2185B);
  static const Color _pinkSub = Color(0xFFE57373);
  static const Color _pinkBorder = Color(0xFFF5C1C1);
  static const Color _pinkLight = Color(0xFFFFF0F0);
  static const Color _textMuted = Color(0xFFC0706F);
  static const Color _textDark = Color(0xFF3A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0F0), Color(0xFFFFE8E8), Color(0xFFFDECEA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildTabs(context),
                const SizedBox(height: 16),
                _buildHeroCard(context),
                const SizedBox(height: 16),
                _buildStats(),
                const SizedBox(height: 16),
                _buildWhyCard(),
                const SizedBox(height: 16),
                _buildBadges(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFCE4EC),
                Color(0xFFF8BBD0),
                Color(0xFFFFCDD2),
                Color(0xFFEF9A9A),
              ],
            ),
            border: Border.all(color: const Color(0xFFF48FB1), width: 1.5),
          ),
          child: const Icon(Icons.favorite, color: Color(0xFFF48FB1), size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              'منصة الأمل للتبرع بالأعضاء',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _pinkTitle,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'حياة جديدة تبدأ بقرارك',
              style: TextStyle(fontSize: 13, color: _pinkSub),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pinkBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(colors: [_primaryRed, _darkRed]),
              ),
              child: const Text(
                'الرئيسية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientFormPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'تسجيل محتاج',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonorSearchPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'استعلام متبرع',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [_primaryRed, _darkRed]),
      ),
      child: Column(
        children: [
          const Text(
            'كن بطلاً في حياة شخص آخر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قرارك بالتبرع يمكن أن ينقذ حياة الكثير',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientFormPage()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'سجل كمحتاج الآن',
                style: TextStyle(
                  color: _primaryRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        _statCard(
          number: '12,598',
          title: 'متبرع مسجل',
          icon: Icons.group_outlined,
          iconColor: const Color(0xFF43A047),
          iconBg: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFF43A047),
        ),
        const SizedBox(height: 10),
        _statCard(
          number: '3,892',
          title: 'حالات تم إنقاذها',
          icon: Icons.favorite_border,
          iconColor: const Color(0xFF1E88E5),
          iconBg: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF1E88E5),
        ),
        const SizedBox(height: 10),
        _statCard(
          number: '1,115',
          title: 'عمليات تمت هذا العام',
          icon: Icons.show_chart_rounded,
          iconColor: const Color(0xFF8E24AA),
          iconBg: const Color(0xFFF3E5F5),
          borderColor: const Color(0xFF8E24AA),
        ),
      ],
    );
  }

  Widget _statCard({
    required String number,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(right: BorderSide(color: borderColor, width: 4)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pinkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'لماذا التبرع بالأعضاء؟',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _pinkTitle,
            ),
          ),
          const SizedBox(height: 12),
          _whyItem(
            Icons.favorite_border,
            'إنقاذ حياة الآخرين',
            dotBg: const Color(0xFFFFF0F0),
            dotBorder: _pinkBorder,
            iconColor: _primaryRed,
          ),
          _whyItem(
            Icons.show_chart,
            'تحسين جودة الحياة',
            dotBg: const Color(0xFFE0F2F1),
            dotBorder: const Color(0xFFB2DFDB),
            iconColor: const Color(0xFF00897B),
          ),
          _whyItem(
            Icons.volunteer_activism,
            'فرصة للإنسانية والعطاء',
            dotBg: const Color(0xFFFFF3E0),
            dotBorder: const Color(0xFFFFE0B2),
            iconColor: const Color(0xFFFB8C00),
          ),
        ],
      ),
    );
  }

  Widget _whyItem(
    IconData icon,
    String text, {
    required Color dotBg,
    required Color dotBorder,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotBg,
              border: Border.all(color: dotBorder),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A2A2A)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _badge('آمن ومشفّر'),
        const SizedBox(width: 8),
        _badge('خصوصية تامة'),
      ],
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: _pinkLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pinkBorder, width: 0.5),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: _deepRed)),
    );
  }
}

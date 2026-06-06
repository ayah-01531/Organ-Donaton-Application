import 'package:flutter/material.dart';
import 'donor_main_page.dart';
import 'patient_main_page.dart';
import 'api_service.dart';
import 'Ministry_main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String selectedType = "";
  bool isLogin = true;
  bool _loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  static const Color _primaryRed = Color(0xFFE24B4A);
  static const Color _darkRed = Color(0xFFC0392B);
  static const Color _deepRed = Color(0xFFA32D2D);
  static const Color _pinkLight = Color(0xFFFCEBEB);
  static const Color _pinkBorder = Color(0xFFF5C1C1);
  static const Color _pinkMid = Color(0xFFF48FB1);
  static const Color _pinkSoft = Color(0xFFFFF9F9);
  static const Color _textMuted = Color(0xFFC0706F);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _pinkBorder, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: _primaryRed.withOpacity(0.10),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogoArea(),
                  const SizedBox(height: 20),
                  _buildTabRow(),
                  const SizedBox(height: 16),
                  if (!isLogin) ...[
                    _buildSectionLabel("نوع الحساب"),
                    const SizedBox(height: 8),
                    _buildTypeRow(),
                    const SizedBox(height: 16),
                  ],
                  if (isLogin) ...[
                    _buildTextField(
                      "البريد الإلكتروني",
                      emailController,
                      Icons.mail_outline,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      "كلمة المرور",
                      passwordController,
                      Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
                  const SizedBox(height: 16),
                  _buildBadges(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoArea() {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
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
            border: Border.all(color: _pinkMid, width: 2),
          ),
          child: const Icon(Icons.favorite, color: Color(0xFFF48FB1), size: 30),
        ),
        const SizedBox(height: 10),
        const Text(
          "منصة الأمل للتبرع بالأعضاء",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFC2185B),
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          "تبرّع بالحياة، أنقذ أرواحاً",
          style: TextStyle(fontSize: 13, color: Color(0xFFE57373)),
        ),
      ],
    );
  }

  Widget _buildTabRow() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _pinkLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pinkBorder, width: 0.5),
      ),
      child: Row(
        children: [
          _buildTab("تسجيل الدخول", true),
          _buildTab("إنشاء حساب", false),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool login) {
    final bool active = isLogin == login;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          isLogin = login;
          selectedType = "";
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: active
                ? const LinearGradient(colors: [_primaryRed, _darkRed])
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w500 : FontWeight.normal,
              color: active ? Colors.white : _textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: _textMuted),
      ),
    );
  }

  Widget _buildTypeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildAccountTypeCard("متبرع", "donor", Icons.person_outline),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAccountTypeCard(
            "مستشفى",
            "hospital",
            Icons.local_hospital,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard(String text, String type, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (type == 'donor') {
          Navigator.pushNamed(context, '/createDonor');
        } else {
          Navigator.pushNamed(context, '/createHospital');
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _pinkBorder, width: 1.5),
          color: _pinkSoft,
        ),
        child: Column(
          children: [
            Icon(icon, color: _textMuted, size: 22),
            const SizedBox(height: 6),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontSize: 14, color: Color(0xFF3A1A1A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFC8A0A0), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFD97C7C), size: 18),
        filled: true,
        fillColor: _pinkSoft,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _pinkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _loading ? null : _handleSubmit,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [_primaryRed, _darkRed]),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "تسجيل الدخول",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBadge("آمن ومشفّر"),
        const SizedBox(width: 8),
        _buildBadge("خصوصية تامة"),
      ],
    );
  }

  Widget _buildBadge(String text) {
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

  Future<void> _handleSubmit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _msg("املأ كل الحقول");
      return;
    }

    setState(() => _loading = true);

    final result = await ApiService.login(
      emailController.text.trim(),
      passwordController.text,
    );

    setState(() => _loading = false);

    if (result['success']) {
      final role = result['role'];
      if (role == 'Donor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DonorMainPage()),
        );
      } else if (role == 'HospitalAdmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PatientMainPage()),
        );
      } else if (role == 'MinistryAdmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MinistryApp()),
        );
      }
    } else {
      _msg(result['message'] ?? 'خطأ بتسجيل الدخول');
    }
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

import 'package:flutter/material.dart';
import 'api_service.dart';

class CreateDonorAccountPage extends StatefulWidget {
  const CreateDonorAccountPage({super.key});

  @override
  State<CreateDonorAccountPage> createState() => _DonorPageState();
}

class _DonorPageState extends State<CreateDonorAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _loading = false;

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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required VoidCallback onDone,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // ✅ زر الإغلاق
              GestureDetector(
                onTap: () {
                  Navigator.pop(dialogContext);
                  onDone();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE24B4A), Color(0xFFC0392B)],
                    ),
                  ),
                  child: const Text(
                    "إغلاق",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    try {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _loading = true);

      final result = await ApiService.registerDonor(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      setState(() => _loading = false);
      if (!mounted) return;

      if (result['success'] == true) {
        _showDialog(
          icon: Icons.mark_email_unread_outlined,
          iconColor: _primaryRed,
          title: 'تم التسجيل بنجاح!',
          message:
              'تم إرسال رابط التأكيد إلى بريدك الإلكتروني.\nتحقق من صندوق الوارد أو Spam.',
          onDone: () => Navigator.pushNamed(context, '/login'),
        );
      } else {
        _showDialog(
          icon: Icons.error_outline,
          iconColor: _primaryRed,
          title: 'حدث خطأ',
          message: result['message']?.toString() ?? 'خطأ بالتسجيل',
          onDone: () {},
        );
      }
    } catch (e) {
      debugPrint('ERROR: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Logo
                    Column(
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
                          child: const Icon(
                            Icons.favorite,
                            color: Color(0xFFF48FB1),
                            size: 30,
                          ),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFE57373),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Tabs
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _pinkLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _pinkBorder, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          // تسجيل الدخول
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Text(
                                  "تسجيل الدخول",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // إنشاء حساب (active)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(13),
                                gradient: const LinearGradient(
                                  colors: [_primaryRed, _darkRed],
                                ),
                              ),
                              child: const Text(
                                "إنشاء حساب",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── نوع الحساب
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "نوع الحساب",
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // متبرع (active)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _primaryRed,
                                width: 1.5,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFF0F0), Color(0xFFFFE4E4)],
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  color: _primaryRed,
                                  size: 22,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "متبرع",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _deepRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // مستشفى
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              '/createHospital',
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _pinkBorder,
                                  width: 1.5,
                                ),
                                color: _pinkSoft,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_hospital,
                                    color: _textMuted,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "مستشفى",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Fields
                    _buildTextField(
                      "الاسم الكامل",
                      nameController,
                      Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty)
                          ? "الرجاء إدخال الاسم"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      "البريد الإلكتروني",
                      emailController,
                      Icons.mail_outline,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return "الرجاء إدخال البريد الإلكتروني";
                        if (!v.contains("@")) return "بريد إلكتروني غير صالح";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      "كلمة المرور",
                      passwordController,
                      Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? "كلمة المرور يجب أن تكون 6 أحرف على الأقل"
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      "تأكيد كلمة المرور",
                      confirmPasswordController,
                      Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => v != passwordController.text
                          ? "كلمة المرور غير متطابقة"
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Submit
                    GestureDetector(
                      onTap: _loading ? null : _handleRegister,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [_primaryRed, _darkRed],
                          ),
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
                                  "إنشاء حساب متبرع",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge("آمن ومشفّر"),
                        const SizedBox(width: 8),
                        _buildBadge("خصوصية تامة"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
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
}

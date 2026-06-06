import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'donor_main_page.dart';

// ═══════════════════════════════════════════════════════
//  صفحة تتبع حالة طلب التبرع
// ═══════════════════════════════════════════════════════
class DonorTrackingPage extends StatelessWidget {
  final String donorName;
  final String bloodType;
  final List<String> organs;
  final String city;
  final String requestNumber;
  final String status; // UnderReview / Approved / Rejected
  final String registeredAt; // ISO date string

  const DonorTrackingPage({
    super.key,
    required this.donorName,
    required this.bloodType,
    required this.organs,
    required this.city,
    this.requestNumber = '',
    this.status = 'UnderReview',
    this.registeredAt = '',
  });

  static const Color _primaryRed = Color(0xFFE24B4A);
  static const Color _darkRed = Color(0xFFC0392B);
  static const Color _pinkTitle = Color(0xFFC2185B);
  static const Color _pinkSub = Color(0xFFE57373);
  static const Color _pinkBorder = Color(0xFFF5C1C1);
  static const Color _pinkLight = Color(0xFFFFF0F0);
  static const Color _textMuted = Color(0xFFC0706F);

  // خريطة الأعضاء عكسية (English → Arabic)
  static const Map<String, String> _orgAr = {
    'Heart': 'القلب',
    'KidneyLeft': 'الكلى اليسرى',
    'KidneyRight': 'الكلى اليمنى',
    'Liver': 'الكبد',
    'LungLeft': 'الرئة اليسرى',
    'LungRight': 'الرئة اليمنى',
    'Cornea': 'القرنية',
    'Pancreas': 'البنكرياس',
  };

  String _arabicOrgans() => organs.map((o) => _orgAr[o] ?? o).join('، ');

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    DateTime regDate = today;
    try {
      if (registeredAt.isNotEmpty) regDate = DateTime.parse(registeredAt);
    } catch (_) {}
    final dateStr = '${regDate.day} ${_monthAr(regDate.month)} ${regDate.year}';
    final reqNum = requestNumber.isNotEmpty
        ? requestNumber
        : 'DN-${today.year}-${today.millisecondsSinceEpoch % 100000}';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                  // ── Header
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // ── Tabs (تتبع الطلب محدد)
                  _buildTabs(context),
                  const SizedBox(height: 16),

                  // ── بطاقة تتبع المراحل
                  _buildTrackingCard(dateStr),
                  const SizedBox(height: 14),

                  // ── بطاقة بيانات المتبرع
                  _buildDonorCard(reqNum),
                  const SizedBox(height: 14),

                  // ── زر التواصل
                  _buildContactButton(),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'رقم الطلب: $reqNum',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      textDirection: TextDirection.rtl,
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

  // ── Tabs ─────────────────────────────────────────────
  Widget _buildTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pinkBorder, width: 0.5),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // الرئيسية
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DonorMainPage()),
                (r) => false,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'الرئيسية',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ),
            ),
          ),
          // تتبع الطلب (active)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(colors: [_primaryRed, _darkRed]),
              ),
              child: const Text(
                'تتبع الطلب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // معلومات عامة
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonorInfoPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'معلومات عامة',
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

  // ── تحويل الحالة لنص عربي
  String _statusLabel() {
    switch (status) {
      case 'Approved':
        return 'تمت الموافقة';
      case 'Rejected':
        return 'مرفوض';
      default:
        return 'قيد مراجعة وزارة الصحة';
    }
  }

  // ── بطاقة مراحل التتبع ──────────────────────────────
  Widget _buildTrackingCard(String dateStr) {
    final isApproved = status == 'Approved';
    final isRejected = status == 'Rejected';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pinkBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // عنوان البطاقة
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _pinkLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _pinkBorder),
                ),
                child: const Icon(
                  Icons.track_changes_outlined,
                  color: _primaryRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'تتبع حالة طلب التبرع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _pinkTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // وقت آخر تحديث
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.access_time, size: 12, color: _textMuted),
              const SizedBox(width: 4),
              Text(
                _statusLabel(),
                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── مراحل السير (تتغير حسب الـ status الفعلي)
          _step(
            index: 0,
            icon: Icons.check_circle,
            iconColor: const Color(0xFF43A047),
            bgColor: const Color(0xFFE8F5E9),
            title: 'استلام الطلب',
            subtitle: 'وصل طلبك بنجاح وتم حفظ بياناتك',
            tag: dateStr,
            tagColor: const Color(0xFF43A047),
            tagBg: const Color(0xFFE8F5E9),
            isFirst: true,
            lineActive: true,
          ),
          _step(
            index: 1,
            icon: isApproved
                ? Icons.check_circle
                : isRejected
                ? Icons.cancel
                : Icons.hourglass_top_rounded,
            iconColor: isApproved
                ? const Color(0xFF43A047)
                : isRejected
                ? Colors.red
                : _primaryRed,
            bgColor: isApproved
                ? const Color(0xFFE8F5E9)
                : isRejected
                ? const Color(0xFFFFEBEE)
                : _pinkLight,
            title: 'مراجعة وزارة الصحة',
            subtitle: isRejected
                ? 'تم رفض طلبك من قِبل الجهات المختصة'
                : 'الجهات المختصة تراجع بياناتك الشخصية والطبية للتحقق من الأهلية',
            tag: isApproved
                ? 'مكتمل'
                : isRejected
                ? 'مرفوض'
                : 'جارٍ الآن',
            tagColor: isApproved
                ? const Color(0xFF43A047)
                : isRejected
                ? Colors.red
                : _primaryRed,
            tagBg: isApproved
                ? const Color(0xFFE8F5E9)
                : isRejected
                ? const Color(0xFFFFEBEE)
                : _pinkLight,
            isFirst: false,
            lineActive: isApproved,
          ),
          _step(
            index: 2,
            icon: isApproved
                ? Icons.workspace_premium
                : Icons.workspace_premium_outlined,
            iconColor: isApproved
                ? const Color(0xFF43A047)
                : const Color(0xFFB0B0B0),
            bgColor: isApproved
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFF5F5F5),
            title: 'القبول كمتبرع رسمي',
            subtitle: isApproved
                ? 'تم قبولك وتسجيلك في قاعدة بيانات المتبرعين الرسمية'
                : 'سيتم إخطارك عند تسجيلك في قاعدة بيانات المتبرعين الرسمية',
            tag: isApproved ? 'مسجل رسمياً' : null,
            tagColor: const Color(0xFF43A047),
            tagBg: const Color(0xFFE8F5E9),
            isFirst: false,
            lineActive: false,
            dimmed: !isApproved,
          ),
        ],
      ),
    );
  }

  Widget _step({
    required int index,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String? tag,
    required Color tagColor,
    required Color tagBg,
    required bool isFirst,
    required bool lineActive,
    bool dimmed = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة + خط
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dimmed
                        ? const Color(0xFFDDDDDD)
                        : iconColor.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              if (!dimmed)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: lineActive
                          ? const Color(0xFF43A047)
                          : const Color(0xFFEEEEEE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // نص المرحلة
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: dimmed
                              ? const Color(0xFFB0B0B0)
                              : const Color(0xFF3A1A1A),
                        ),
                      ),
                      const Spacer(),
                      if (tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: tagColor.withOpacity(0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              color: tagColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 12,
                      color: dimmed
                          ? const Color(0xFFCCCCCC)
                          : const Color(0xFF8A5A5A),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة بيانات المتبرع المسجلة ──────────────────
  Widget _buildDonorCard(String reqNum) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pinkBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _pinkLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _pinkBorder),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: _primaryRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'بيانات التبرع المسجلة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _pinkTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _dataRow(Icons.person_outline, 'الاسم', donorName),
          _dataRow(Icons.bloodtype_outlined, 'فصيلة الدم', bloodType),
          _dataRow(Icons.location_city_outlined, 'المدينة', city),
          const SizedBox(height: 6),

          // الأعضاء كـ chips
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.favorite_border, color: _primaryRed, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: organs.map((o) {
                    final ar = _orgAr[o] ?? o;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _pinkLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _pinkBorder, width: 0.8),
                      ),
                      child: Text(
                        ar,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _primaryRed,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // label
              const Text(
                'الأعضاء المسجلة',
                style: TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: _primaryRed, size: 16),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF3A1A1A)),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── زر التواصل ──────────────────────────────────────
  Widget _buildContactButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _pinkBorder),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: const [
                Icon(
                  Icons.support_agent_outlined,
                  color: _primaryRed,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'تواصل مع وزارة الصحة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthAr(int m) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[m];
  }
}

// ═══════════════════════════════════════════════════════
//  DonorScreen  (نموذج التسجيل — معدّل)
// ═══════════════════════════════════════════════════════
class DonorScreen extends StatefulWidget {
  const DonorScreen({super.key});

  @override
  State<DonorScreen> createState() => _DonorScreenState();
}

class _DonorScreenState extends State<DonorScreen> {
  static const Color _primaryRed = Color(0xFFE24B4A);
  static const Color _darkRed = Color(0xFFC0392B);
  static const Color _pinkTitle = Color(0xFFC2185B);
  static const Color _pinkSub = Color(0xFFE57373);
  static const Color _pinkBorder = Color(0xFFF5C1C1);
  static const Color _pinkSoft = Color(0xFFFFF9F9);
  static const Color _pinkLight = Color(0xFFFFF0F0);
  static const Color _textMuted = Color(0xFFC0706F);

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  final cityController = TextEditingController();

  DateTime? selectedDate;
  String? bloodType;
  String? fileName;
  bool _loading = false;

  File? healthDocumentMobile;
  Uint8List? healthDocumentWeb;

  final Map<String, String> organsMap = {
    'القلب': 'Heart',
    'الكلى اليسرى': 'KidneyLeft',
    'الكلى اليمنى': 'KidneyRight',
    'الكبد': 'Liver',
    'الرئة اليسرى': 'LungLeft',
    'الرئة اليمنى': 'LungRight',
    'القرنية': 'Cornea',
    'البنكرياس': 'Pancreas',
  };

  List<String> selectedOrgans = [];
  bool _checkingDonor = true; // loading أثناء التحقق

  bool get hasDocument =>
      kIsWeb ? healthDocumentWeb != null : healthDocumentMobile != null;

  @override
  void initState() {
    super.initState();
    _checkExistingDonor();
  }

  /// تتحقق من الـ API إذا المستخدم مسجل متبرع مسبقاً
  Future<void> _checkExistingDonor() async {
    try {
      final result = await ApiService.getDonorStatus();
      if (!mounted) return;

      if (result['exists'] == true) {
        // المستخدم عنده طلب مسجل → روّح لصفحة التتبع مباشرة
        final data = result['donor'] ?? {};
        final List<String> organs = List<String>.from(
          (data['organsToDonat'] as String? ?? '')
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DonorTrackingPage(
              donorName: data['fullName'] ?? '',
              bloodType: data['bloodType'] ?? '',
              organs: organs,
              city: data['address'] ?? '',
              requestNumber: data['id']?.toString() ?? '',
              status: data['status'] ?? 'UnderReview',
              registeredAt: data['registeredAt'] ?? '',
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // لو فشل الـ call خلّي الفورم يفتح عادي
    }

    if (mounted) setState(() => _checkingDonor = false);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    idController.dispose();
    cityController.dispose();
    super.dispose();
  }

  // ── موديل تأكيد الإرسال فقط (حُذف موديل "مسجل مسبقاً")
  Future<bool> _showConfirmDialog() async {
    final organsAr = selectedOrgans.take(2).join('، ');
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Directionality(
            textDirection: TextDirection.rtl,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF0F0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_outlined,
                        color: _primaryRed,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'تأكيد إرسال الطلب',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA32D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'هل أنت متأكد من إرسال بيانات التبرع؟ لن تتمكن من تعديلها بعد الإرسال.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF7C1C1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              const Icon(
                                Icons.person_outline,
                                color: _primaryRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                nameController.text,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF791F1F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              const Icon(
                                Icons.bloodtype_outlined,
                                color: _primaryRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'فصيلة الدم: $bloodType',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF791F1F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                color: _primaryRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'الأعضاء: $organsAr'
                                  '${selectedOrgans.length > 2 ? ' ...' : ''}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF791F1F),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'إرسال الطلب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFEEEEEE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'تعديل',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  // ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // بينما بيتحقق من السيرفر أظهر شاشة تحميل
    if (_checkingDonor) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF0F0),
                  Color(0xFFFFE8E8),
                  Color(0xFFFDECEA),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: _primaryRed,
                strokeWidth: 2.5,
              ),
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildTabs(context),
                    const SizedBox(height: 16),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      textDirection: TextDirection.rtl,
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
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _pinkTitle,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'حياة جديدة تبدأ بقرارك',
              textDirection: TextDirection.rtl,
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
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DonorMainPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'الرئيسية',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: const LinearGradient(colors: [_primaryRed, _darkRed]),
              ),
              child: const Text(
                'تسجيل متبرع',
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
                MaterialPageRoute(builder: (_) => const DonorInfoPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Text(
                  'معلومات عامة',
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

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _pinkBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _pinkLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _pinkBorder),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  color: _primaryRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'بيانات المتبرع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _pinkTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _divider(
            'المعلومات الشخصية',
            Icons.person_outline,
            const Color(0xFF43A047),
            const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 10),
          _input(nameController, 'الاسم الكامل', Icons.person_outline),
          _input(
            emailController,
            'البريد الإلكتروني',
            Icons.mail_outline,
            isEmail: true,
          ),
          _input(
            phoneController,
            'رقم الهاتف',
            Icons.phone_outlined,
            isPhone: true,
          ),
          _input(idController, 'رقم الهوية', Icons.badge_outlined),
          _input(cityController, 'المدينة', Icons.location_city_outlined),
          _datePicker(),
          const SizedBox(height: 12),
          _divider(
            'المعلومات الطبية',
            Icons.medical_services_outlined,
            const Color(0xFF1E88E5),
            const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 10),
          _bloodDropdown(),
          _documentPicker(),
          const SizedBox(height: 12),
          _divider(
            'الأعضاء المراد التبرع بها',
            Icons.favorite_border,
            _primaryRed,
            _pinkLight,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: organsMap.keys.map((o) => _organChip(o)).toList(),
          ),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _divider(String title, IconData icon, Color iconColor, Color iconBg) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: _pinkBorder, thickness: 0.8)),
      ],
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        keyboardType: isPhone
            ? TextInputType.phone
            : isEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        validator: (v) {
          if (v == null || v.isEmpty) return 'الحقل مطلوب';
          if (isEmail && !v.contains('@')) return 'بريد غير صالح';
          if (isPhone && v.length < 9) return 'رقم غير صالح';
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFFD97C7C), size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFC8A0A0), fontSize: 14),
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
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          initialDate: DateTime(2000),
        );
        if (picked != null) setState(() => selectedDate = picked);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _pinkSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _pinkBorder, width: 1.5),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFD97C7C),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              selectedDate == null
                  ? 'تاريخ الميلاد'
                  : '${selectedDate!.year}-'
                        '${selectedDate!.month.toString().padLeft(2, '0')}-'
                        '${selectedDate!.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: selectedDate == null
                    ? const Color(0xFFC8A0A0)
                    : const Color(0xFF3A1A1A),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentPicker() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _pinkSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDocument ? _primaryRed : _pinkBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              hasDocument
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              color: hasDocument ? _primaryRed : const Color(0xFFD97C7C),
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                fileName ?? 'إرفاق تقرير طبي (PDF أو صورة)',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasDocument
                      ? const Color(0xFF3A1A1A)
                      : const Color(0xFFC8A0A0),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: kIsWeb,
    );
    if (result != null) {
      final file = result.files.single;
      setState(() {
        fileName = file.name;
        if (kIsWeb) {
          healthDocumentWeb = file.bytes;
        } else {
          healthDocumentMobile = File(file.path!);
        }
      });
    }
  }

  Widget _bloodDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: bloodType,
        items: [
          'A+',
          'A-',
          'B+',
          'B-',
          'O+',
          'O-',
          'AB+',
          'AB-',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) => setState(() => bloodType = val),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.bloodtype_outlined,
            color: Color(0xFFD97C7C),
            size: 18,
          ),
          hintText: 'فصيلة الدم',
          hintStyle: const TextStyle(color: Color(0xFFC8A0A0), fontSize: 14),
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
        validator: (v) => v == null ? 'اختر فصيلة الدم' : null,
      ),
    );
  }

  Widget _organChip(String organ) {
    final bool isSelected = selectedOrgans.contains(organ);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? selectedOrgans.remove(organ) : selectedOrgans.add(organ);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _primaryRed : _pinkSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryRed : _pinkBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          organ,
          style: TextStyle(
            color: isSelected ? Colors.white : _textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _loading ? null : _submit,
      child: Container(
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
                  'حفظ البيانات',
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      _showMsg('اختر تاريخ الميلاد');
      return;
    }
    if (selectedOrgans.isEmpty) {
      _showMsg('اختر عضو واحد على الأقل');
      return;
    }
    if (!hasDocument) {
      _showMsg('أرفق التقرير الطبي أولاً');
      return;
    }

    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _loading = true);

    final organsEn = selectedOrgans.map((o) => organsMap[o]!).toList();

    final result = await ApiService.applyDonor(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      nationalId: idController.text.trim(),
      bloodType: bloodType!,
      dateOfBirth: selectedDate!.toIso8601String(),
      address: cityController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      organs: organsEn,
    );

    // ── إذا فشل الطلب (غير "مسجل مسبقاً") أظهر رسالة خطأ فقط
    if (!result['success'] && result['alreadyRegistered'] != true) {
      setState(() => _loading = false);
      _showMsg(result['message'] ?? 'خطأ بالتسجيل');
      return;
    }

    // ── رفع الملف الطبي
    final uploadResult = kIsWeb
        ? await ApiService.uploadMedicalReport(
            null,
            webBytes: healthDocumentWeb,
            fileName: fileName,
          )
        : await ApiService.uploadMedicalReport(healthDocumentMobile);

    setState(() => _loading = false);

    if (!uploadResult['success']) {
      _showMsg('تم حفظ البيانات لكن فشل رفع الملف، حاول مرة ثانية');
      return;
    }

    // ✅ انتقل مباشرة لصفحة التتبع بدل SuccessPage
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DonorTrackingPage(
          donorName: nameController.text.trim(),
          bloodType: bloodType!,
          organs: organsEn,
          city: cityController.text.trim(),
          requestNumber: result['requestNumber'] ?? '',
        ),
      ),
      (route) => false, // يمسح كل الـ stack → المستخدم لا يقدر يرجع للفورم
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ═══════════════════════════════════════════════════════
//  صفحة المعلومات العامة (بدون تغيير)
// ═══════════════════════════════════════════════════════
class DonorInfoPage extends StatelessWidget {
  const DonorInfoPage({super.key});

  static const Color _primaryRed = Color(0xFFE24B4A);
  static const Color _darkRed = Color(0xFFC0392B);
  static const Color _pinkTitle = Color(0xFFC2185B);
  static const Color _pinkSub = Color(0xFFE57373);
  static const Color _pinkBorder = Color(0xFFF5C1C1);
  static const Color _pinkLight = Color(0xFFFFF0F0);
  static const Color _textMuted = Color(0xFFC0706F);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                  Row(
                    textDirection: TextDirection.rtl,
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
                          border: Border.all(
                            color: const Color(0xFFF48FB1),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Color(0xFFF48FB1),
                          size: 22,
                        ),
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
                            'معلومات عامة عن التبرع',
                            style: TextStyle(fontSize: 13, color: _pinkSub),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _pinkBorder, width: 0.5),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DonorMainPage(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text(
                                'الرئيسية',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DonorScreen(),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: const Text(
                                'تسجيل متبرع',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              gradient: const LinearGradient(
                                colors: [_primaryRed, _darkRed],
                              ),
                            ),
                            child: const Text(
                              'معلومات عامة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
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
                  _infoCard(
                    'ما هو التبرع بالأعضاء؟',
                    Icons.info_outline,
                    const Color(0xFF1E88E5),
                    const Color(0xFFE3F2FD),
                    'التبرع بالأعضاء هو عملية نقل عضو أو نسيج من شخص متبرع إلى شخص محتاج. يمكن أن يُنقذ هذا القرار حياة أشخاص يعانون من فشل الأعضاء.',
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    'من يستطيع التبرع؟',
                    Icons.person_outline,
                    const Color(0xFF43A047),
                    const Color(0xFFE8F5E9),
                    'يمكن لأي شخص بالغ يتمتع بصحة جيدة أن يتبرع. يتم إجراء فحوصات طبية للتأكد من التوافق بين المتبرع والمستفيد.',
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    'الأعضاء التي يمكن التبرع بها',
                    Icons.favorite_border,
                    _primaryRed,
                    _pinkLight,
                    'القلب، الكبد، الكليتان، الرئتان، البنكرياس، القرنية، والأنسجة المختلفة. كل عضو يمكنه إنقاذ أو تحسين حياة شخص آخر.',
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    'كيف تعمل العملية؟',
                    Icons.medical_services_outlined,
                    const Color(0xFF8E24AA),
                    const Color(0xFFF3E5F5),
                    'بعد التسجيل، يتم مراجعة بياناتك من قبل الفريق الطبي. في حال التوافق مع محتاج، يتم التواصل معك لإكمال الإجراءات اللازمة.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _badge('آمن ومشفّر'),
                      const SizedBox(width: 8),
                      _badge('خصوصية تامة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    String title,
    IconData icon,
    Color iconColor,
    Color iconBg,
    String body,
  ) {
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
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5A2A2A),
              height: 1.6,
            ),
          ),
        ],
      ),
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFFA32D2D)),
      ),
    );
  }
}

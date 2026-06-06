import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'api_service.dart';
import 'success_page.dart';
import 'patient_main_page.dart';

// ══════════════════════════════════════════════════════════
//  ألوان مشتركة
// ══════════════════════════════════════════════════════════
class _AppColors {
  static const Color primaryRed = Color(0xFFE24B4A);
  static const Color darkRed = Color(0xFFC0392B);
  static const Color pinkTitle = Color(0xFFC2185B);
  static const Color pinkSub = Color(0xFFE57373);
  static const Color pinkBorder = Color(0xFFF5C1C1);
  static const Color pinkSoft = Color(0xFFFFF9F9);
  static const Color pinkLight = Color(0xFFFFF0F0);
  static const Color textMuted = Color(0xFFC0706F);
  static const Color textDark = Color(0xFF3A1A1A);
}

// ══════════════════════════════════════════════════════════
//  ويدجت التبويبات المشتركة
// ══════════════════════════════════════════════════════════
class _SharedTabBar extends StatelessWidget {
  final int selectedTab;
  final BuildContext pageContext;

  const _SharedTabBar({required this.selectedTab, required this.pageContext});

  void _navigate(int index) {
    if (index == selectedTab) return;
    if (index == 0) {
      Navigator.pushReplacement(
        pageContext,
        MaterialPageRoute(builder: (_) => const PatientMainPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        pageContext,
        MaterialPageRoute(builder: (_) => const PatientFormPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        pageContext,
        MaterialPageRoute(builder: (_) => const DonorSearchPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['الرئيسية', 'تسجيل محتاج', 'استعلام متبرع'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.5),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => _navigate(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [_AppColors.primaryRed, _AppColors.darkRed],
                        )
                      : null,
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: isSelected ? Colors.white : _AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  صفحة تسجيل محتاج
// ══════════════════════════════════════════════════════════
class PatientFormPage extends StatefulWidget {
  const PatientFormPage({super.key});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nationalIdController = TextEditingController();

  String? selectedBloodType;
  String? selectedOrgan;
  File? medicalDocument;
  String? fileName;
  bool _loading = false;

  final Map<String, String> organsMap = {
    'الكلى': 'KidneyLeft',
    'القلب': 'Heart',
    'الكبد': 'Liver',
    'البنكرياس': 'Pancreas',
    'الرئتين': 'LungLeft',
    'القرنية': 'Cornea',
  };

  @override
  void dispose() {
    nameController.dispose();
    nationalIdController.dispose();
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildHeader(),
                  ),
                  _SharedTabBar(selectedTab: 1, pageContext: context),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: _buildFormCard(),
                  ),
                ],
              ),
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
                color: _AppColors.pinkTitle,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'حياة جديدة تبدأ بقرارك',
              style: TextStyle(fontSize: 13, color: _AppColors.pinkSub),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primaryRed.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _AppColors.pinkLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _AppColors.pinkBorder),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: _AppColors.primaryRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'تسجيل محتاج للتبرع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _AppColors.pinkTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionDivider(
            'المعلومات الشخصية',
            Icons.person_outline,
            const Color(0xFF43A047),
            const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 10),
          _inputField(
            controller: nameController,
            hint: 'اسم المريض الكامل',
            icon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.isEmpty) return 'الرجاء إدخال الاسم';
              if (v.length < 3) return 'الاسم قصير جداً';
              return null;
            },
          ),
          _inputField(
            controller: nationalIdController,
            hint: 'رقم الهوية الوطنية',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'أدخل رقم الهوية';
              return null;
            },
          ),
          _sectionDivider(
            'المعلومات الطبية',
            Icons.medical_services_outlined,
            const Color(0xFF1E88E5),
            const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DropdownButtonFormField<String>(
              value: selectedBloodType,
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
              onChanged: (val) => setState(() => selectedBloodType = val),
              decoration: _inputDecoration(
                'فصيلة الدم',
                Icons.bloodtype_outlined,
              ),
              validator: (v) => v == null ? 'اختر فصيلة الدم' : null,
            ),
          ),
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: medicalDocument != null
                      ? _AppColors.primaryRed
                      : _AppColors.pinkBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    medicalDocument != null
                        ? Icons.check_circle_outline
                        : Icons.upload_file_outlined,
                    color: medicalDocument != null
                        ? _AppColors.primaryRed
                        : const Color(0xFFD97C7C),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileName ?? 'إرفاق تقرير طبي (PDF أو صورة)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: medicalDocument != null
                            ? _AppColors.textDark
                            : const Color(0xFFC8A0A0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _sectionDivider(
            'العضو المطلوب',
            Icons.favorite_border,
            _AppColors.primaryRed,
            _AppColors.pinkLight,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: organsMap.keys.map(_organChip).toList(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [_AppColors.primaryRed, _AppColors.darkRed],
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
                        'إرسال الطلب',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider(String title, IconData icon, Color color, Color bg) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: _AppColors.pinkBorder, thickness: 0.8)),
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _inputDecoration(hint, icon),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFFD97C7C), size: 18),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC8A0A0), fontSize: 14),
      filled: true,
      fillColor: _AppColors.pinkSoft,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.pinkBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _AppColors.primaryRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _organChip(String organ) {
    final bool isSelected = selectedOrgan == organ;
    return GestureDetector(
      onTap: () => setState(() => selectedOrgan = organ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? _AppColors.primaryRed : _AppColors.pinkSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _AppColors.primaryRed : _AppColors.pinkBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          organ,
          style: TextStyle(
            color: isSelected ? Colors.white : _AppColors.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedOrgan == null) {
      _msg('اختر العضو المطلوب');
      return;
    }
    if (medicalDocument == null) {
      _msg('أرفق التقرير الطبي أولاً');
      return;
    }

    setState(() => _loading = true);
    final result = await ApiService.addPatientNeed(
      patientName: nameController.text.trim(),
      bloodType: selectedBloodType!,
      neededOrgan: organsMap[selectedOrgan!]!,
      nationalId: nationalIdController.text.trim(),
    );
    setState(() => _loading = false);

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
      );
    } else {
      _msg(result['message'] ?? 'خطأ بالتسجيل');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() {
        medicalDocument = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

// ══════════════════════════════════════════════════════════
//  صفحة استعلام متبرع
// ══════════════════════════════════════════════════════════
class DonorSearchPage extends StatefulWidget {
  const DonorSearchPage({super.key});

  @override
  State<DonorSearchPage> createState() => _DonorSearchPageState();
}

class _DonorSearchPageState extends State<DonorSearchPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  Map<String, dynamic>? _donorData;
  String? _errorMsg;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final id = _searchController.text.trim();
    if (id.isEmpty) {
      _showMsg('أدخل رقم الهوية أولاً');
      return;
    }

    setState(() {
      _isSearching = true;
      _donorData = null;
      _errorMsg = null;
    });
    _animCtrl.reset();

    final result = await ApiService.searchDonorByNationalId(id);
    setState(() => _isSearching = false);

    if (result['success']) {
      setState(() => _donorData = result['data']);
      _animCtrl.forward();
    } else {
      setState(() => _errorMsg = result['message']);
    }
  }

  void _showMsg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  void _openDetails() {
    if (_donorData == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DonorDetailsPage(donor: _donorData!)),
    ).then((_) => _search());
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: _buildHeader(),
                ),
                _SharedTabBar(selectedTab: 2, pageContext: context),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _buildSearchCard(),
                      const SizedBox(height: 12),
                      if (_isSearching) _buildLoading(),
                      if (_errorMsg != null) _buildError(),
                      if (_donorData != null) _buildResultCard(),
                    ],
                  ),
                ),
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
          child: const Icon(Icons.search, color: Color(0xFFF48FB1), size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              'استعلام متبرع',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AppColors.pinkTitle,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'ابحث بالرقم الوطني للتحقق من تسجيل التبرع',
              style: TextStyle(fontSize: 12, color: _AppColors.pinkSub),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primaryRed.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _AppColors.pinkLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _AppColors.pinkBorder),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: _AppColors.primaryRed,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'البحث بالرقم الوطني',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _AppColors.pinkTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _isSearching ? null : _search,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _AppColors.primaryRed,
                  ),
                  child: _isSearching
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _AppColors.textDark,
                  ),
                  textAlign: TextAlign.right,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'أدخل الرقم الوطني للمتبرع',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: const TextStyle(
                      color: Color(0xFFC8A0A0),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.tag,
                      color: Color(0xFFD97C7C),
                      size: 17,
                    ),
                    filled: true,
                    fillColor: _AppColors.pinkSoft,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _AppColors.pinkBorder,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _AppColors.primaryRed,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.5),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: _AppColors.primaryRed,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 10),
          Text(
            'جاري البحث...',
            style: TextStyle(color: _AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AppColors.pinkBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: _AppColors.primaryRed,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMsg ?? 'لم يتم العثور على متبرع بهذا الرقم',
              style: const TextStyle(color: _AppColors.textDark, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: _buildDonorCard(_donorData!),
      ),
    );
  }

  Widget _buildDonorCard(Map<String, dynamic> donor) {
    final String status = (donor['status'] ?? '').toString().toLowerCase();
    final bool isDeceased = status == 'deceased' || status == 'متوفي';

    return GestureDetector(
      onTap: _openDetails,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.pinkBorder, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        donor['fullName'] ?? '—',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'رقم الهوية: ${donor['nationalId'] ?? '—'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDeceased
                        ? Colors.grey.shade100
                        : const Color(0xFFFCE4EC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDeceased ? Icons.person_off_outlined : Icons.person,
                    color: isDeceased
                        ? Colors.grey.shade400
                        : _AppColors.primaryRed,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _statusBadge(donor['status']),
                const Spacer(),
                if ((donor['phoneNumber'] ?? '').toString().isNotEmpty)
                  _infoChip(Icons.phone_outlined, donor['phoneNumber']!),
                const SizedBox(width: 6),
                if ((donor['address'] ?? '').toString().isNotEmpty)
                  _infoChip(Icons.location_on_outlined, donor['address']!),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _AppColors.primaryRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'عرض التفاصيل الكاملة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String? status) {
    final s = (status ?? '').toLowerCase();
    Color bg, textColor, borderColor;
    String label;
    IconData icon;

    if (s == 'available' || s == 'متاح') {
      bg = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      borderColor = const Color(0xFFA5D6A7);
      label = 'متاح للتبرع';
      icon = Icons.check_circle_outline;
    } else if (s == 'deceased' || s == 'متوفي') {
      bg = Colors.grey.shade100;
      textColor = Colors.grey.shade600;
      borderColor = Colors.grey.shade300;
      label = 'متوفي';
      icon = Icons.remove_circle_outline;
    } else if (s == 'pending' || s == 'قيد المراجعة') {
      bg = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFF57F17);
      borderColor = const Color(0xFFFFE082);
      label = 'قيد المراجعة';
      icon = Icons.hourglass_top_outlined;
    } else {
      bg = _AppColors.pinkLight;
      textColor = _AppColors.primaryRed;
      borderColor = _AppColors.pinkBorder;
      label = status ?? '—';
      icon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _AppColors.pinkSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: _AppColors.textDark),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  صفحة تفاصيل المتبرع + تسجيل الوفاة
// ══════════════════════════════════════════════════════════
class DonorDetailsPage extends StatefulWidget {
  final Map<String, dynamic> donor;
  const DonorDetailsPage({super.key, required this.donor});

  @override
  State<DonorDetailsPage> createState() => _DonorDetailsPageState();
}

class _DonorDetailsPageState extends State<DonorDetailsPage> {
  bool _submitting = false;
  File? _certMobile;
  Uint8List? _certWeb;
  String? _certName;

  bool get _isDeceased {
    final s = (widget.donor['status'] ?? '').toString().toLowerCase();
    return s == 'deceased' || s == 'متوفي';
  }

  bool get _hasCert => kIsWeb ? _certWeb != null : _certMobile != null;

  Future<void> _pickCert() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: kIsWeb,
    );
    if (result != null) {
      final f = result.files.single;
      setState(() {
        _certName = f.name;
        if (kIsWeb) {
          _certWeb = f.bytes;
        } else {
          _certMobile = File(f.path!);
        }
      });
    }
  }

  void _confirmDeath() {
    if (!_hasCert) {
      _msg('أرفق شهادة الوفاة أولاً');
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'تأكيد تسجيل الوفاة',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل وفاة ${widget.donor['fullName'] ?? 'المتبرع'}؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _submitDeath();
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDeath() async {
    setState(() => _submitting = true);
    final result = await ApiService.markDonorAsDeceased(
      nationalId: widget.donor['nationalId'],
      deathCertFile: _certMobile,
      webBytes: _certWeb,
      fileName: _certName,
    );
    setState(() => _submitting = false);
    if (result['success']) {
      _showSuccessDialog();
    } else {
      _msg(result['message'] ?? 'حدث خطأ، حاول مجدداً');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF43A047),
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم تحديث الحالة بنجاح',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تم تسجيل وفاة المتبرع وتحديث حالته إلى "متاح للتبرع"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'حسناً',
              style: TextStyle(color: _AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }

  void _msg(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final donor = widget.donor;
    final List organs = donor['organsToDonat'] ?? donor['organs'] ?? [];

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
                _buildIdentityCard(donor),
                const SizedBox(height: 14),
                _buildSection(
                  title: 'المعلومات الشخصية',
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF43A047),
                  iconBg: const Color(0xFFE8F5E9),
                  children: [
                    _row('الاسم الكامل', donor['fullName']),
                    _row('البريد الإلكتروني', donor['email']),
                    _row('رقم الهاتف', donor['phoneNumber']),
                    _row('رقم الهوية', donor['nationalId']),
                    _row('العنوان', donor['address']),
                    _row('تاريخ الميلاد', _formatDate(donor['dateOfBirth'])),
                  ],
                ),
                const SizedBox(height: 14),
                _buildSection(
                  title: 'المعلومات الطبية',
                  icon: Icons.medical_services_outlined,
                  iconColor: const Color(0xFF1E88E5),
                  iconBg: const Color(0xFFE3F2FD),
                  children: [
                    _row('فصيلة الدم', donor['bloodType']),
                    if ((donor['medicalConditions'] ?? '')
                        .toString()
                        .isNotEmpty)
                      _row('الحالات الطبية', donor['medicalConditions']),
                  ],
                ),
                const SizedBox(height: 14),
                _buildOrgans(organs),
                const SizedBox(height: 14),
                if (!_isDeceased) _buildDeathSection(),
                if (_isDeceased) _buildAlreadyDeceased(),
                const SizedBox(height: 24),
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
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _AppColors.pinkBorder),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: _AppColors.primaryRed,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'تفاصيل المتبرع',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _AppColors.pinkTitle,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'معلومات كاملة عن المتبرع',
              style: TextStyle(fontSize: 12, color: _AppColors.pinkSub),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIdentityCard(Map<String, dynamic> donor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_AppColors.primaryRed, _AppColors.darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  donor['fullName'] ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'رقم الهوية: ${donor['nationalId'] ?? '—'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                _statusBadgeWhite(donor['status']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadgeWhite(String? status) {
    final s = (status ?? '').toLowerCase();
    Color bg;
    String label;
    IconData icon;
    if (s == 'available' || s == 'متاح') {
      bg = const Color(0xFF43A047);
      label = 'متاح للتبرع';
      icon = Icons.check_circle_outline;
    } else if (s == 'deceased' || s == 'متوفي') {
      bg = const Color(0xFF1565C0);
      label = 'متوفي – متاح للتبرع';
      icon = Icons.volunteer_activism;
    } else if (s == 'pending' || s == 'قيد المراجعة') {
      bg = const Color(0xFFF57F17);
      label = 'قيد المراجعة';
      icon = Icons.hourglass_top_outlined;
    } else {
      bg = Colors.grey;
      label = status ?? '—';
      icon = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
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
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(color: _AppColors.pinkBorder, thickness: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: _AppColors.textMuted),
            ),
          ),
          const Text(': ', style: TextStyle(color: _AppColors.textMuted)),
          Expanded(
            child: Text(
              value ?? '—',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 12,
                color: _AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgans(List organs) {
    const organsAr = {
      'Heart': 'القلب',
      'KidneyLeft': 'الكلى اليسرى',
      'KidneyRight': 'الكلى اليمنى',
      'Liver': 'الكبد',
      'LungLeft': 'الرئة اليسرى',
      'LungRight': 'الرئة اليمنى',
      'Cornea': 'القرنية',
      'Pancreas': 'البنكرياس',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.pinkBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _AppColors.pinkLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: _AppColors.pinkBorder),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: 14,
                  color: _AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'الأعضاء المسجلة للتبرع',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(color: _AppColors.pinkBorder, thickness: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          organs.isEmpty
              ? const Text(
                  'لا توجد أعضاء مسجلة',
                  style: TextStyle(color: _AppColors.textMuted, fontSize: 12),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: organs.map<Widget>((o) {
                    final label = organsAr[o] ?? o.toString();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _AppColors.pinkLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _AppColors.pinkBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: _AppColors.primaryRed,
                            size: 12,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _AppColors.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildDeathSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Icon(
                  Icons.warning_amber_outlined,
                  size: 15,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'تسجيل وفاة المتبرع',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'عند تسجيل الوفاة وإرفاق شهادة الوفاة، ستتغير حالة المتبرع تلقائياً إلى "متاح للتبرع" وسيتم إخطار فريق التنسيق.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickCert,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _AppColors.pinkSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasCert
                      ? _AppColors.primaryRed
                      : _AppColors.pinkBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasCert
                        ? Icons.check_circle_outline
                        : Icons.upload_file_outlined,
                    color: _hasCert
                        ? _AppColors.primaryRed
                        : const Color(0xFFD97C7C),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _certName ?? 'إرفاق شهادة الوفاة (PDF أو صورة)',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: _hasCert
                            ? _AppColors.textDark
                            : const Color(0xFFC8A0A0),
                      ),
                    ),
                  ),
                  if (_hasCert)
                    GestureDetector(
                      onTap: () => setState(() {
                        _certMobile = null;
                        _certWeb = null;
                        _certName = null;
                      }),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: _AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _submitting ? null : _confirmDeath,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade600, Colors.orange.shade800],
                ),
              ),
              child: Center(
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.volunteer_activism,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'تأكيد تسجيل الوفاة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyDeceased() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تم تسجيل وفاة هذا المتبرع مسبقاً. حالته الحالية: متاح للتبرع.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null) return '—';
    try {
      final d = DateTime.parse(date);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }
}

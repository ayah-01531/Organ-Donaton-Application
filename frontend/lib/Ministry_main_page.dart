import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

// ══════════════════════════════════════════════════════════════
//  COLOURS
// ══════════════════════════════════════════════════════════════
class _C {
  static const primary = Color(0xFFE24B4A);
  static const darkRed = Color(0xFFC0392B);
  static const deepRed = Color(0xFFA32D2D);
  static const pinkTitle = Color(0xFFC2185B);
  static const pinkSub = Color(0xFFE57373);
  static const pinkBorder = Color(0xFFF5C1C1);
  static const pinkLight = Color(0xFFFFF0F0);
  static const textMuted = Color(0xFFC0706F);
  static const textDark = Color(0xFF3A1A1A);
}

// ══════════════════════════════════════════════════════════════
//  ROOT SHELL
// ══════════════════════════════════════════════════════════════
class MinistryApp extends StatefulWidget {
  const MinistryApp({super.key});
  @override
  State<MinistryApp> createState() => _MinistryAppState();
}

class _MinistryAppState extends State<MinistryApp> {
  int _idx = 0;

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
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
                          Icons.dashboard_outlined,
                          color: Color(0xFFF48FB1),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'لوحة تحكم الوزارة',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _C.pinkTitle,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'نظام إدارة التبرع بالأعضاء',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontSize: 13, color: _C.pinkSub),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _C.pinkBorder, width: 0.5),
                    ),
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        _tabBtn('الرئيسية', 0),
                        _tabBtn('المستشفيات', 1),
                        _tabBtn('المتبرعون', 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: IndexedStack(
                    index: _idx,
                    children: const [
                      DashboardPage(),
                      HospitalsPage(),
                      DonorsPage(),
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

  Widget _tabBtn(String label, int i) {
    final sel = _idx == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _idx = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: sel
                ? const LinearGradient(colors: [_C.primary, _C.darkRed])
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: sel ? FontWeight.w500 : FontWeight.normal,
              color: sel ? Colors.white : _C.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════
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
      textDirection: TextDirection.rtl,
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
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _C.textDark,
              ),
            ),
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _statusBadge(String status) {
  Color bg, fg;
  String label;
  switch (status) {
    case 'Approved':
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
      label = 'معتمد';
      break;
    case 'Rejected':
      bg = const Color(0xFFFFEBEE);
      fg = _C.deepRed;
      label = 'مرفوض';
      break;
    default:
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
      label = 'معلق';
      break;
  }
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500),
    ),
  );
}

Widget _sectionTitle(String text, int count) {
  return Row(
    textDirection: TextDirection.rtl,
    children: [
      Expanded(
        child: Text(
          text,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _C.pinkTitle,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: _C.pinkLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.pinkBorder, width: 0.5),
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            color: _C.deepRed,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

Widget _empty(String label) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _C.pinkBorder, width: 0.5),
    ),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, color: _C.textMuted, size: 30),
        const SizedBox(height: 8),
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 13, color: _C.textMuted),
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
      textDirection: TextDirection.rtl,
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
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5A2A2A)),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
//  PAGE 1 — DASHBOARD
// ══════════════════════════════════════════════════════════════
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  List<dynamic> _hospitals = [];
  List<dynamic> _donors = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final h = await ApiService.getMinistryHospitalRequests();
    final d = await ApiService.getMinistryDonorRequests();
    setState(() {
      _hospitals = h['data'] ?? [];
      _donors = d['data'] ?? [];
      _loading = false;
    });
  }

  List<dynamic> get _pendingH =>
      _hospitals.where((h) => h['status'] == 'Pending').toList();
  List<dynamic> get _pendingD =>
      _donors.where((d) => d['status'] == 'Pending').toList();

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: _C.primary));
    return RefreshIndicator(
      color: _C.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_C.primary, _C.darkRed],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'إدارة التبرع بالأعضاء بكفاءة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (_pendingH.length + _pendingD.length) > 0
                        ? 'لديك ${_pendingH.length + _pendingD.length} طلب بانتظار المراجعة'
                        : 'لا توجد طلبات معلقة حالياً',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'مراجعة الطلبات',
                      style: TextStyle(
                        color: _C.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _statCard(
              number: _hospitals
                  .where((h) => h['status'] == 'Approved')
                  .length
                  .toString(),
              title: 'مستشفى معتمد',
              icon: Icons.local_hospital_outlined,
              iconColor: const Color(0xFF43A047),
              iconBg: const Color(0xFFE8F5E9),
              borderColor: const Color(0xFF43A047),
            ),
            const SizedBox(height: 10),
            _statCard(
              number: _donors
                  .where((d) => d['status'] == 'Approved')
                  .length
                  .toString(),
              title: 'متبرع معتمد',
              icon: Icons.favorite_border,
              iconColor: const Color(0xFF1E88E5),
              iconBg: const Color(0xFFE3F2FD),
              borderColor: const Color(0xFF1E88E5),
            ),
            const SizedBox(height: 10),
            _statCard(
              number: (_pendingH.length + _pendingD.length).toString(),
              title: 'طلب معلق',
              icon: Icons.hourglass_empty_rounded,
              iconColor: const Color(0xFF8E24AA),
              iconBg: const Color(0xFFF3E5F5),
              borderColor: const Color(0xFF8E24AA),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.pinkBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'مهام الوزارة',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.pinkTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _whyItem(
                    Icons.verified_outlined,
                    'اعتماد المستشفيات والمراكز الطبية',
                    dotBg: const Color(0xFFFFF0F0),
                    dotBorder: _C.pinkBorder,
                    iconColor: _C.primary,
                  ),
                  _whyItem(
                    Icons.people_outline,
                    'مراجعة وقبول طلبات المتبرعين',
                    dotBg: const Color(0xFFE0F2F1),
                    dotBorder: const Color(0xFFB2DFDB),
                    iconColor: const Color(0xFF00897B),
                  ),
                  _whyItem(
                    Icons.security_outlined,
                    'ضمان الجودة والسلامة الطبية',
                    dotBg: const Color(0xFFFFF3E0),
                    dotBorder: const Color(0xFFFFE0B2),
                    iconColor: const Color(0xFFFB8C00),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle('طلبات المستشفيات المعلقة', _pendingH.length),
            const SizedBox(height: 10),
            _pendingH.isEmpty
                ? _empty('لا توجد طلبات مستشفيات معلقة')
                : Column(
                    children: _pendingH
                        .map((h) => _HospReqTile(item: h, onDecision: _load))
                        .toList(),
                  ),
            const SizedBox(height: 24),
            _sectionTitle('طلبات المتبرعين المعلقة', _pendingD.length),
            const SizedBox(height: 10),
            _pendingD.isEmpty
                ? _empty('لا توجد طلبات متبرعين معلقة')
                : Column(
                    children: _pendingD
                        .map((d) => _DonorReqTile(item: d, onDecision: _load))
                        .toList(),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pill('آمن ومشفّر'),
                const SizedBox(width: 8),
                _pill('خصوصية تامة'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
    decoration: BoxDecoration(
      color: _C.pinkLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _C.pinkBorder, width: 0.5),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12, color: _C.deepRed)),
  );
}

// ══════════════════════════════════════════════════════════════
//  PAGE 2 — HOSPITALS
// ══════════════════════════════════════════════════════════════
class HospitalsPage extends StatefulWidget {
  const HospitalsPage({super.key});
  @override
  State<HospitalsPage> createState() => _HospitalsPageState();
}

class _HospitalsPageState extends State<HospitalsPage> {
  bool _loading = true;
  List<dynamic> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService.getMinistryHospitalRequests();
    setState(() {
      _list = r['data'] ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: _C.primary));
    return RefreshIndicator(
      color: _C.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('قائمة المستشفيات', _list.length),
            const SizedBox(height: 10),
            _list.isEmpty
                ? _empty('لا توجد مستشفيات مسجلة')
                : Column(
                    children: _list.map((h) => _HospInfoTile(item: h)).toList(),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE 3 — DONORS
// ══════════════════════════════════════════════════════════════
class DonorsPage extends StatefulWidget {
  const DonorsPage({super.key});
  @override
  State<DonorsPage> createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  bool _loading = true;
  List<dynamic> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ApiService.getMinistryDonorRequests();
    setState(() {
      _list = r['data'] ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Center(child: CircularProgressIndicator(color: _C.primary));
    return RefreshIndicator(
      color: _C.primary,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('قائمة المتبرعين', _list.length),
            const SizedBox(height: 10),
            _list.isEmpty
                ? _empty('لا يوجد متبرعون مسجلون')
                : Column(
                    children: _list
                        .map((d) => _DonorInfoTile(item: d))
                        .toList(),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  DONOR DETAIL PAGE — صفحة التفاصيل الكاملة مع الملفات
// ══════════════════════════════════════════════════════════════
class DonorDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDecision;
  const DonorDetailPage({
    super.key,
    required this.item,
    required this.onDecision,
  });

  @override
  State<DonorDetailPage> createState() => _DonorDetailPageState();
}

class _DonorDetailPageState extends State<DonorDetailPage> {
  bool _showReject = false;
  bool _busy = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    await ApiService.ministryApproveDonor(widget.item['id']);
    widget.onDecision();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reject() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    await ApiService.ministryRejectDonor(widget.item['id'], _ctrl.text.trim());
    widget.onDecision();
    if (mounted) Navigator.pop(context);
  }

  List<String> _parseFiles(dynamic path) {
    if (path == null || path.toString().isEmpty) return [];
    final s = path.toString();
    try {
      final decoded = jsonDecode(s);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
    if (s.contains(',')) return s.split(',').map((e) => e.trim()).toList();
    return [s];
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.item;
    final organs = (d['organs'] as List?)?.join('، ') ?? '';
    final init = (d['fullName'] ?? ' ').substring(0, 1);
    debugPrint('donor data keys: ${d.keys.toList()}');
    debugPrint('medicalReportsPath value: ${d['medicalReportsPath']}');
    final files = _parseFiles(d['medicalReportsPath']);
    final isPending = (d['status'] ?? '') == 'Pending';

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
            child: Column(
              children: [
                // ── هيدر مع زر رجوع
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _C.pinkBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: _C.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'تفاصيل المتبرع',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _C.pinkTitle,
                          ),
                        ),
                      ),
                      _statusBadge(d['status'] ?? ''),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── بطاقة هوية المتبرع
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _C.pinkBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: _C.pinkLight,
                                child: Text(
                                  init,
                                  style: const TextStyle(
                                    color: _C.deepRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      d['fullName'] ?? '',
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: _C.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      d['email'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ── المعلومات الشخصية
                        _detailSection(
                          title: 'المعلومات الشخصية',
                          icon: Icons.person_outline,
                          children: [
                            _infoRow('الرقم الوطني', d['nationalId'] ?? ''),
                            _infoRow('فصيلة الدم', d['bloodType'] ?? ''),
                            if (organs.isNotEmpty)
                              _infoRow('الأعضاء للتبرع', organs),
                            if ((d['medicalConditions'] ?? '').isNotEmpty)
                              _infoRow('الحالة الطبية', d['medicalConditions']),
                            if ((d['rejectionReason'] ?? '').isNotEmpty)
                              _infoRow(
                                'سبب الرفض',
                                d['rejectionReason'],
                                valueColor: _C.primary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── الفحوصات الطبية
                        _detailSection(
                          title: 'الفحوصات الطبية',
                          icon: Icons.folder_open_outlined,
                          children: [
                            if (files.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.folder_off_outlined,
                                      color: _C.textMuted,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'لا توجد ملفات مرفقة',
                                      style: TextStyle(
                                        color: _C.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...files.asMap().entries.map(
                                (e) =>
                                    _FileTile(index: e.key + 1, path: e.value),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── أزرار القرار (فقط للطلبات المعلقة)
                        if (isPending) ...[
                          if (_busy)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  color: _C.primary,
                                ),
                              ),
                            )
                          else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _actionBtn(
                                    'قبول الطلب',
                                    Icons.check_circle_outline,
                                    const Color(0xFF2E7D32),
                                    const Color(0xFFE8F5E9),
                                    _approve,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _actionBtn(
                                    'رفض الطلب',
                                    Icons.cancel_outlined,
                                    _C.primary,
                                    _C.pinkLight,
                                    () => setState(() => _showReject = true),
                                  ),
                                ),
                              ],
                            ),
                            if (_showReject) ...[
                              const SizedBox(height: 12),
                              _RejectBox(ctrl: _ctrl, onSend: _reject),
                            ],
                          ],
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
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

// ── قسم تفاصيل
Widget _detailSection({
  required String title,
  required IconData icon,
  required List<Widget> children,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.pinkBorder, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _C.pinkLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: _C.primary),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _C.pinkTitle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: _C.pinkBorder, height: 1),
        const SizedBox(height: 10),
        ...children,
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════
//  FILE TILE — بطاقة الملف الطبي
// ══════════════════════════════════════════════════════════════
class _FileTile extends StatelessWidget {
  final int index;
  final String path;

  static const String _baseUrl = 'http://192.168.1.5:5004';

  const _FileTile({required this.index, required this.path});

  String get _fullUrl => '$_baseUrl$path';

  String get _fileName {
    final parts = path.split('/');
    return parts.isNotEmpty ? parts.last : 'ملف $index';
  }

  bool get _isImage =>
      ['.jpg', '.jpeg', '.png'].any((ext) => path.toLowerCase().endsWith(ext));

  bool get _isPdf => path.toLowerCase().endsWith('.pdf');

  IconData get _icon => _isPdf
      ? Icons.picture_as_pdf_outlined
      : _isImage
      ? Icons.image_outlined
      : Icons.attach_file_outlined;

  Color get _iconColor =>
      _isPdf ? const Color(0xFFE53935) : const Color(0xFF1E88E5);
  Color get _iconBg =>
      _isPdf ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.pinkLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.pinkBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // معاينة مباشرة للصور
          if (_isImage)
            GestureDetector(
              onTap: () => _openFile(context),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  _fullUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          height: 180,
                          color: _C.pinkLight,
                          child: const Center(
                            child: CircularProgressIndicator(color: _C.primary),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: _C.pinkLight,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: _C.textMuted,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, size: 18, color: _iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ملف $index',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openFile(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_C.primary, _C.darkRed],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'فتح',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFile(BuildContext context) async {
    final uri = Uri.parse(_fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر فتح الملف', textDirection: TextDirection.rtl),
            backgroundColor: _C.primary,
          ),
        );
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════
//  TILE — pending hospital request
// ══════════════════════════════════════════════════════════════
class _HospReqTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDecision;
  const _HospReqTile({required this.item, required this.onDecision});
  @override
  State<_HospReqTile> createState() => _HospReqTileState();
}

class _HospReqTileState extends State<_HospReqTile> {
  bool _open = false, _showReject = false, _busy = false;
  final _ctrl = TextEditingController();
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    await ApiService.ministryApproveHospital(widget.item['id']);
    widget.onDecision();
  }

  Future<void> _reject() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    await ApiService.ministryRejectHospital(
      widget.item['id'],
      _ctrl.text.trim(),
    );
    widget.onDecision();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.item;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(right: BorderSide(color: _C.primary, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _C.pinkLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital_outlined,
                      color: _C.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          h['name'] ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _C.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h['licenseNumber'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _C.textMuted,
                  ),
                ],
              ),
            ),
            if (_open) ...[
              Container(height: 0.5, color: _C.pinkBorder),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _infoRow('البريد الإلكتروني', h['email'] ?? ''),
                    _infoRow('رقم الترخيص', h['licenseNumber'] ?? ''),
                    const SizedBox(height: 14),
                    if (_busy)
                      const Center(
                        child: CircularProgressIndicator(color: _C.primary),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _actionBtn(
                              'قبول',
                              Icons.check_circle_outline,
                              const Color(0xFF2E7D32),
                              const Color(0xFFE8F5E9),
                              _approve,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _actionBtn(
                              'رفض',
                              Icons.cancel_outlined,
                              _C.primary,
                              _C.pinkLight,
                              () => setState(() => _showReject = true),
                            ),
                          ),
                        ],
                      ),
                      if (_showReject) ...[
                        const SizedBox(height: 12),
                        _RejectBox(ctrl: _ctrl, onSend: _reject),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TILE — pending donor request  →  يفتح DonorDetailPage
// ══════════════════════════════════════════════════════════════
class _DonorReqTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDecision;
  const _DonorReqTile({required this.item, required this.onDecision});

  @override
  Widget build(BuildContext context) {
    final d = item;
    final init = (d['fullName'] ?? ' ').substring(0, 1);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonorDetailPage(item: d, onDecision: onDecision),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(right: BorderSide(color: _C.primary, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: _C.pinkLight,
                child: Text(
                  init,
                  style: const TextStyle(
                    color: _C.deepRed,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      d['fullName'] ?? '',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _C.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'فصيلة الدم: ${d["bloodType"] ?? ""}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // سهم يدل على وجود صفحة تفاصيل
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _C.pinkLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: _C.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TILE — hospital info (read-only)
// ══════════════════════════════════════════════════════════════
class _HospInfoTile extends StatefulWidget {
  final Map<String, dynamic> item;
  const _HospInfoTile({required this.item});
  @override
  State<_HospInfoTile> createState() => _HospInfoTileState();
}

class _HospInfoTileState extends State<_HospInfoTile> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final h = widget.item;
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            right: BorderSide(color: _borderFor(h['status'] ?? ''), width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _C.pinkLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital_outlined,
                      color: _C.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          h['name'] ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _C.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h['licenseNumber'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(h['status'] ?? ''),
                  const SizedBox(width: 6),
                  Icon(
                    _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _C.textMuted,
                  ),
                ],
              ),
            ),
            if (_open) ...[
              Container(height: 0.5, color: _C.pinkBorder),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _infoRow('البريد الإلكتروني', h['email'] ?? ''),
                    _infoRow('رقم الترخيص', h['licenseNumber'] ?? ''),
                    if ((h['rejectionReason'] ?? '').isNotEmpty)
                      _infoRow(
                        'سبب الرفض',
                        h['rejectionReason'],
                        valueColor: _C.primary,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  TILE — donor info (read-only) → يفتح DonorDetailPage
// ══════════════════════════════════════════════════════════════
class _DonorInfoTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _DonorInfoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final d = item;
    final init = (d['fullName'] ?? ' ').substring(0, 1);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonorDetailPage(item: d, onDecision: () {}),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            right: BorderSide(color: _borderFor(d['status'] ?? ''), width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: _C.pinkLight,
                child: Text(
                  init,
                  style: const TextStyle(
                    color: _C.deepRed,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      d['fullName'] ?? '',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _C.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'فصيلة الدم: ${d["bloodType"] ?? ""}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _statusBadge(d['status'] ?? ''),
              const SizedBox(width: 6),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _C.pinkLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: _C.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  MICRO HELPERS
// ══════════════════════════════════════════════════════════════
Color _borderFor(String status) {
  switch (status) {
    case 'Approved':
      return const Color(0xFF43A047);
    case 'Rejected':
      return _C.primary;
    default:
      return const Color(0xFFFB8C00);
  }
}

Widget _infoRow(String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 13, color: _C.textMuted),
        ),
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 13, color: valueColor ?? _C.textDark),
          ),
        ),
      ],
    ),
  );
}

Widget _actionBtn(
  String label,
  IconData icon,
  Color color,
  Color bg,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

class _RejectBox extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onSend;
  const _RejectBox({required this.ctrl, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: ctrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'اكتب سبب الرفض...',
            hintStyle: const TextStyle(color: _C.textMuted),
            filled: true,
            fillColor: _C.pinkLight,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.pinkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.pinkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [_C.primary, _C.darkRed]),
            ),
            child: const Text(
              'إرسال السبب',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

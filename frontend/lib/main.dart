import 'package:flutter/material.dart';
import 'login.dart';
import 'create_donor_account_page.dart';
import 'create_hospital_account_page.dart';
import 'donor_main_page.dart';
import 'patient_main_page.dart';
import 'donor_profile.dart';
import 'patient_profile.dart';
import 'Ministry_main_page.dart';
import 'success_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/ministry': (context) => const MinistryApp(),
        '/createDonor': (context) => CreateDonorAccountPage(),
        '/createHospital': (context) => CreateHospitalAccountPage(),

        '/donormain': (context) => const DonorMainPage(),
        '/patientmain': (context) => const PatientMainPage(),
        '/success': (context) => const SuccessPage(),

        '/donorProfile': (context) => const DonorScreen(),
        '/patientProfile': (context) => const PatientFormPage(),
      },
    );
  }
}

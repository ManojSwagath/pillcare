import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../services/caregiver_service.dart';
import '../services/auth_service.dart';
import '../widgets/section_header.dart';
import '../widgets/big_button.dart';
import 'login_screen.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  List<dynamic> patients = [];
  List<dynamic> alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final patientsResponse = await CaregiverService.getPatients();
      final alertsResponse = await CaregiverService.getAlerts();
      
      if (patientsResponse['success'] == true) {
        patients = patientsResponse['data'] ?? [];
      }
      if (alertsResponse['success'] == true) {
        alerts = alertsResponse['data'] ?? [];
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLinkPatientDialog() {
    final emailController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Link Patient', style: AppTextStyles.heading2),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the patient\'s email to connect and monitor their medication.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Patient Email',
                  labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.email, color: AppColors.primary, size: 28),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 24),
              BigButton.primary(
                text: 'Link Patient',
                icon: Icons.link,
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter patient email'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    return;
                  }
                  
                  try {
                    final response = await CaregiverService.linkPatient(emailController.text.trim());
                    Navigator.pop(context);
                    
                    if (response['success'] == true) {
                      _loadData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Patient linked successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'Failed to link patient'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(dynamic link) {
    final patient = link['patientId'] ?? {};
    final stats = link['todayStats'] ?? {};
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient['name'] ?? 'Unknown', style: AppTextStyles.heading2),
                      Text(patient['email'] ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Today's Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Progress", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(label: 'Taken', value: '${stats['taken'] ?? 0}', color: AppColors.success),
                      const SizedBox(width: 12),
                      _StatBox(label: 'Pending', value: '${stats['pending'] ?? 0}', color: AppColors.warning),
                      const SizedBox(width: 12),
                      _StatBox(label: 'Missed', value: '${stats['missed'] ?? 0}', color: AppColors.danger),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Unlink button
            BigButton(
              text: 'Unlink Patient',
              icon: Icons.link_off,
              backgroundColor: AppColors.danger,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Unlink Patient?'),
                    content: Text('You will no longer be able to monitor ${patient['name']}\'s medication.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Unlink', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true) {
                  try {
                    await CaregiverService.unlinkPatient(patient['_id']);
                    Navigator.pop(context);
                    _loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Patient unlinked'), backgroundColor: AppColors.success),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _logout() {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Caregiver', style: AppTextStyles.heading2),
                              const SizedBox(height: 4),
                              Text(
                                'Monitor your loved ones',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _logout,
                            icon: Icon(Icons.logout, color: AppColors.textSecondary, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Link Patient Button
                      GestureDetector(
                        onTap: _showLinkPatientDialog,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add, color: AppColors.primary, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Link a Patient',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Patients Section
                      SectionHeader(title: 'My Patients', icon: Icons.people),
                      
                      if (patients.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.people_outline, size: 64, color: AppColors.textLight),
                              const SizedBox(height: 16),
                              Text('No patients linked yet', style: AppTextStyles.bodyLarge),
                              const SizedBox(height: 8),
                              Text(
                                'Link a patient using their email to start monitoring',
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ...patients.map((link) {
                          final patient = link['patientId'] ?? {};
                          final stats = link['todayStats'] ?? {};
                          return GestureDetector(
                            onTap: () => _showPatientDetails(link),
                            child: _PatientCard(
                              name: patient['name'] ?? 'Unknown',
                              email: patient['email'] ?? '',
                              todayTaken: stats['taken'] ?? 0,
                              todayTotal: stats['total'] ?? 0,
                              pending: stats['pending'] ?? 0,
                              missed: stats['missed'] ?? 0,
                            ),
                          );
                        }),

                      const SizedBox(height: 16),
                      SectionHeader(title: 'Recent Alerts', icon: Icons.warning_amber),
                      
                      if (alerts.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 32),
                              const SizedBox(width: 16),
                              Text('No alerts - All good!', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.success)),
                            ],
                          ),
                        )
                      else
                        ...alerts.take(5).map((alert) {
                          final patient = alert['patientId'] ?? {};
                          final isMissed = alert['alertType'] == 'missed_dose';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (isMissed ? AppColors.danger : AppColors.warning).withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: (isMissed ? AppColors.danger : AppColors.warning).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isMissed ? Icons.cancel : Icons.warning,
                                    color: isMissed ? AppColors.danger : AppColors.warning,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patient['name'] ?? 'Patient',
                                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        alert['message'] ?? (isMissed ? 'Missed dose' : 'Alert'),
                                        style: AppTextStyles.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String name;
  final String email;
  final int todayTaken;
  final int todayTotal;
  final int pending;
  final int missed;

  const _PatientCard({
    required this.name,
    required this.email,
    required this.todayTaken,
    required this.todayTotal,
    required this.pending,
    required this.missed,
  });

  @override
  Widget build(BuildContext context) {
    final progress = todayTotal > 0 ? todayTaken / todayTotal : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 32, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(email, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textLight, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(
                missed > 0 ? AppColors.danger : (progress == 1 ? AppColors.success : AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today: $todayTaken/$todayTotal doses',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              if (missed > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$missed missed',
                    style: AppTextStyles.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold),
                  ),
                )
              else if (pending > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pending pending',
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                  ),
                )
              else if (todayTotal > 0 && todayTaken == todayTotal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'All done!',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

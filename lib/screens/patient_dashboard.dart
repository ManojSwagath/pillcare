import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../services/schedule_service.dart';
import '../services/dose_service.dart';
import '../widgets/medicine_card.dart';
import '../widgets/section_header.dart';
import 'medicine_list.dart';
import 'history_screen.dart';
import 'reminder_popup.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  List<Medicine> medicines = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final schedulesResponse = await ScheduleService.getTodaySchedules();
      final statsResponse = await DoseService.getAdherenceStats(days: 1);

      if (schedulesResponse['success'] == true) {
        final List<dynamic> data = schedulesResponse['data'];
        medicines = data.map((item) {
          final med = item['medicineId'];
          return Medicine(
            id: item['_id'],
            name: med['name'] ?? 'Unknown',
            dosage: med['dosage'] ?? '',
            time: item['time'] ?? '',
            timeOfDay: _parseTimeOfDay(item['timeOfDay']),
            status: _parseStatus(item['status']),
            notes: item['notes'],
          );
        }).toList();
      }

      if (statsResponse['success'] == true) {
        _stats = statsResponse['data'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  MedicineTimeOfDay _parseTimeOfDay(String? value) {
    switch (value) {
      case 'morning': return MedicineTimeOfDay.morning;
      case 'afternoon': return MedicineTimeOfDay.afternoon;
      case 'evening': return MedicineTimeOfDay.evening;
      case 'night': return MedicineTimeOfDay.night;
      default: return MedicineTimeOfDay.morning;
    }
  }

  MedicineStatus _parseStatus(String? value) {
    switch (value) {
      case 'taken': return MedicineStatus.taken;
      case 'missed': return MedicineStatus.missed;
      case 'skipped': return MedicineStatus.skipped;
      default: return MedicineStatus.pending;
    }
  }

  void _showReminder(Medicine medicine) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => ReminderPopup(
          medicine: medicine,
          onTaken: () => _respondToDose(medicine, 'taken'),
          onNotTaken: () => _respondToDose(medicine, 'skipped'),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _respondToDose(Medicine medicine, String status) async {
    try {
      await DoseService.respondToDose(
        doseLogId: medicine.id,
        status: status,
      );
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _logout() {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  int get pendingCount => medicines.where((m) => m.status == MedicineStatus.pending).length;
  int get takenCount => medicines.where((m) => m.status == MedicineStatus.taken).length;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboard(),
            const MedicineListScreen(),
            const HistoryScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.medication, 'Medicines'),
                _buildNavItem(2, Icons.history, 'History'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    return RefreshIndicator(
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
                    Text(_greeting, style: AppTextStyles.heading2),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
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
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text("Today's Progress", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('$takenCount', style: AppTextStyles.heading1.copyWith(color: Colors.white, fontSize: 48)),
                      Text(' / ${medicines.length}', style: AppTextStyles.heading2.copyWith(color: Colors.white60)),
                      const SizedBox(width: 16),
                      Text('medicines taken', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: medicines.isEmpty ? 0 : takenCount / medicines.length,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SectionHeader(
              title: "Today's Medicines",
              icon: Icons.medication,
            ),
            if (pendingCount > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$pendingCount medicine${pendingCount > 1 ? 's' : ''} pending',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (medicines.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 64, color: AppColors.success),
                      const SizedBox(height: 16),
                      Text('No medicines scheduled for today!', style: AppTextStyles.bodyLarge),
                    ],
                  ),
                ),
              )
            else
              ...medicines.map((medicine) => MedicineCard(
                    medicine: medicine,
                    onTap: () => _showReminder(medicine),
                  )),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../services/dose_service.dart';
import '../widgets/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> history = [];
  bool _isLoading = true;
  String selectedFilter = 'All';

  final filters = ['All', 'Taken', 'Missed', 'Skipped'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final status = selectedFilter == 'All' ? null : selectedFilter.toLowerCase();
      final response = await DoseService.getDoseHistory(status: status);
      if (response['success'] == true) {
        history = response['data'];
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);
      
      String dayStr;
      if (date == today) {
        dayStr = 'Today';
      } else if (date == today.subtract(const Duration(days: 1))) {
        dayStr = 'Yesterday';
      } else {
        dayStr = '${dt.day}/${dt.month}/${dt.year}';
      }
      
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      
      return '$dayStr, $hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('History', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    'Track your medication history',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: filters.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => selectedFilter = filter);
                        _loadHistory();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : AppColors.cardShadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          filter,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history, size: 80, color: AppColors.textLight),
                              const SizedBox(height: 16),
                              Text('No history found', style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final dose = history[index];
                              final med = dose['medicineId'] ?? {};
                              return _HistoryCard(
                                medicineName: med['name'] ?? 'Unknown',
                                dosage: med['dosage'] ?? '',
                                scheduledTime: _formatDateTime(dose['scheduledTime']),
                                status: _parseStatus(dose['status']),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final String scheduledTime;
  final MedicineStatus status;

  const _HistoryCard({
    required this.medicineName,
    required this.dosage,
    required this.scheduledTime,
    required this.status,
  });

  Color get statusColor {
    switch (status) {
      case MedicineStatus.taken: return AppColors.success;
      case MedicineStatus.missed: return AppColors.danger;
      case MedicineStatus.skipped: return AppColors.textSecondary;
      case MedicineStatus.pending: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(width: 6, height: 100, color: statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.medication, color: statusColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(medicineName, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(dosage, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(child: Text(scheduledTime, style: AppTextStyles.caption)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: status, fontSize: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../services/medicine_service.dart';
import '../services/schedule_service.dart';
import '../widgets/big_button.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  List<dynamic> medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      final response = await MedicineService.getMedicines();
      if (response['success'] == true) {
        medicines = response['data'];
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay? selectedTime;
    String? selectedMealInstruction;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Medicine', style: AppTextStyles.heading2),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField('Medicine Name', Icons.medication, nameController),
                  const SizedBox(height: 16),
                  _buildTextField('Dosage (e.g., 500mg)', Icons.format_size, dosageController),
                  const SizedBox(height: 24),
                  
                  // Time Picker
                  Text('Schedule Time', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(primary: AppColors.primary),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: AppColors.primary, size: 28),
                          const SizedBox(width: 16),
                          Text(
                            selectedTime != null 
                              ? selectedTime!.format(context)
                              : 'Select time',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: AppColors.textLight),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Meal Instruction
                  Text('Meal Instructions', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MealChip(
                        label: 'Before Meal',
                        icon: Icons.restaurant,
                        isSelected: selectedMealInstruction == 'before_meal',
                        onTap: () => setModalState(() => selectedMealInstruction = 'before_meal'),
                      ),
                      _MealChip(
                        label: 'After Meal',
                        icon: Icons.restaurant_menu,
                        isSelected: selectedMealInstruction == 'after_meal',
                        onTap: () => setModalState(() => selectedMealInstruction = 'after_meal'),
                      ),
                      _MealChip(
                        label: 'With Meal',
                        icon: Icons.lunch_dining,
                        isSelected: selectedMealInstruction == 'with_meal',
                        onTap: () => setModalState(() => selectedMealInstruction = 'with_meal'),
                      ),
                      _MealChip(
                        label: 'Any Time',
                        icon: Icons.schedule,
                        isSelected: selectedMealInstruction == 'anytime',
                        onTap: () => setModalState(() => selectedMealInstruction = 'anytime'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BigButton.primary(
                    text: 'Add Medicine',
                    icon: Icons.add,
                    onPressed: () async {
                      if (nameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter medicine name'), backgroundColor: AppColors.danger),
                        );
                        return;
                      }
                      if (selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a time'), backgroundColor: AppColors.danger),
                        );
                        return;
                      }
                      
                      try {
                        // Create medicine first
                        final medResponse = await MedicineService.createMedicine(
                          name: nameController.text,
                          dosage: dosageController.text.isNotEmpty ? dosageController.text : '1 tablet',
                        );
                        
                        if (medResponse['success'] == true) {
                          final medicineId = medResponse['data']['_id'];
                          
                          // Create schedule with time
                          final timeStr = '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                          await ScheduleService.createSchedule(
                            medicineId: medicineId,
                            time: timeStr,
                            mealInstruction: selectedMealInstruction,
                          );
                          
                          Navigator.pop(context);
                          _loadMedicines();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${nameController.text} scheduled for ${selectedTime!.format(context)}'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                        );
                      }
                    },
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

  void _showAddScheduleDialog(dynamic medicine) {
    TimeOfDay? selectedTime;
    String? selectedMealInstruction;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Schedule', style: AppTextStyles.heading2),
                          Text(medicine['name'], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 32),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Time Picker
                Text('Select Time', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ?? TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: AppColors.primary),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setModalState(() => selectedTime = time);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.primary, size: 28),
                        const SizedBox(width: 16),
                        Text(
                          selectedTime != null 
                            ? selectedTime!.format(context)
                            : 'Tap to select time',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: selectedTime != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: AppColors.textLight),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Meal Instruction
                Text('Meal Instructions (Optional)', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MealChip(
                      label: 'Before',
                      icon: Icons.restaurant,
                      isSelected: selectedMealInstruction == 'before_meal',
                      onTap: () => setModalState(() => selectedMealInstruction = 'before_meal'),
                    ),
                    _MealChip(
                      label: 'After',
                      icon: Icons.restaurant_menu,
                      isSelected: selectedMealInstruction == 'after_meal',
                      onTap: () => setModalState(() => selectedMealInstruction = 'after_meal'),
                    ),
                    _MealChip(
                      label: 'With',
                      icon: Icons.lunch_dining,
                      isSelected: selectedMealInstruction == 'with_meal',
                      onTap: () => setModalState(() => selectedMealInstruction = 'with_meal'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                BigButton.primary(
                  text: 'Add Schedule',
                  icon: Icons.schedule,
                  onPressed: () async {
                    if (selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a time'), backgroundColor: AppColors.danger),
                      );
                      return;
                    }
                    
                    try {
                      final timeStr = '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}';
                      await ScheduleService.createSchedule(
                        medicineId: medicine['_id'],
                        time: timeStr,
                        mealInstruction: selectedMealInstruction,
                      );
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Schedule added for ${selectedTime!.format(context)}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 28),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
    );
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
                  Text('My Medicines', style: AppTextStyles.heading2),
                  const SizedBox(height: 8),
                  Text(
                    '${medicines.length} medicines registered',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : medicines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.medication, size: 64, color: AppColors.textLight),
                              const SizedBox(height: 16),
                              Text('No medicines yet', style: AppTextStyles.bodyLarge),
                              const SizedBox(height: 8),
                              Text('Add your first medicine below', style: AppTextStyles.caption),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadMedicines,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: medicines.length,
                            itemBuilder: (context, index) {
                              final med = medicines[index];
                              return _MedicineListCard(
                                medicine: med,
                                onAddSchedule: () => _showAddScheduleDialog(med),
                              );
                            },
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: BigButton.primary(
                text: 'Add Medicine',
                icon: Icons.add,
                onPressed: _showAddMedicineDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineListCard extends StatelessWidget {
  final dynamic medicine;
  final VoidCallback onAddSchedule;

  const _MedicineListCard({
    required this.medicine,
    required this.onAddSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final name = medicine['name'] ?? 'Unknown';
    final dosage = medicine['dosage'] ?? '';
    final colorStr = medicine['color'] ?? '#4A90E2';
    final instructions = medicine['instructions'];
    
    Color cardColor;
    try {
      cardColor = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      cardColor = AppColors.primary;
    }

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
            Container(width: 8, height: 120, color: cardColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(dosage, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    if (instructions != null) ...[
                      const SizedBox(height: 4),
                      Text(instructions, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: onAddSchedule,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_alarm, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Add Schedule',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

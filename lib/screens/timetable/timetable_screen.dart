import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../data/models/timetable_period.dart';
import '../../data/models/time_slot.dart';
import 'widgets/add_period_sheet.dart';
import 'manage_time_slots_screen.dart';

class TimetableRow {
  final TimeSlot? slot;
  final TimetablePeriod? period;

  TimetableRow({this.slot, this.period});

  String get startTime => period?.startTime ?? slot?.startTime ?? '00:00';
  String get endTime => period?.endTime ?? slot?.endTime ?? '00:00';

  int get startMinutes {
    final parts = startTime.split(':');
    if (parts.length == 2) {
      return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    }
    return 0;
  }
}

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  late Map<String, List<TimetablePeriod>> _timetable;
  late List<TimeSlot> _timeSlots;

  @override
  void initState() {
    super.initState();
    final currentWeekday = DateTime.now().weekday;
    final initialIndex = (currentWeekday == DateTime.sunday) ? 0 : currentWeekday - 1;

    _tabController = TabController(
      length: _days.length, 
      initialIndex: initialIndex,
      vsync: this,
    );
    // Load initial data
    _timetable = ref.read(userPrefsRepositoryProvider).getTimetable();
    _timeSlots = ref.read(userPrefsRepositoryProvider).getTimeSlots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveData() {
    ref.read(userPrefsRepositoryProvider).saveTimetable(_timetable);
  }

  Future<void> _manageTimeSlots() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ManageTimeSlotsScreen(),
    ));
    setState(() {
      _timeSlots = ref.read(userPrefsRepositoryProvider).getTimeSlots();
    });
  }

  void _showAddSheet({TimeSlot? slot}) {
    final currentDay = _days[_tabController.index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPeriodSheet(
        initialSlotId: slot?.id,
        initialStartTime: slot?.startTime,
        initialEndTime: slot?.endTime,
        onAdd: (TimetablePeriod period) {
          setState(() {
            _timetable.putIfAbsent(currentDay, () => []).add(period);
          });
          _saveData();
        },
      ),
    );
  }

  void _showUpdateSheet(String day, TimetablePeriod existingPeriod) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPeriodSheet(
        existingPeriod: existingPeriod,
        onAdd: (TimetablePeriod updatedPeriod) {
          setState(() {
            final periods = _timetable[day];
            if (periods != null) {
              final index = periods.indexWhere((p) => p.id == updatedPeriod.id);
              if (index != -1) {
                periods[index] = updatedPeriod;
              }
            }
          });
          _saveData();
        },
      ),
    );
  }

  void _deletePeriod(String day, String periodId) {
    setState(() {
      _timetable[day]?.removeWhere((p) => p.id == periodId);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Timetable', style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            tooltip: 'Manage Bell Schedule',
            onPressed: _manageTimeSlots,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: cs.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: cs.primary,
          tabs: _days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) {
          final periods = _timetable[day] ?? [];
          final rows = <TimetableRow>[];

          // Add all global slots
          for (final slot in _timeSlots) {
            final periodIdx = periods.indexWhere((p) => p.slotId == slot.id);
            if (periodIdx != -1) {
              rows.add(TimetableRow(slot: slot, period: periods[periodIdx]));
            } else {
              rows.add(TimetableRow(slot: slot, period: null));
            }
          }

          // Add any custom periods that don't belong to a global slot
          for (final period in periods) {
            if (period.slotId == null || !_timeSlots.any((s) => s.id == period.slotId)) {
              rows.add(TimetableRow(slot: null, period: period));
            }
          }

          // Sort rows chronologically
          rows.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
          
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_note_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 20),
                    Text('No classes', style: Theme.of(context).textTheme.displaySmall),
                    const SizedBox(height: 8),
                    Text(
                      'Set up your Bell Schedule or tap + to add a custom class.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // padding for FAB
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              final period = row.period;
              final slot = row.slot;

              if (period == null && slot != null && slot.isBreak) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text('${slot.name} (${slot.startTime} - ${slot.endTime})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }

              if (period == null && slot != null) {
                return InkWell(
                  onTap: () => _showAddSheet(slot: slot),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.add, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Empty Slot (${slot.name})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${slot.startTime} - ${slot.endTime}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
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

              if (period == null) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? cs.surface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.getSubjectColor(period.subject).$1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.getSubjectColor(period.subject).$2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            period.subject,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (period.startTime.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${period.startTime} - ${period.endTime}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showUpdateSheet(day, period);
                        } else if (value == 'delete') {
                          _deletePeriod(day, period.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Custom'),
      ),
    );
  }
}

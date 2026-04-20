import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../data/models/timetable_period.dart';
import 'widgets/add_period_sheet.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  late Map<String, List<TimetablePeriod>> _timetable;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveData() {
    ref.read(userPrefsRepositoryProvider).saveTimetable(_timetable);
  }

  void _showAddSheet() {
    final currentDay = _days[_tabController.index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddPeriodSheet(
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
        title: Text('Timetable', style: Theme.of(context).textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          
          if (periods.isEmpty) {
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
                      'Tap + to add a class to your $day schedule.',
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
            itemCount: periods.length,
            itemBuilder: (context, index) {
              final period = periods[index];
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
        label: const Text('Add Class'),
      ),
    );
  }
}

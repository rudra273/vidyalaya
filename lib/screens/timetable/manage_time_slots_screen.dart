import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/models/time_slot.dart';
import '../../providers/core_providers.dart';

class ManageTimeSlotsScreen extends ConsumerStatefulWidget {
  const ManageTimeSlotsScreen({super.key});

  @override
  ConsumerState<ManageTimeSlotsScreen> createState() => _ManageTimeSlotsScreenState();
}

class _ManageTimeSlotsScreenState extends ConsumerState<ManageTimeSlotsScreen> {
  late List<TimeSlot> _timeSlots;

  @override
  void initState() {
    super.initState();
    _timeSlots = ref.read(userPrefsRepositoryProvider).getTimeSlots();
  }

  void _saveData() {
    ref.read(userPrefsRepositoryProvider).saveTimeSlots(_timeSlots);
  }

  void _addSlot() {
    setState(() {
      _timeSlots.add(TimeSlot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'New Period',
        startTime: '09:00',
        endTime: '09:40',
      ));
    });
    _saveData();
    _showEditDialog(_timeSlots.last, _timeSlots.length - 1);
  }

  void _deleteSlot(int index) {
    setState(() {
      _timeSlots.removeAt(index);
    });
    _saveData();
  }

  Future<void> _showEditDialog(TimeSlot slot, int index) async {
    final nameController = TextEditingController(text: slot.name);
    TimeOfDay startTime = _parseTime(slot.startTime);
    TimeOfDay endTime = _parseTime(slot.endTime);
    bool isBreak = slot.isBreak;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Time Slot'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name (e.g. Period 1)'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: startTime,
                              );
                              if (time != null) setDialogState(() => startTime = time);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Start Time'),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: endTime,
                              );
                              if (time != null) setDialogState(() => endTime = time);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'End Time'),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Is Break / Lunch'),
                      value: isBreak,
                      onChanged: (v) => setDialogState(() => isBreak = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        _timeSlots[index] = slot.copyWith(
          name: nameController.text.trim(),
          startTime: _formatTime(startTime),
          endTime: _formatTime(endTime),
          isBreak: isBreak,
        );
        // Sort by start time
        _timeSlots.sort((a, b) => _parseTime(a.startTime).hour * 60 + _parseTime(a.startTime).minute
            .compareTo(_parseTime(b.startTime).hour * 60 + _parseTime(b.startTime).minute));
      });
      _saveData();
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bell Schedule'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final slot = _timeSlots[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(slot.isBreak ? Icons.restaurant : Icons.access_time),
              title: Text(slot.name),
              subtitle: Text('${slot.startTime} - ${slot.endTime}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditDialog(slot, index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteSlot(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSlot,
        icon: const Icon(Icons.add),
        label: const Text('Add Time Slot'),
      ),
    );
  }
}

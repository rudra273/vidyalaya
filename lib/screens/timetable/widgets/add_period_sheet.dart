import 'package:flutter/material.dart';

import '../../../data/seed/seed_data.dart';
import '../../../data/models/timetable_period.dart';

class AddPeriodSheet extends StatefulWidget {
  final TimetablePeriod? existingPeriod;
  final Function(TimetablePeriod) onAdd;

  const AddPeriodSheet({super.key, required this.onAdd, this.existingPeriod});

  @override
  State<AddPeriodSheet> createState() => _AddPeriodSheetState();
}

class _AddPeriodSheetState extends State<AddPeriodSheet> {
  final _subjectController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  
  // Available subjects for suggestion
  late final List<String> _subjects;

  @override
  void initState() {
    super.initState();
    // Extract unique subjects and format them nicely
    _subjects = allBooks.map((b) => b.subject).toSet().map((s) {
      return s.split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
    }).toList();
    
    if (widget.existingPeriod != null) {
      _subjectController.text = widget.existingPeriod!.subject;
      _startController.text = widget.existingPeriod!.startTime;
      _endController.text = widget.existingPeriod!.endTime;
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _submit() {
    final sub = _subjectController.text.trim();
    if (sub.isEmpty) return;

    final period = TimetablePeriod(
      id: widget.existingPeriod?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      subject: sub,
      startTime: _startController.text.trim(),
      endTime: _endController.text.trim(),
    );

    widget.onAdd(period);
    Navigator.of(context).pop();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(picked, alwaysUse24HourFormat: false);
      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.existingPeriod == null ? 'Add Class Period' : 'Edit Class Period',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RawAutocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return _subjects.where((String option) {
                return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (String selection) {
              _subjectController.text = selection;
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              // We override the controller to keep it synced
              textEditingController.value = _subjectController.value;
              textEditingController.addListener(() {
                _subjectController.text = textEditingController.text;
              });
              
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Subject (e.g. Maths, Science, PT)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startController,
                  readOnly: true,
                  onTap: () => _selectTime(_startController),
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    hintText: 'e.g. 10:00 AM',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _endController,
                  readOnly: true,
                  onTap: () => _selectTime(_endController),
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    hintText: 'e.g. 10:45 AM',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffixIcon: const Icon(Icons.access_time),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

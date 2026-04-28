import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/history/timeline_data.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String _selectedEra = 'All';
  List<HistoricalEvent> _filteredEvents = timelineEvents;

  final List<String> _eras = [
    'All',
    'Ancient India',
    'Medieval India',
    'Modern India',
    'Odisha History',
  ];

  void _onEraSelected(String era) {
    setState(() {
      _selectedEra = era;
      if (era == 'All') {
        _filteredEvents = timelineEvents;
      } else {
        _filteredEvents = timelineEvents.where((e) => e.era == era).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Historical Timeline'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _eras.length,
                itemBuilder: (context, index) {
                  final era = _eras[index];
                  final isSelected = era == _selectedEra;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(era),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        if (selected) _onEraSelected(era);
                      },
                      backgroundColor: cs.surface,
                      selectedColor: Colors.amber.withValues(alpha: 0.2),
                      checkmarkColor: Colors.amber.shade700,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.amber.shade800 : AppColors.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.amber.shade700 : cs.outlineVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const Divider(height: 1),

          // Timeline List
          Expanded(
            child: _filteredEvents.isEmpty
                ? const Center(child: Text('No events found.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      final isFirst = index == 0;
                      final isLast = index == _filteredEvents.length - 1;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Timeline Line & Dot
                            SizedBox(
                              width: 32,
                              child: Column(
                                children: [
                                  // Top Line segment
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: isFirst ? Colors.transparent : Colors.amber.withValues(alpha: 0.5),
                                  ),
                                  // Timeline Dot
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade700,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withValues(alpha: 0.4),
                                          blurRadius: 4,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Bottom Line segment
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: isLast ? Colors.transparent : Colors.amber.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Right Content Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 24),
                                child: _EventCard(event: event),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final HistoricalEvent event;

  const _EventCard({required this.event});

  MaterialColor _getEraColor(String era) {
    switch (era) {
      case 'Ancient India':
        return Colors.brown;
      case 'Medieval India':
        return Colors.indigo;
      case 'Modern India':
        return Colors.blue;
      case 'Odisha History':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eraColor = _getEraColor(event.era);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year and Era Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.year,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber.shade700,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: eraColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: eraColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  event.era,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? eraColor.shade200 : eraColor.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // English Title and Description
          Text(
            event.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  height: 1.4,
                ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          
          // Odia Title and Description
          Text(
            event.titleOdia,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            event.descriptionOdia,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

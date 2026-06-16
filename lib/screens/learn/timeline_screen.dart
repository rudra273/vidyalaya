import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../data/history/timeline_data.dart';
import '../../providers/regional_language_provider.dart';
import '../../widgets/regional_language_switch.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

/// A geographic scope the student can toggle in the timeline filter. Multiple
/// scopes can be active at once — events from any selected scope are shown.
enum _RegionScope { world, india, state }

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  // The set of active region scopes. Defaults to India alone. When
  // [_RegionScope.state] is active, [_selectedState] names the chosen state.
  final Set<_RegionScope> _scopes = {_RegionScope.india};
  String _selectedState = 'Odisha';

  /// Events whose region matches any of the active scopes.
  List<HistoricalEvent> get _filteredEvents {
    return timelineEvents.where((e) {
      if (_scopes.contains(_RegionScope.world) && e.region == kRegionWorld) {
        return true;
      }
      if (_scopes.contains(_RegionScope.india) && e.region == kRegionIndia) {
        return true;
      }
      if (_scopes.contains(_RegionScope.state) && e.region == _selectedState) {
        return true;
      }
      return false;
    }).toList();
  }

  void _toggleScope(_RegionScope scope) {
    setState(() {
      if (_scopes.contains(scope)) {
        _scopes.remove(scope);
      } else {
        _scopes.add(scope);
      }
    });
  }

  Future<void> _pickState() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StatePickerSheet(selected: _selectedState),
    );
    if (picked != null) {
      setState(() {
        _selectedState = picked;
        _scopes.add(_RegionScope.state);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(regionalLanguageProvider);
    final events = _filteredEvents;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Historical Timeline'),
        actions: const [RegionalLanguageSwitch()],
      ),
      body: Column(
        children: [
          // Region scope selector: World / India / State (multi-select).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _RegionChip(
                  label: 'World',
                  icon: Icons.public_rounded,
                  selected: _scopes.contains(_RegionScope.world),
                  onTap: () => _toggleScope(_RegionScope.world),
                ),
                const SizedBox(width: 8),
                _RegionChip(
                  label: 'India',
                  icon: Icons.flag_rounded,
                  selected: _scopes.contains(_RegionScope.india),
                  onTap: () => _toggleScope(_RegionScope.india),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RegionChip(
                    label: _selectedState,
                    icon: Icons.location_on_rounded,
                    selected: _scopes.contains(_RegionScope.state),
                    // When the state scope is active, tap toggles it off; the
                    // caret reopens the picker to change which state.
                    trailing: Icons.arrow_drop_down_rounded,
                    onTap: () {
                      if (_scopes.contains(_RegionScope.state)) {
                        _toggleScope(_RegionScope.state);
                      } else {
                        _pickState();
                      }
                    },
                    onTrailingTap: _pickState,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Timeline List
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No events for this region yet.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      final isFirst = index == 0;
                      final isLast = index == events.length - 1;

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
                                child: _EventCard(event: event, lang: lang),
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

/// A pill-shaped region scope selector used in the timeline filter row.
class _RegionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final IconData? trailing;
  final VoidCallback onTap;

  /// Tapped when the [trailing] icon is pressed. Falls back to [onTap] if null.
  final VoidCallback? onTrailingTap;

  const _RegionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? Colors.amber.withValues(alpha: 0.2) : cs.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? Colors.amber.shade700 : cs.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.amber.shade800 : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        selected ? Colors.amber.shade800 : AppColors.textMuted,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (trailing != null)
                GestureDetector(
                  onTap: onTrailingTap ?? onTap,
                  child: Icon(
                    trailing,
                    size: 18,
                    color:
                        selected ? Colors.amber.shade800 : AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A searchable bottom sheet listing all 28 Indian states. The student can type
/// to filter and tap to select. Returns the chosen state name via [Navigator.pop].
class _StatePickerSheet extends StatefulWidget {
  final String selected;

  const _StatePickerSheet({required this.selected});

  @override
  State<_StatePickerSheet> createState() => _StatePickerSheetState();
}

class _StatePickerSheetState extends State<_StatePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final matches = indianStates
        .where((s) => s.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search your state…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: matches.isEmpty
                    ? const Center(child: Text('No matching state.'))
                    : ListView.builder(
                        itemCount: matches.length,
                        itemBuilder: (context, index) {
                          final state = matches[index];
                          final isSelected = state == widget.selected;
                          return ListTile(
                            leading: Icon(
                              Icons.location_on_rounded,
                              color: isSelected
                                  ? Colors.amber.shade700
                                  : AppColors.textMuted,
                            ),
                            title: Text(
                              state,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_rounded,
                                    color: Colors.amber.shade700)
                                : null,
                            onTap: () => Navigator.of(context).pop(state),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final HistoricalEvent event;
  final RegionalLanguage lang;

  const _EventCard({required this.event, required this.lang});

  MaterialColor _getEraColor(String era) {
    switch (era) {
      case 'Ancient':
        return Colors.brown;
      case 'Medieval':
        return Colors.indigo;
      case 'Modern':
        return Colors.blue;
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
          
          // Regional Title and Description (Odia or Hindi)
          Text(
            lang == RegionalLanguage.hindi ? event.titleHindi : event.titleOdia,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            lang == RegionalLanguage.hindi
                ? event.descriptionHindi
                : event.descriptionOdia,
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

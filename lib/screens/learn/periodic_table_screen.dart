import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/science/periodic_table_data.dart';

class PeriodicTableScreen extends StatefulWidget {
  const PeriodicTableScreen({super.key});

  @override
  State<PeriodicTableScreen> createState() => _PeriodicTableScreenState();
}

class _PeriodicTableScreenState extends State<PeriodicTableScreen> {
  final double _elementWidth = 72.0;
  final double _elementHeight = 84.0;
  final double _gap = 4.0;

  void _showElementDetails(BuildContext context, ElementData element, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with atomic number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Atomic Number: ${element.atomicNumber}',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              
              // Big Symbol Box
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text(
                    element.symbol,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),

              // Names
              Text(
                element.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                element.nameOdia,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Details Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDetailStat(context, 'Group', '${element.group}'),
                    ),
                    Container(width: 1, height: 40, color: cs.outlineVariant),
                    Expanded(
                      child: _buildDetailStat(context, 'Period', '${element.period}'),
                    ),
                    Container(width: 1, height: 40, color: cs.outlineVariant),
                    Expanded(
                      child: _buildDetailStat(context, 'Category', _formatCategory(element.category)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'nonmetal': return Colors.lightGreen;
      case 'noble_gas': return Colors.purpleAccent;
      case 'alkali_metal': return Colors.orange;
      case 'alkaline_earth': return Colors.amber;
      case 'metalloid': return Colors.teal;
      case 'halogen': return Colors.cyan;
      case 'post_transition': return Colors.blueGrey;
      case 'transition_metal': return Colors.blue;
      case 'lanthanide': return Colors.pinkAccent;
      case 'actinide': return Colors.deepPurpleAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Total width = 18 groups * (width + gap)
    final double tableWidth = 18 * (_elementWidth + _gap);
    // Total height = 10 periods * (height + gap) to allow for Lanthanides and Actinides (period 8, 9)
    final double tableHeight = 10 * (_elementHeight + _gap);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Periodic Table'),
      ),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(80.0),
          minScale: 0.2,
          maxScale: 3.0,
          constrained: false, // Allows the child to be its intrinsic size
          child: SizedBox(
            width: tableWidth,
            height: tableHeight,
            child: Stack(
              children: periodicTableElements.map((e) {
                final color = _getCategoryColor(e.category);
                
                return Positioned(
                  left: (e.group - 1) * (_elementWidth + _gap),
                  top: (e.period - 1) * (_elementHeight + _gap),
                  width: _elementWidth,
                  height: _elementHeight,
                  child: _ElementCell(
                    element: e,
                    color: color,
                    onTap: () => _showElementDetails(context, e, color),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ElementCell extends StatelessWidget {
  final ElementData element;
  final Color color;
  final VoidCallback onTap;

  const _ElementCell({
    required this.element,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine text colors based on background
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.3 : 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.6 : 0.4),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${element.atomicNumber}',
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            Center(
              child: Text(
                element.symbol,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.0,
                ),
              ),
            ),
            Center(
              child: Text(
                element.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:fin_chart/models/enums/scanner_type.dart';
import 'package:flutter/material.dart';

enum _ScannerGroup {
  candlestick,
  oscillator,
  priceAboveSMA,
  priceBelowSMA,
  priceAboveEMA,
  priceBelowEMA,
}

const Map<_ScannerGroup, String> _scannerGroupNames = {
  _ScannerGroup.candlestick: 'Candlestick Patterns',
  _ScannerGroup.oscillator: 'Oscillator Patterns',
  _ScannerGroup.priceAboveSMA: 'Price Above SMA',
  _ScannerGroup.priceBelowSMA: 'Price Below SMA',
  _ScannerGroup.priceAboveEMA: 'Price Above EMA',
  _ScannerGroup.priceBelowEMA: 'Price Below EMA',
};

const List<int> _smaPeriods = [5, 10, 20, 30, 50, 100, 150, 200];
const List<int> _emaPeriods = [5, 10, 12, 20, 26, 50, 100, 200];

_ScannerGroup _getCategoryForType(ScannerType type) {
  String name = type.name;
  if (name.startsWith('priceAboveSMA')) return _ScannerGroup.priceAboveSMA;
  if (name.startsWith('priceBelowSMA')) return _ScannerGroup.priceBelowSMA;
  if (name.startsWith('priceAboveEMA')) return _ScannerGroup.priceAboveEMA;
  if (name.startsWith('priceBelowEMA')) return _ScannerGroup.priceBelowEMA;
  if (name.startsWith('mfi')) return _ScannerGroup.oscillator;
  if (name.startsWith('dual')) return _ScannerGroup.oscillator;
  if (name.startsWith('macd')) return _ScannerGroup.oscillator;
  if (name.startsWith('rsiB')) return _ScannerGroup.oscillator;
  return _ScannerGroup.candlestick;
}

class ScannerSelectionDialog extends StatefulWidget {
  final Function(ScannerType) onScannerSelected;

  const ScannerSelectionDialog({
    super.key,
    required this.onScannerSelected,
  });

  @override
  State<ScannerSelectionDialog> createState() => _ScannerSelectionDialogState();
}

class _ScannerSelectionDialogState extends State<ScannerSelectionDialog> {
  _ScannerGroup? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_selectedGroup == null
          ? 'Select Scanner Group'
          : _scannerGroupNames[_selectedGroup!]!),
      content: SizedBox(
        width: 350,
        child: _selectedGroup == null ? _buildGroupList() : _buildScannerList(),
      ),
      actions: [
        if (_selectedGroup != null)
          TextButton(
            onPressed: () => setState(() => _selectedGroup = null),
            child: const Text('Back'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildGroupList() {
    return ListView(
      shrinkWrap: true,
      children: _ScannerGroup.values.map((group) {
        return ListTile(
          title: Text(_scannerGroupNames[group]!),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (group == _ScannerGroup.candlestick ||
                group == _ScannerGroup.oscillator) {
              setState(() {
                _selectedGroup = group;
              });
            } else {
              _showPeriodSelectionDialog(group);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildScannerList() {
    final scanners = ScannerType.values
        .where((type) => _getCategoryForType(type) == _selectedGroup)
        .toList();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: scanners.length,
      itemBuilder: (context, index) {
        final scannerType = scanners[index];
        return ListTile(
          title: Text(scannerType.name),
          onTap: () {
            widget.onScannerSelected(scannerType);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _showPeriodSelectionDialog(_ScannerGroup group) async {
    final List<int> periods = (group == _ScannerGroup.priceAboveSMA ||
            group == _ScannerGroup.priceBelowSMA)
        ? _smaPeriods
        : _emaPeriods;

    final int? period = await showDialog<int>(
      context: context,
      builder: (context) => _PeriodSelectionDialog(periods: periods),
    );

    if (period != null && mounted) {
      String enumName = '';
      switch (group) {
        case _ScannerGroup.priceAboveSMA:
          enumName = 'priceAbove${period}SMA';
          break;
        case _ScannerGroup.priceBelowSMA:
          enumName = 'priceBelow${period}SMA';
          break;
        case _ScannerGroup.priceAboveEMA:
          enumName = 'priceAbove${period}EMA';
          break;
        case _ScannerGroup.priceBelowEMA:
          enumName = 'priceBelow${period}EMA';
          break;
        case _ScannerGroup.candlestick:
        case _ScannerGroup.oscillator:
          return;
      }

      try {
        final finalType =
            ScannerType.values.firstWhere((e) => e.name == enumName);
        widget.onScannerSelected(finalType);
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not find a scanner for period $period.')));
      }
    }
  }
}

class _PeriodSelectionDialog extends StatelessWidget {
  final List<int> periods;

  const _PeriodSelectionDialog({required this.periods});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Period'),
      content: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: periods.map((period) {
          return ActionChip(
            label: Text(period.toString()),
            onPressed: () {
              Navigator.of(context).pop(period);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

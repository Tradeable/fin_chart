import 'package:fin_chart/models/enums/event_type.dart';
import 'package:fin_chart/models/fundamental/dividend_event.dart';
import 'package:fin_chart/models/fundamental/earnings_event.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/fundamental/stock_split_event.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class AddEventDialog extends StatefulWidget {
  final Function(FundamentalEvent) onEventAdded;
  final List<DateTime> validDates;

  const AddEventDialog(
      {super.key, required this.onEventAdded, required this.validDates});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  EventType _selectedEventType = EventType.earnings;
  final _formKey = GlobalKey<FormState>();
  DateTime? _exDividendDate;
  DateTime? _paymentDate;
  
  // Earnings event controllers
  final TextEditingController _epsActualController = TextEditingController();
  final TextEditingController _epsEstimateController = TextEditingController();
  final TextEditingController _revenueActualController = TextEditingController();
  final TextEditingController _revenueEstimateController = TextEditingController();
  
  // Dividend event controllers
  final TextEditingController _amountController = TextEditingController();
  // final TextEditingController _currencyController = TextEditingController(text: 'USD');
  
  // Stock split event controller
  final TextEditingController _ratioController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _epsActualController.dispose();
    _epsEstimateController.dispose();
    _revenueActualController.dispose();
    _revenueEstimateController.dispose();
    _amountController.dispose();
    // _currencyController.dispose();
    _ratioController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _findClosestValidDate(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      selectableDayPredicate: (DateTime date) {
        // Check if this date exists in validDates (comparing just the date part)
        return widget.validDates.any((validDate) =>
            date.year == validDate.year &&
            date.month == validDate.month &&
            date.day == validDate.day);
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Helper method to find closest valid date to current selection
  DateTime _findClosestValidDate() {
    if (widget.validDates.isEmpty) return DateTime.now();

    if (widget.validDates.any((date) =>
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day)) {
      return _selectedDate;
    }

    // If current selection is invalid, use the most recent date
    return widget.validDates.last;
  }

  Widget _buildEarningsForm() {
    return Column(
      children: [
        TextFormField(
          controller: _epsActualController,
          decoration: const InputDecoration(labelText: 'EPS Actual'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        TextFormField(
          controller: _epsEstimateController,
          decoration: const InputDecoration(labelText: 'EPS Estimate'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        TextFormField(
          controller: _revenueActualController,
          decoration: const InputDecoration(labelText: 'Revenue Actual'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        TextFormField(
          controller: _revenueEstimateController,
          decoration: const InputDecoration(labelText: 'Revenue Estimate'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildDividendForm() {
    return Column(
      children: [
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Amount'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the dividend amount';
            }
            return null;
          },
        ),
        // TextFormField(
        //   controller: _currencyController,
        //   decoration: const InputDecoration(labelText: 'Currency'),
        // ),

        // Ex-Dividend Date
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _exDividendDate ?? _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _exDividendDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration:
                const InputDecoration(labelText: 'Ex-Dividend Date (Optional)'),
            child: Text(
              _exDividendDate != null
                  ? "${_exDividendDate!.toLocal()}".split(' ')[0]
                  : "Not set",
            ),
          ),
        ),

        // Payment Date
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _paymentDate ?? _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _paymentDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration:
                const InputDecoration(labelText: 'Payment Date (Optional)'),
            child: Text(
              _paymentDate != null
                  ? "${_paymentDate!.toLocal()}".split(' ')[0]
                  : "Not set",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockSplitForm() {
    return TextFormField(
      controller: _ratioController,
      decoration: const InputDecoration(labelText: 'Ratio (e.g., 2:1)'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the stock split ratio';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Fundamental Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<EventType>(
                value: _selectedEventType,
                decoration: const InputDecoration(labelText: 'Event Type'),
                items: EventType.values.map((EventType type) {
                  return DropdownMenuItem<EventType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (EventType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedEventType = newValue;
                    });
                  }
                },
              ),
              
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Show different form fields based on selected event type
              if (_selectedEventType == EventType.earnings)
                _buildEarningsForm()
              else if (_selectedEventType == EventType.dividend)
                _buildDividendForm()
              else if (_selectedEventType == EventType.stockSplit)
                _buildStockSplitForm(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              FundamentalEvent event;
              final id = generateV4();

              if (_selectedEventType == EventType.earnings) {
                // Calculate surprise values automatically
                final actualEps = _epsActualController.text.isNotEmpty
                    ? double.parse(_epsActualController.text)
                    : null;
                final estEps = _epsEstimateController.text.isNotEmpty
                    ? double.parse(_epsEstimateController.text)
                    : null;
                double? epsSurprise;
                if (actualEps != null && estEps != null && estEps != 0) {
                  epsSurprise = ((actualEps - estEps) / estEps) * 100;
                }

                final actualRev = _revenueActualController.text.isNotEmpty
                    ? double.parse(_revenueActualController.text)
                    : null;
                final estRev = _revenueEstimateController.text.isNotEmpty
                    ? double.parse(_revenueEstimateController.text)
                    : null;
                double? revSurprise;
                if (actualRev != null && estRev != null && estRev != 0) {
                  revSurprise = ((actualRev - estRev) / estRev) * 100;
                }

                event = EarningsEvent(
                  id: id,
                  date: _selectedDate,
                  title: "Earnings",
                  description: "",
                  epsActual: actualEps,
                  epsEstimate: estEps,
                  epsSurprise: epsSurprise,
                  revenueActual: actualRev,
                  revenueEstimate: estRev,
                  revenueSurprise: revSurprise,
                );
              } else if (_selectedEventType == EventType.dividend) {
                event = DividendEvent(
                  id: id,
                  date: _selectedDate,
                  title: "Dividend",
                  exDividendDate: _exDividendDate,
                  paymentDate: _paymentDate,
                  amount: double.parse(_amountController.text),
                  // currency: _currencyController.text,
                );
              } else {
                event = StockSplitEvent(
                  id: id,
                  date: _selectedDate,
                  title: "Stock SPlit",
                  ratio: _ratioController.text,
                );
              }
              
              widget.onEventAdded(event);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
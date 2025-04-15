import 'package:fin_chart/models/enums/event_type.dart';
import 'package:fin_chart/models/fundamental/bonus_event.dart';
import 'package:fin_chart/models/fundamental/dividend_event.dart';
import 'package:fin_chart/models/fundamental/earnings_event.dart';
import 'package:fin_chart/models/fundamental/fundamental_event.dart';
import 'package:fin_chart/models/fundamental/news_event.dart';
import 'package:fin_chart/models/fundamental/stock_split_event.dart';
import 'package:fin_chart/utils/calculations.dart';
import 'package:flutter/material.dart';

class AddEventDialog extends StatefulWidget {
  final Function(FundamentalEvent) onEventAdded;
  final DateTime preSelectedDate;
  final int index;

  const AddEventDialog(
      {super.key, required this.onEventAdded, required this.preSelectedDate, required this.index});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  EventType _selectedEventType = EventType.earnings;
  final _formKey = GlobalKey<FormState>();
  DateTime? _exDividendDate;
  DateTime? _paymentDate;
  DateTime? _recordDate;
  DateTime? _issueDate;
  
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

  // News event controller
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
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

        // Ex-Dividend Date
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _exDividendDate ?? widget.preSelectedDate,
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
              initialDate: _paymentDate ?? widget.preSelectedDate,
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
    return Column(
      children: [
        TextFormField(
          controller: _ratioController,
          decoration: const InputDecoration(labelText: 'Ratio (e.g., 2:1)'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the stock split ratio';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNewsForm() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the title';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'More Details'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBonusForm() {
    return Column(
      children: [
        TextFormField(
          controller: _ratioController,
          decoration: const InputDecoration(labelText: 'Ratio (e.g., 2:1)'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the bonus ratio';
            }
            return null;
          },
        ),

               // Ex-Dividend Date
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _recordDate ?? widget.preSelectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _recordDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration:
                const InputDecoration(labelText: 'Record Date (Optional)'),
            child: Text(
              _recordDate != null
                  ? "${_recordDate!.toLocal()}".split(' ')[0]
                  : "Not set",
            ),
          ),
        ),

        // Payment Date
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _issueDate ?? widget.preSelectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _issueDate = picked;
              });
            }
          },
          child: InputDecorator(
            decoration:
                const InputDecoration(labelText: 'Issue Date (Optional)'),
            child: Text(
              _issueDate != null
                  ? "${_issueDate!.toLocal()}".split(' ')[0]
                  : "Not set",
            ),
          ),
        ),
      ],
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

              InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(
                  _formatDate(widget.preSelectedDate),
                ),
              ),

              const SizedBox(height: 16),
              
              // Show different form fields based on selected event type
              if (_selectedEventType == EventType.earnings)
                _buildEarningsForm()
              else if (_selectedEventType == EventType.dividend)
                _buildDividendForm()
              else if (_selectedEventType == EventType.stockSplit)
                _buildStockSplitForm()
              else if (_selectedEventType == EventType.news)
                _buildNewsForm()
              else if (_selectedEventType == EventType.bonus) 
                _buildBonusForm(),
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
                  index: widget.index,
                  date: widget.preSelectedDate,
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
                  index: widget.index,
                  date: widget.preSelectedDate,
                  title: "Dividend",
                  exDividendDate: _exDividendDate,
                  paymentDate: _paymentDate,
                  amount: double.parse(_amountController.text),
                );
              } else if (_selectedEventType == EventType.stockSplit) {
                event = StockSplitEvent(
                  id: id,
                  index: widget.index,
                  date: widget.preSelectedDate,
                  title: "Stock SPlit",
                  ratio: _ratioController.text,
                );
              } else if (_selectedEventType == EventType.news) {
                event = NewsEvent(
                  id: id,
                  index: widget.index,
                  date: widget.preSelectedDate,
                  title: _titleController.text,
                  description: _descriptionController.text,
                );
              } else {
                event = BonusEvent(
                  id: id,
                  index: widget.index,
                  date: widget.preSelectedDate,
                  title: "Bonus",
                  ratio: _ratioController.text,
                  recordDate: _recordDate,
                  issueDate: _issueDate,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

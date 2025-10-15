import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/construction_permit_request.dart';
import '../../providers/permit_provider.dart';
import '../../utils/validators.dart';
import 'dart:developer' as developer;

/// Submit construction permit form
class SubmitPermitScreen extends ConsumerStatefulWidget {
  const SubmitPermitScreen({super.key});

  @override
  ConsumerState<SubmitPermitScreen> createState() => _SubmitPermitScreenState();
}

class _SubmitPermitScreenState extends ConsumerState<SubmitPermitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _contractorNameController = TextEditingController();
  final _contractorContactController = TextEditingController();
  final _estimatedWorkersController = TextEditingController();

  String _selectedProjectType = PermitProjectType.renovation;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  // Authorized workers list
  final List<String> _authorizedWorkers = [];
  final _workerNameController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _contractorNameController.dispose();
    _contractorContactController.dispose();
    _estimatedWorkersController.dispose();
    _workerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Permit Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Project type dropdown
            DropdownButtonFormField<String>(
              value: _selectedProjectType,
              decoration: const InputDecoration(
                labelText: 'Project Type',
                prefixIcon: Icon(Icons.construction),
              ),
              items: PermitProjectType.all.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(PermitProjectType.displayNames[type]!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedProjectType = value;
                  });
                }
              },
              validator: Validators.required('Project type is required'),
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Project Description',
                hintText: 'Describe the construction project',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: Validators.required('Description is required'),
            ),

            const SizedBox(height: 16),

            // Contractor name
            TextFormField(
              controller: _contractorNameController,
              decoration: const InputDecoration(
                labelText: 'Contractor Name',
                hintText: 'Enter contractor name',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: Validators.required('Contractor name is required'),
            ),

            const SizedBox(height: 16),

            // Contractor contact
            TextFormField(
              controller: _contractorContactController,
              decoration: const InputDecoration(
                labelText: 'Contractor Contact',
                hintText: 'Enter contractor contact number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.compose([
                Validators.required('Contractor contact is required'),
                Validators.phone(),
              ]),
            ),

            const SizedBox(height: 16),

            // Start date
            InkWell(
              onTap: () => _selectStartDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _startDate != null
                      ? _formatDate(_startDate!)
                      : 'Select start date',
                  style: TextStyle(
                    color: _startDate != null ? null : Colors.grey[600],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // End date
            InkWell(
              onTap: () => _selectEndDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  prefixIcon: Icon(Icons.event),
                ),
                child: Text(
                  _endDate != null ? _formatDate(_endDate!) : 'Select end date',
                  style: TextStyle(
                    color: _endDate != null ? null : Colors.grey[600],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Estimated workers
            TextFormField(
              controller: _estimatedWorkersController,
              decoration: const InputDecoration(
                labelText: 'Estimated Workers',
                hintText: 'Number of workers',
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Estimated workers is required';
                }
                final workers = int.tryParse(value);
                if (workers == null || workers <= 0) {
                  return 'Must be greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Authorized workers section
            Text(
              'Authorized Workers (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'List the names of workers who will be entering the village for this project.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Worker input with add button
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _workerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Worker Name',
                      hintText: 'Enter worker full name',
                      prefixIcon: Icon(Icons.person_add),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final name = _workerNameController.text.trim();
                    if (name.isNotEmpty && !_authorizedWorkers.contains(name)) {
                      setState(() {
                        _authorizedWorkers.add(name);
                        _workerNameController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Add worker',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Workers list
            if (_authorizedWorkers.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authorized Workers (${_authorizedWorkers.length})',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ..._authorizedWorkers.map(
                      (worker) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(worker)),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _authorizedWorkers.remove(worker);
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Info card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Project duration cannot exceed 365 days. Road fee will be calculated by admin after approval.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Permit Request'),
            ),
          ],
        ),
      ),
    );
  }

  /// Select start date
  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  /// Select end date
  Future<void> _selectEndDate(BuildContext context) async {
    final initialDate =
        _endDate ??
        (_startDate?.add(const Duration(days: 30)) ?? DateTime.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final notifier = ref.read(permitProvider.notifier);

    // Resolve authorized workers to include any pending input not yet added via the + button
    final List<String> resolvedWorkers = List<String>.from(_authorizedWorkers);
    final String pendingWorker = _workerNameController.text.trim();
    if (pendingWorker.isNotEmpty && !resolvedWorkers.contains(pendingWorker)) {
      resolvedWorkers.add(pendingWorker);
    }

    final success = await notifier.submitPermit(
      projectType: _selectedProjectType,
      description: _descriptionController.text.trim(),
      contractorName: _contractorNameController.text.trim(),
      contractorContact: _contractorContactController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      estimatedWorkers: int.parse(_estimatedWorkersController.text.trim()),
      authorizedWorkers: resolvedWorkers.isNotEmpty ? resolvedWorkers : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permit request submitted successfully')),
      );
      context.pop();
    } else {
      final errorMessage = ref.read(permitProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

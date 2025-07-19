import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/client.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/client_provider.dart';
import '../../utils/app_theme.dart';

class AddEditAppointmentScreen extends StatefulWidget {
  final Appointment? appointment;
  final Client? preselectedClient;
  final DateTime? preselectedDate;

  const AddEditAppointmentScreen({
    super.key,
    this.appointment,
    this.preselectedClient,
    this.preselectedDate,
  });

  @override
  State<AddEditAppointmentScreen> createState() => _AddEditAppointmentScreenState();
}

class _AddEditAppointmentScreenState extends State<AddEditAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  String _selectedType = 'Consultation';
  String _selectedStatus = 'Scheduled';
  bool _isAllDay = false;
  bool _isRecurring = false;
  String _recurringPattern = 'Weekly';
  int _recurringInterval = 1;
  DateTime? _recurringEndDate;
  bool _isLoading = false;

  final List<String> _appointmentTypes = [
    'Consultation',
    'Court Hearing',
    'Client Meeting',
    'Document Review',
    'Mediation',
    'Deposition',
    'Other'
  ];

  final List<String> _statusOptions = [
    'Scheduled',
    'Confirmed',
    'In Progress',
    'Completed',
    'Cancelled',
    'Rescheduled'
  ];

  final List<String> _recurringPatterns = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients(refresh: true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.appointment != null) {
      final appointment = widget.appointment!;
      _titleController.text = appointment.title;
      _descriptionController.text = appointment.description ?? '';
      _locationController.text = appointment.location ?? '';
      _notesController.text = appointment.notes ?? '';
      _selectedClient = appointment.client;
      _selectedDate = appointment.startDateTime;
      _startTime = TimeOfDay.fromDateTime(appointment.startDateTime);
      _endTime = TimeOfDay.fromDateTime(appointment.endDateTime);
      _selectedType = appointment.appointmentType;
      _selectedStatus = appointment.status;
      _isAllDay = appointment.isAllDay;
      _isRecurring = appointment.isRecurring;
      if (appointment.recurringPattern != null) {
        _recurringPattern = appointment.recurringPattern!['frequency'] ?? 'Weekly';
        _recurringInterval = appointment.recurringPattern!['interval'] ?? 1;
        if (appointment.recurringPattern!['endDate'] != null) {
          _recurringEndDate = DateTime.parse(appointment.recurringPattern!['endDate']);
        }
      }
    } else {
      if (widget.preselectedClient != null) {
        _selectedClient = widget.preselectedClient;
      }
      if (widget.preselectedDate != null) {
        _selectedDate = widget.preselectedDate!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment != null ? 'Edit Appointment' : 'Add Appointment'),
        actions: [
          if (widget.appointment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter appointment title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 16),
              
              // Client Selection
              Consumer<ClientProvider>(
                builder: (context, clientProvider, child) {
                  return DropdownButtonFormField<Client>(
                    value: _selectedClient,
                    decoration: const InputDecoration(
                      labelText: 'Client *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select a client'),
                    items: clientProvider.clients.map((client) {
                      return DropdownMenuItem<Client>(
                        value: client,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (client) {
                      setState(() {
                        _selectedClient = client;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a client';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date and Time Section
              _buildDateTimeSection(),
              
              const SizedBox(height: 16),
              
              // Type and Status Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _appointmentTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (type) {
                        setState(() {
                          _selectedType = type!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(status),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (status) {
                        setState(() {
                          _selectedStatus = status!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location (optional)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description (optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 16),
              
              // Recurring Section
              _buildRecurringSection(),
              
              const SizedBox(height: 16),
              
              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter additional notes (optional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAppointment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.appointment != null ? 'Update Appointment' : 'Save Appointment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Date & Time',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date Selection
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(DateFormat('EEEE, MMM d, y').format(_selectedDate)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // All Day Toggle
            SwitchListTile(
              title: const Text('All Day'),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            if (!_isAllDay) ...[
              const SizedBox(height: 16),
              
              // Time Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time_filled),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.repeat, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Recurring',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Repeat this appointment'),
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _recurringPattern,
                      decoration: const InputDecoration(
                        labelText: 'Repeat',
                        border: OutlineInputBorder(),
                      ),
                      items: _recurringPatterns.map((pattern) {
                        return DropdownMenuItem<String>(
                          value: pattern,
                          child: Text(pattern),
                        );
                      }).toList(),
                      onChanged: (pattern) {
                        setState(() {
                          _recurringPattern = pattern!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _recurringInterval.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Every',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _recurringInterval = int.tryParse(value) ?? 1;
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _selectRecurringEndDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date (Optional)',
                    prefixIcon: Icon(Icons.event),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _recurringEndDate != null
                        ? DateFormat('MMM d, y').format(_recurringEndDate!)
                        : 'No end date',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Automatically adjust end time if it's before start time
          if (_endTime.hour < _startTime.hour || 
              (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
            _endTime = TimeOfDay(
              hour: (_startTime.hour + 1) % 24,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectRecurringEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _recurringEndDate ?? _selectedDate.add(const Duration(days: 30)),
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _recurringEndDate = picked;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate time logic
    if (!_isAllDay) {
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );
      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final startDateTime = _isAllDay
          ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
          : DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _startTime.hour,
              _startTime.minute,
            );

      final endDateTime = _isAllDay
          ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59)
          : DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _endTime.hour,
              _endTime.minute,
            );

      final appointmentData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty 
            ? null : _descriptionController.text.trim(),
        'location': _locationController.text.trim().isEmpty 
            ? null : _locationController.text.trim(),
        'notes': _notesController.text.trim().isEmpty 
            ? null : _notesController.text.trim(),
        'clientId': _selectedClient!.id,
        'startDateTime': startDateTime.toIso8601String(),
        'endDateTime': endDateTime.toIso8601String(),
        'appointmentType': _selectedType,
        'status': _selectedStatus,
        'isAllDay': _isAllDay,
        'isRecurring': _isRecurring,
        'recurringPattern': _isRecurring ? {
          'frequency': _recurringPattern,
          'interval': _recurringInterval,
          'endDate': _recurringEndDate?.toIso8601String(),
        } : null,
      };

      bool success;
      if (widget.appointment != null) {
        success = await context.read<AppointmentProvider>().updateAppointment(
          widget.appointment!.id,
          appointmentData,
        );
      } else {
        success = await context.read<AppointmentProvider>().createAppointment(appointmentData);
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.appointment != null 
                ? 'Appointment updated successfully' 
                : 'Appointment created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.appointment != null 
                ? 'Failed to update appointment' 
                : 'Failed to create appointment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text('Are you sure you want to delete this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              
              final success = await context.read<AppointmentProvider>()
                  .deleteAppointment(widget.appointment!.id);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Appointment deleted successfully' 
                      : 'Failed to delete appointment'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

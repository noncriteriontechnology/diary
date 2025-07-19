import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/client_provider.dart';
import '../../models/client.dart';

class AddEditClientScreen extends StatefulWidget {
  final Client? client;
  
  const AddEditClientScreen({super.key, this.client});

  @override
  State<AddEditClientScreen> createState() => _AddEditClientScreenState();
}

class _AddEditClientScreenState extends State<AddEditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _caseDescriptionController = TextEditingController();
  final _retainerFeeController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  String _selectedCaseType = 'Civil';
  String _selectedStatus = 'Active';
  String _selectedPriority = 'Medium';

  final List<String> _caseTypes = [
    'Criminal', 'Civil', 'Corporate', 'Family', 'Property', 'Tax', 'Labor', 'Constitutional', 'Other'
  ];
  
  final List<String> _statusOptions = ['Active', 'Closed', 'On Hold', 'Pending'];
  final List<String> _priorityOptions = ['Low', 'Medium', 'High', 'Urgent'];

  bool get isEditing => widget.client != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _populateFields();
    }
    _countryController.text = 'India'; // Default country
  }

  void _populateFields() {
    final client = widget.client!;
    _nameController.text = client.name;
    _emailController.text = client.email ?? '';
    _phoneController.text = client.phone;
    _alternatePhoneController.text = client.alternatePhone ?? '';
    _streetController.text = client.address?.street ?? '';
    _cityController.text = client.address?.city ?? '';
    _stateController.text = client.address?.state ?? '';
    _zipCodeController.text = client.address?.zipCode ?? '';
    _countryController.text = client.address?.country ?? 'India';
    _selectedCaseType = client.caseType;
    _caseNumberController.text = client.caseNumber ?? '';
    _caseDescriptionController.text = client.caseDescription ?? '';
    _selectedStatus = client.status;
    _selectedPriority = client.priority;
    _retainerFeeController.text = client.retainerFee?.toString() ?? '';
    _hourlyRateController.text = client.hourlyRate?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _caseNumberController.dispose();
    _caseDescriptionController.dispose();
    _retainerFeeController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    final clientProvider = context.read<ClientProvider>();
    
    final address = {
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'zipCode': _zipCodeController.text.trim(),
      'country': _countryController.text.trim(),
    };

    bool success;
    if (isEditing) {
      success = await clientProvider.updateClient(widget.client!.id, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alternatePhone': _alternatePhoneController.text.trim().isEmpty ? null : _alternatePhoneController.text.trim(),
        'address': address,
        'caseType': _selectedCaseType,
        'caseNumber': _caseNumberController.text.trim().isEmpty ? null : _caseNumberController.text.trim(),
        'caseDescription': _caseDescriptionController.text.trim().isEmpty ? null : _caseDescriptionController.text.trim(),
        'status': _selectedStatus,
        'priority': _selectedPriority,
        'retainerFee': _retainerFeeController.text.trim().isEmpty ? null : double.tryParse(_retainerFeeController.text.trim()),
        'hourlyRate': _hourlyRateController.text.trim().isEmpty ? null : double.tryParse(_hourlyRateController.text.trim()),
      });
    } else {
      success = await clientProvider.createClient(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        alternatePhone: _alternatePhoneController.text.trim().isEmpty ? null : _alternatePhoneController.text.trim(),
        address: address,
        caseType: _selectedCaseType,
        caseNumber: _caseNumberController.text.trim().isEmpty ? null : _caseNumberController.text.trim(),
        caseDescription: _caseDescriptionController.text.trim().isEmpty ? null : _caseDescriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        retainerFee: _retainerFeeController.text.trim().isEmpty ? null : double.tryParse(_retainerFeeController.text.trim()),
        hourlyRate: _hourlyRateController.text.trim().isEmpty ? null : double.tryParse(_hourlyRateController.text.trim()),
      );
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Client updated successfully' : 'Client created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clientProvider.error ?? 'Failed to save client'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Client' : 'Add Client'),
        actions: [
          Consumer<ClientProvider>(
            builder: (context, clientProvider, child) {
              return TextButton(
                onPressed: clientProvider.isLoading ? null : _saveClient,
                child: clientProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              );
            },
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
              // Personal Information
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter client\'s full name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter client\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _alternatePhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Alternate Phone',
                  hintText: 'Enter alternate phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 24),
              
              // Address Information
              Text(
                'Address Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: 'Enter street address',
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        hintText: 'Enter city',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        hintText: 'Enter state',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _zipCodeController,
                      decoration: const InputDecoration(
                        labelText: 'ZIP Code',
                        hintText: 'Enter ZIP code',
                        prefixIcon: Icon(Icons.local_post_office),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'Enter country',
                        prefixIcon: Icon(Icons.public),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Case Information
              Text(
                'Case Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedCaseType,
                decoration: const InputDecoration(
                  labelText: 'Case Type *',
                  prefixIcon: Icon(Icons.gavel),
                ),
                items: _caseTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCaseType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _caseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Case Number',
                  hintText: 'Enter case number',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _caseDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Case Description',
                  hintText: 'Enter case description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: _priorityOptions.map((priority) {
                        return DropdownMenuItem(value: priority, child: Text(priority));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Billing Information
              Text(
                'Billing Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _retainerFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Retainer Fee',
                        hintText: 'Enter retainer fee',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _hourlyRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate',
                        hintText: 'Enter hourly rate',
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Save Button
              Consumer<ClientProvider>(
                builder: (context, clientProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: clientProvider.isLoading ? null : _saveClient,
                      child: clientProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? 'Update Client' : 'Create Client'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

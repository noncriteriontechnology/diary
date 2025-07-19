import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/note_provider.dart';
import '../../utils/app_theme.dart';
import 'add_edit_client_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  final Client client;

  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadClientData() {
    // Load appointments for this client
    context.read<AppointmentProvider>().loadAppointments(
      refresh: true,
      clientId: widget.client.id,
    );
    
    // Load notes for this client
    context.read<NoteProvider>().loadNotes(
      refresh: true,
      clientId: widget.client.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _makePhoneCall(widget.client.phone),
            tooltip: 'Call',
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => _openWhatsApp(widget.client.phone),
            tooltip: 'WhatsApp',
          ),
          PopupMenuButton<String>(
            onSelected: _handleAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Client'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'add_appointment',
                child: ListTile(
                  leading: Icon(Icons.event_add),
                  title: Text('Add Appointment'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'add_note',
                child: ListTile(
                  leading: Icon(Icons.note_add),
                  title: Text('Add Note'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details', icon: Icon(Icons.info)),
            Tab(text: 'Appointments', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Notes', icon: Icon(Icons.note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildAppointmentsTab(),
          _buildNotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _navigateToEditClient();
              break;
            case 1:
              // TODO: Add appointment
              break;
            case 2:
              // TODO: Add note
              break;
          }
        },
        child: Icon(_getFloatingActionButtonIcon()),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.getCaseTypeColor(widget.client.caseType),
                    child: Text(
                      widget.client.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.client.caseType,
                          style: TextStyle(
                            color: AppTheme.getCaseTypeColor(widget.client.caseType),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                widget.client.status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.getStatusColor(widget.client.status),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                widget.client.priority,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: AppTheme.getPriorityColor(widget.client.priority),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Contact Information
          _buildSectionCard(
            'Contact Information',
            Icons.contact_phone,
            [
              _buildInfoRow(Icons.phone, 'Phone', widget.client.phone),
              if (widget.client.alternatePhone != null)
                _buildInfoRow(Icons.phone_outlined, 'Alternate Phone', widget.client.alternatePhone!),
              if (widget.client.email != null)
                _buildInfoRow(Icons.email, 'Email', widget.client.email!),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Address Information
          if (widget.client.address != null && widget.client.address!.fullAddress.isNotEmpty)
            _buildSectionCard(
              'Address',
              Icons.location_on,
              [
                _buildInfoRow(Icons.home, 'Address', widget.client.address!.fullAddress),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Case Information
          _buildSectionCard(
            'Case Information',
            Icons.gavel,
            [
              _buildInfoRow(Icons.category, 'Case Type', widget.client.caseType),
              if (widget.client.caseNumber != null)
                _buildInfoRow(Icons.numbers, 'Case Number', widget.client.caseNumber!),
              if (widget.client.caseDescription != null)
                _buildInfoRow(Icons.description, 'Description', widget.client.caseDescription!),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Billing Information
          if (widget.client.retainerFee != null || widget.client.hourlyRate != null)
            _buildSectionCard(
              'Billing Information',
              Icons.currency_rupee,
              [
                if (widget.client.retainerFee != null)
                  _buildInfoRow(Icons.account_balance_wallet, 'Retainer Fee', 
                    '₹${widget.client.retainerFee!.toStringAsFixed(2)}'),
                if (widget.client.hourlyRate != null)
                  _buildInfoRow(Icons.schedule, 'Hourly Rate', 
                    '₹${widget.client.hourlyRate!.toStringAsFixed(2)}/hr'),
                _buildInfoRow(Icons.receipt, 'Total Billed', 
                  '₹${widget.client.totalBilled.toStringAsFixed(2)}'),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Timeline
          _buildSectionCard(
            'Timeline',
            Icons.timeline,
            [
              _buildInfoRow(Icons.calendar_today, 'Created', 
                DateFormat('MMM d, y').format(widget.client.createdAt)),
              _buildInfoRow(Icons.update, 'Last Updated', 
                DateFormat('MMM d, y').format(widget.client.updatedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, child) {
        final appointments = appointmentProvider.getAppointmentsByClient(widget.client.id);
        
        if (appointmentProvider.isLoading && appointments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Schedule your first appointment with this client',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to add appointment
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule Appointment'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.getStatusColor(appointment.status),
                  child: Icon(
                    Icons.event,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  appointment.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('MMM d, y').format(appointment.startDateTime)} at ${DateFormat('HH:mm').format(appointment.startDateTime)}',
                    ),
                    if (appointment.location != null)
                      Text('Location: ${appointment.location}'),
                    Text(
                      'Type: ${appointment.appointmentType}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    appointment.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppTheme.getStatusColor(appointment.status),
                ),
                onTap: () {
                  // TODO: Navigate to appointment detail
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotesTab() {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final notes = noteProvider.getNotesByClient(widget.client.id);
        
        if (noteProvider.isLoading && notes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notes yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first note for this client',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to add note
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Note'),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.getPriorityColor(note.priority),
                  child: Icon(
                    note.voiceRecording != null ? Icons.mic : Icons.note,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormat('MMM d, y').format(note.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (note.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              children: note.tags.take(2).map((tag) {
                                return Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: note.isFavorite
                    ? const Icon(Icons.favorite, color: Colors.red, size: 16)
                    : null,
                onTap: () {
                  // TODO: Navigate to note detail
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFloatingActionButtonIcon() {
    switch (_tabController.index) {
      case 0:
        return Icons.edit;
      case 1:
        return Icons.event_add;
      case 2:
        return Icons.note_add;
      default:
        return Icons.add;
    }
  }

  void _handleAction(String action) {
    switch (action) {
      case 'edit':
        _navigateToEditClient();
        break;
      case 'add_appointment':
        // TODO: Navigate to add appointment
        break;
      case 'add_note':
        // TODO: Navigate to add note
        break;
    }
  }

  void _navigateToEditClient() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditClientScreen(client: widget.client),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }
}

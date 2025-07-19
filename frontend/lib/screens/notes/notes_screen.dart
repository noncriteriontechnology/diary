import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/note_provider.dart';
import '../../models/note.dart';
import '../../utils/app_theme.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    context.read<NoteProvider>().loadNotes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          if (_searchController.text.isNotEmpty || _selectedFilter != 'All')
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  if (_searchController.text.isNotEmpty) ...[
                    Chip(
                      label: Text('Search: ${_searchController.text}'),
                      onDeleted: () {
                        setState(() {
                          _searchController.clear();
                        });
                        _loadNotes();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_selectedFilter != 'All') ...[
                    Chip(
                      label: Text('Filter: $_selectedFilter'),
                      onDeleted: () {
                        setState(() {
                          _selectedFilter = 'All';
                        });
                        _loadNotes();
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  Text(
                    'Sort: $_selectedSort',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          // Notes List
          Expanded(
            child: _buildNotesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditNoteScreen(),
                    ),
                  );
                },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotesList() {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (noteProvider.isLoading && noteProvider.notes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (noteProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading notes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  noteProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadNotes,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final filteredNotes = _getFilteredNotes(noteProvider.notes);
        
        if (filteredNotes.isEmpty) {
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
                  noteProvider.notes.isEmpty ? 'No notes yet' : 'No matching notes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  noteProvider.notes.isEmpty 
                    ? 'Create your first note'
                    : 'Try adjusting your search or filters',
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
        
        return RefreshIndicator(
          onRefresh: () async => _loadNotes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredNotes.length + 
                      (noteProvider.hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredNotes.length) {
                // Load more indicator
                if (noteProvider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => noteProvider.loadNotes(),
                      child: const Text('Load More'),
                    ),
                  );
                }
              }
              
              final note = filteredNotes[index];
              return _buildNoteCard(note);
            },
          ),
        );
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to note detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.getPriorityColor(note.priority),
                    radius: 20,
                    child: Icon(
                      note.voiceRecording != null ? Icons.mic : Icons.note,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (note.isFavorite)
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (note.client != null)
                          Text(
                            'Client: ${note.client!.name}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleNoteAction(value, note),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'favorite',
                        child: ListTile(
                          leading: Icon(
                            note.isFavorite ? Icons.favorite_border : Icons.favorite,
                          ),
                          title: Text(note.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: ListTile(
                          leading: Icon(Icons.share),
                          title: Text('Share'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content
              Text(
                note.content,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              if (note.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: note.tags.take(3).map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 10),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 8),
              
              // Footer Row
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, y • HH:mm').format(note.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (note.voiceRecording != null) ...[
                    Icon(Icons.mic, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Voice',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (note.attachments.isNotEmpty) ...[
                    Icon(Icons.attach_file, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${note.attachments.length}',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Chip(
                    label: Text(
                      note.priority,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppTheme.getPriorityColor(note.priority),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Note> _getFilteredNotes(List<Note> notes) {
    List<Note> filtered = notes;
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((note) {
        return note.title.toLowerCase().contains(query) ||
               note.content.toLowerCase().contains(query) ||
               note.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    
    // Apply category filter
    if (_selectedFilter != 'All') {
      switch (_selectedFilter) {
        case 'Favorites':
          filtered = filtered.where((note) => note.isFavorite).toList();
          break;
        case 'Voice Notes':
          filtered = filtered.where((note) => note.voiceRecording != null).toList();
          break;
        case 'High Priority':
          filtered = filtered.where((note) => note.priority == 'High').toList();
          break;
        case 'With Attachments':
          filtered = filtered.where((note) => note.attachments.isNotEmpty).toList();
          break;
      }
    }
    
    // Apply sorting
    switch (_selectedSort) {
      case 'Recent':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Title A-Z':
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Title Z-A':
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Priority':
        filtered.sort((a, b) {
          const priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
          return (priorityOrder[b.priority] ?? 0).compareTo(priorityOrder[a.priority] ?? 0);
        });
        break;
    }
    
    return filtered;
  }

  void _handleNoteAction(String action, Note note) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit note
        break;
      case 'favorite':
        _toggleFavorite(note);
        break;
      case 'share':
        _shareNote(note);
        break;
      case 'delete':
        _showDeleteConfirmation(note);
        break;
    }
  }

  void _toggleFavorite(Note note) async {
    final success = await context.read<NoteProvider>().updateNote(
      note.id,
      {'isFavorite': !note.isFavorite},
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? (note.isFavorite ? 'Removed from favorites' : 'Added to favorites')
            : 'Failed to update note'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _shareNote(Note note) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon')),
    );
  }

  void _showDeleteConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<NoteProvider>()
                  .deleteNote(note.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Note deleted' 
                      : 'Failed to delete note'),
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Notes'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter search terms...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchController.clear();
              Navigator.pop(context);
              _loadNotes();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
              _loadNotes();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['All', 'Favorites', 'Voice Notes', 'High Priority', 'With Attachments']
                  .map((filter) => FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Recent', 'Oldest', 'Title A-Z', 'Title Z-A', 'Priority']
                  .map((sort) => FilterChip(
                        label: Text(sort),
                        selected: _selectedSort == sort,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSort = sort;
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _selectedSort = 'Recent';
              });
              Navigator.pop(context);
              _loadNotes();
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
              _loadNotes();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

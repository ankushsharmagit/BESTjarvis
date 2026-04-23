// lib/screens/routine_screen.dart
// Automation Routine Management Screen

import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../models/routine_model.dart';
import '../widgets/glassmorphic_card.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({Key? key}) : super(key: key);

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<Routine> _routines = [];
  String _selectedCategory = 'all';
  
  final List<String> _categories = ['all', 'morning', 'night', 'office', 'driving', 'gaming', 'study', 'custom'];
  
  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }
  
  void _loadRoutines() {
    _routines = PrebuiltRoutines.getAllPrebuilt();
  }
  
  List<Routine> get _filteredRoutines {
    if (_selectedCategory == 'all') return _routines;
    return _routines.where((r) => r.type.toString().split('.').last == _selectedCategory).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JarvisColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Automation Routines'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: JarvisColors.accentCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: JarvisColors.accentCyan),
            onPressed: _createNewRoutine,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.toUpperCase()),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : 'all';
                      });
                    },
                    backgroundColor: JarvisColors.bgCard,
                    selectedColor: JarvisColors.accentCyan.withOpacity(0.3),
                    checkmarkColor: JarvisColors.accentCyan,
                  ),
                );
              },
            ),
          ),
          
          // Routines List
          Expanded(
            child: _filteredRoutines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 64, color: JarvisColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          'No routines found',
                          style: TextStyle(color: JarvisColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _createNewRoutine,
                          child: const Text('Create Routine'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRoutines.length,
                    itemBuilder: (context, index) {
                      final routine = _filteredRoutines[index];
                      return _buildRoutineCard(routine);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRoutine,
        backgroundColor: JarvisColors.accentCyan,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
  
  Widget _buildRoutineCard(Routine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: JarvisColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JarvisColors.borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: JarvisColors.accentCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  routine.getIcon(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              routine.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.description,
                  style: TextStyle(fontSize: 12, color: JarvisColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '⏱️ ${routine.actions.length} actions • 🔁 ${routine.executionCount} times',
                  style: TextStyle(fontSize: 10, color: JarvisColors.textHint),
                ),
              ],
            ),
            trailing: Switch(
              value: routine.isActive,
              onChanged: (value) {
                setState(() {
                  routine.isActive = value;
                });
              },
              activeColor: JarvisColors.success,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: JarvisColors.bgPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    routine.trigger.getTriggerDescription(),
                    style: TextStyle(fontSize: 10, color: JarvisColors.accentCyan),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit', style: TextStyle(color: JarvisColors.accentCyan)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Run Now', style: TextStyle(color: JarvisColors.success)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _createNewRoutine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Routine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Routine Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Trigger Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'voice', child: Text('Voice Command')),
                DropdownMenuItem(value: 'time', child: Text('Scheduled Time')),
                DropdownMenuItem(value: 'location', child: Text('Location')),
                DropdownMenuItem(value: 'battery', child: Text('Battery Level')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: JarvisColors.accentCyan),
            child: const Text('Create', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/task.dart';
import '../../data/models/task_filter.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../settings/settings_page.dart';
import '../task/task_form_page.dart';
import '../widgets/empty_state.dart';
import 'completed_tasks_page.dart';
import 'repeated_tasks_page.dart';
import 'today_tasks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final TextEditingController _searchController = TextEditingController();
  TaskPriority? _priorityFilter;
  String? _tagFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TaskViewModel>();
      vm.ensurePermissionsAndReschedule();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters(TaskViewModel vm) {
    vm.applyFilter(
      TaskFilter(
        query: _searchController.text,
        priority: _priorityFilter,
        tagName: _tagFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewModel>();
    final pageTitles = ['Today', 'Repeated', 'Completed'];
    final tabs = [
      TodayTasksPage(tasks: vm.todayTasks),
      RepeatedTasksPage(tasks: vm.repeatingTasks),
      CompletedTasksPage(tasks: vm.completedTasks),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(vm),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showSearch<String?>(
                context: context,
                delegate: _TaskSearchDelegate(
                  initialQuery: _searchController.text,
                ),
              );
              if (query != null) {
                _searchController.text = query;
                _applyFilters(vm);
              }
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tabs[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskFormPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.repeat), label: 'Repeated'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Completed'),
        ],
      ),
    );
  }

  void _showFilterSheet(TaskViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search tasks',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (_) => _applyFilters(vm),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority?>(
                initialValue: _priorityFilter,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  const DropdownMenuItem<TaskPriority?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ...TaskPriority.values.map(
                    (priority) => DropdownMenuItem<TaskPriority?>(
                      value: priority,
                      child: Text(priority.label),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _priorityFilter = value);
                  _applyFilters(vm);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _tagFilter,
                decoration: const InputDecoration(labelText: 'Tag'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ...vm.availableTags.map(
                    (tag) => DropdownMenuItem<String?>(
                      value: tag.name,
                      child: Text(tag.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _tagFilter = value);
                  _applyFilters(vm);
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear filters'),
                  onPressed: () {
                    _searchController.clear();
                    _priorityFilter = null;
                    _tagFilter = null;
                    vm.clearFilters();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskSearchDelegate extends SearchDelegate<String?> {
  _TaskSearchDelegate({String? initialQuery}) {
    query = initialQuery ?? '';
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSuggestions(context);

  Widget _buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const EmptyState(
        title: 'Search tasks',
        subtitle: 'Type a keyword to filter your tasks.',
      );
    }
    return ListTile(
      leading: const Icon(Icons.search),
      title: Text('Search "$query"'),
      onTap: () => close(context, query),
    );
  }
}

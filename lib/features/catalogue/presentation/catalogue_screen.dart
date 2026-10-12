import 'package:flutter/material.dart';

import '../domain/practical_registry.dart';

class CatalogueScreen extends StatefulWidget {
  final PracticalRegistry registry;
  const CatalogueScreen({super.key, required this.registry});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  String? selectedSemester;
  String? selectedSubject;

  @override
  Widget build(BuildContext context) {
    final defs = widget.registry.all;
    final semesters = widget.registry.semesterIds;
    final subjects = defs
        .where(
          (d) => selectedSemester == null || d.semesterId == selectedSemester,
        )
        .map((d) => (d.subjectId, d.subjectLabel))
        .toSet()
        .toList();
    final practicals = defs
        .where(
          (d) =>
              (selectedSemester == null || d.semesterId == selectedSemester) &&
              (selectedSubject == null || d.subjectId == selectedSubject),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Pharmaceutical Lab')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _filters(semesters, subjects)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _practicalList(practicals)),
                    ],
                  )
                : ListView(
                    children: [
                      _filters(semesters, subjects),
                      const SizedBox(height: 16),
                      _practicalList(practicals),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _filters(List<String> semesters, List<(String, String)> subjects) {
    String semLabel(String id) {
      final d = widget.registry.all.firstWhere((e) => e.semesterId == id);
      return d.semesterLabel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Semester', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedSemester == null,
              onSelected: (_) => setState(() {
                selectedSemester = null;
                selectedSubject = null;
              }),
            ),
            for (final s in semesters)
              ChoiceChip(
                label: Text(semLabel(s)),
                selected: selectedSemester == s,
                onSelected: (_) => setState(() {
                  selectedSemester = s;
                  selectedSubject = null;
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Subject', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedSubject == null,
              onSelected: (_) => setState(() => selectedSubject = null),
            ),
            for (final sub in subjects)
              ChoiceChip(
                label: Text(sub.$2),
                selected: selectedSubject == sub.$1,
                onSelected: (_) => setState(() => selectedSubject = sub.$1),
              ),
          ],
        ),
      ],
    );
  }

  Widget _practicalList(List defs) {
    if (defs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No practicals match this filter.'),
        ),
      );
    }
    return Column(
      children: [
        for (final d in defs)
          Card(
            child: ListTile(
              title: Text(d.title),
              subtitle: Text('${d.semesterLabel} • ${d.subjectLabel}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.pushNamed(
                context,
                '/overview',
                arguments: (d as dynamic).id as String,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../../design_system.dart';
import '../../services/learning_service.dart';
import '../../services/localization_service.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({Key? key}) : super(key: key);

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final learning = Provider.of<LearningService>(context);
    final loc = Provider.of<LocalizationService>(context);

    final filteredTerms = learning.glossaryTerms.where((t) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.term.toLowerCase().contains(q) ||
          t.definition.toLowerCase().contains(q) ||
          t.simpleExample.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tr('glossary_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.tr('glossary_subtitle'),
                style: AppDesign.body.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppDesign.spaceMedium),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search words (e.g. Wi-Fi, QR code)...',
                  prefixIcon: const Icon(Icons.search, size: 28),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: AppDesign.spaceMedium),
              Expanded(
                child: filteredTerms.isEmpty
                    ? const Center(
                        child: Text(
                          'No terms found matching your search.',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTerms.length,
                        itemBuilder: (context, i) {
                          final term = filteredTerms[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppDesign.spaceSmall),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppDesign.spaceMedium),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(_getIconData(term.iconName), size: 30, color: Colors.blue.shade800),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              term.term,
                                              style: AppDesign.title.copyWith(fontSize: 20, color: Colors.blue.shade900),
                                            ),
                                            if (term.relatedCategory != null)
                                              Text(
                                                'Used in: ${term.relatedCategory}',
                                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    term.definition,
                                    style: AppDesign.body.copyWith(fontSize: 18, height: 1.3),
                                  ),
                                  if (term.simpleExample.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.amber.shade200),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('💡 ', style: TextStyle(fontSize: 18)),
                                          Expanded(
                                            child: Text(
                                              'Example: ${term.simpleExample}',
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      case 'attach_file':
        return Icons.attach_file;
      case 'person':
        return Icons.person;
      case 'download':
        return Icons.download;
      case 'mic':
        return Icons.mic;
      case 'settings':
        return Icons.settings;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.help_outline;
    }
  }
}

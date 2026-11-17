import 'package:flutter/material.dart';
import '../design_system.dart';
import '../models/category.dart';
import 'category_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Category> _categories = [];
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/categories.json');
      final data = json.decode(jsonStr) as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _categories = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'We could not load the lessons. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')), // Simple welcome
      body: Padding(
        padding: const EdgeInsets.all(AppDesign.spaceMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Learn how to use your smartphone', style: AppDesign.headline),
            const SizedBox(height: AppDesign.spaceMedium),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_loadError!, style: AppDesign.body, textAlign: TextAlign.center), const SizedBox(height: 16), ElevatedButton(onPressed: () { setState(() { _loading = true; _loadError = null; }); _loadCategories(); }, child: const Text('Try again'))]))
                  : _categories.isEmpty
                      ? const Center(child: Text('No learning categories are available yet.', style: AppDesign.body, textAlign: TextAlign.center))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppDesign.spaceMedium,
                        crossAxisSpacing: AppDesign.spaceMedium,
                        childAspectRatio: 1,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        return Card(
                          elevation: 2,
                          child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CategoryScreen(category: cat)),
                          ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppDesign.spaceSmall),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: Image.asset(cat.imageAsset, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.smartphone, size: 56, semanticLabel: 'Smartphone'))),
                                  const SizedBox(height: AppDesign.spaceSmall),
                                  Text(cat.title, style: AppDesign.title, textAlign: TextAlign.center),
                                  const SizedBox(height: AppDesign.spaceSmall),
                                  Text(cat.description, style: AppDesign.body, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

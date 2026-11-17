import 'package:material_ui/material_ui.dart';

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
  static Future<List<Category>>? _categoriesFuture;

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
      final categories = await (_categoriesFuture ??= _readCategories());
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Failed to load learning categories: $error');
      _categoriesFuture = null;
      if (!mounted) return;
      setState(() {
        _loadError = 'We could not load the lessons. Please try again.';
        _loading = false;
      });
    }
  }

  static Future<List<Category>> _readCategories() async {
    final jsonStr = await rootBundle.loadString('assets/data/categories.json');
    final data = json.decode(jsonStr) as List<dynamic>;
    return data
        .map((entry) => Category.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 3 : 2;
    final childAspectRatio = isTablet ? 1.0 : 0.82;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesign.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learn how to use your smartphone',
                style: AppDesign.headline,
              ),
              const SizedBox(height: AppDesign.spaceSmall),
              const Text(
                'Tap any topic below to begin with easy step-by-step guidance.',
                style: AppDesign.body,
              ),
              const SizedBox(height: AppDesign.spaceMedium),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _loadError!,
                              style: AppDesign.body,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _loadError = null;
                                });
                                _loadCategories();
                              },
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      )
                    : _categories.isEmpty
                    ? const Center(
                        child: Text(
                          'No learning categories are available yet.',
                          style: AppDesign.body,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: AppDesign.spaceMedium,
                          crossAxisSpacing: AppDesign.spaceMedium,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryScreen(category: cat),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  AppDesign.spaceSmall,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Image.asset(
                                          cat.imageAsset,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                Icons.smartphone,
                                                size: 56,
                                                semanticLabel: 'Smartphone',
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: AppDesign.spaceSmall,
                                    ),
                                    Text(
                                      cat.title,
                                      style: AppDesign.title,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat.description,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
      ),
    );
  }
}

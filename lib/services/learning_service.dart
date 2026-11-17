import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';
import '../models/category.dart';
import '../models/glossary_term.dart';
import '../models/lesson.dart';
import '../models/task.dart';

class LearningService extends ChangeNotifier {
  List<Category> _categories = List.from(_fallbackCategories);
  List<GlossaryTerm> _glossaryTerms = List.from(_defaultGlossaryTerms);
  final Set<String> _completedLessonIds = {};
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => List.unmodifiable(_categories);
  List<GlossaryTerm> get glossaryTerms => List.unmodifiable(_glossaryTerms);
  Set<String> get completedLessonIds => Set.unmodifiable(_completedLessonIds);
  bool get isLoading => _isLoading;
  String? get error => _error;

  LearningService({bool autoLoad = true}) {
    if (autoLoad) {
      loadContent();
    }
  }

  Future<void> loadContent() async {
    _error = null;

    try {
      // 1. Load Categories & Lessons
      final catJson = await rootBundle.loadString('assets/data/categories.json');
      final data = json.decode(catJson) as List<dynamic>;
      _categories = data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      // keep fallback
    }

    try {
      // 2. Load Glossary
      final glossJson = await rootBundle.loadString('assets/data/glossary.json');
      final gData = json.decode(glossJson) as List<dynamic>;
      _glossaryTerms = gData.map((e) => GlossaryTerm.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (e) {
      // keep fallback
    }
  }

  void markLessonCompleted(String lessonId) {
    if (!_completedLessonIds.contains(lessonId)) {
      _completedLessonIds.add(lessonId);
      notifyListeners();
    }
  }

  bool isLessonCompleted(String lessonId) {
    return _completedLessonIds.contains(lessonId);
  }

  double get overallProgressPercentage {
    final allLessons = getAllLessons();
    if (allLessons.isEmpty) return 0.0;
    return _completedLessonIds.length / allLessons.length;
  }

  List<Lesson> getAllLessons() {
    final list = <Lesson>[];
    for (final cat in _categories) {
      for (final task in cat.tasks) {
        list.addAll(task.lessons);
      }
    }
    return list;
  }

  Lesson? findLessonById(String id) {
    for (final cat in _categories) {
      for (final task in cat.tasks) {
        for (final l in task.lessons) {
          if (l.id == id) return l;
        }
      }
    }
    return null;
  }

  Category? findCategoryByLessonId(String id) {
    for (final cat in _categories) {
      for (final task in cat.tasks) {
        for (final l in task.lessons) {
          if (l.id == id) return cat;
        }
      }
    }
    return null;
  }

  Task? findTaskByLessonId(String id) {
    for (final cat in _categories) {
      for (final task in cat.tasks) {
        for (final l in task.lessons) {
          if (l.id == id) return task;
        }
      }
    }
    return null;
  }

  // Robust fallback data ensuring app works even if json asset is missing
  static final List<GlossaryTerm> _defaultGlossaryTerms = [
    const GlossaryTerm(
      id: 'g_qr',
      term: 'QR Code',
      definition: 'A square barcode made of black and white shapes that your camera can read to open a website, menu, or payment.',
      simpleExample: 'Like scanning a paper menu at a restaurant using your phone camera.',
      iconName: 'qr_code_scanner',
      relatedCategory: 'QR Codes',
    ),
    const GlossaryTerm(
      id: 'g_attachment',
      term: 'Attachment',
      definition: 'A photo, video, or paper document that you clip to a message to send to someone else.',
      simpleExample: 'Like putting a printed photo into a mailing envelope before sealing it.',
      iconName: 'attach_file',
      relatedCategory: 'WhatsApp',
    ),
    const GlossaryTerm(
      id: 'g_contact',
      term: 'Contact',
      definition: 'The name and phone number of a person saved in your phone address book.',
      simpleExample: 'Your daughter, doctor, or neighbor saved in your phone.',
      iconName: 'person',
      relatedCategory: 'Smartphone Basics',
    ),
    const GlossaryTerm(
      id: 'g_download',
      term: 'Download',
      definition: 'Saving a picture, song, or document from the internet onto your own phone storage.',
      simpleExample: 'Saving a recipe photo someone sent you so you can see it without internet.',
      iconName: 'download',
      relatedCategory: 'Internet & Browsing',
    ),
    const GlossaryTerm(
      id: 'g_microphone',
      term: 'Microphone',
      definition: 'The tiny audio sensor in your phone that hears your voice when speaking on calls or sending voice messages.',
      simpleExample: 'Tap the microphone icon to speak instead of typing with your fingers.',
      iconName: 'mic',
      relatedCategory: 'Voice Groups',
    ),
    const GlossaryTerm(
      id: 'g_settings',
      term: 'Settings',
      definition: 'The phone control center where you can make text larger, adjust volume, or turn on Wi-Fi.',
      simpleExample: 'Looks like a small gear or wheel on your home screen.',
      iconName: 'settings',
      relatedCategory: 'Smartphone Basics',
    ),
    const GlossaryTerm(
      id: 'g_wifi',
      term: 'Wi-Fi',
      definition: 'Wireless internet in your home or cafe that lets your phone connect without using mobile data.',
      simpleExample: 'Looks like small curved radio waves in the top corner of your screen.',
      iconName: 'wifi',
      relatedCategory: 'Smartphone Basics',
    ),
  ];

  static final List<Category> _fallbackCategories = _buildFallbackCategories();

  static List<Category> _buildFallbackCategories() {
    final List<dynamic> data = json.decode(_defaultCategoriesJson) as List<dynamic>;
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  static const String _defaultCategoriesJson = r'''[
  {
    "id": "cat1",
    "title": "WhatsApp",
    "description": "Learn how to use WhatsApp for messaging family and friends.",
    "imageAsset": "assets/images/whatsapp.png",
    "tasks": [
      {
        "id": "task1",
        "title": "Send a WhatsApp Message",
        "description": "Step‑by‑step guide to open WhatsApp and send a text message.",
        "lessons": [
          {
            "id": "lesson1",
            "title": "Open WhatsApp and Send Message",
            "description": "Learn to find WhatsApp, choose a contact, and send a message.",
            "steps": [
              {
                "order": 1,
                "text": "Tap the green WhatsApp icon on your phone's home screen.",
                "image": "assets/images/whatsapp_step1.png"
              },
              {
                "order": 2,
                "text": "Tap the green chat button in the bottom right corner.",
                "image": "assets/images/whatsapp_step2.png"
              },
              {
                "order": 3,
                "text": "Find and tap the name of the person you want to message.",
                "image": "assets/images/whatsapp_step3.png"
              },
              {
                "order": 4,
                "text": "Tap the message box at the bottom and type your words.",
                "image": "assets/images/whatsapp_step4.png"
              },
              {
                "order": 5,
                "text": "Tap the green paper-plane button on the right to send.",
                "image": "assets/images/whatsapp_step5.png"
              }
            ]
          }
        ]
      },
      {
        "id": "task2",
        "title": "Send a Photo on WhatsApp",
        "description": "Share memorable pictures with your loved ones.",
        "lessons": [
          {
            "id": "lesson2",
            "title": "Pick and Send a Photo",
            "description": "Tap the paperclip icon in a chat, select Gallery, and tap Send.",
            "steps": [
              {
                "order": 1,
                "text": "Open a chat with the person you want to send a photo to.",
                "image": "assets/images/whatsapp_step3.png"
              },
              {
                "order": 2,
                "text": "Tap the paperclip or camera icon next to the message box.",
                "image": "assets/images/whatsapp_step4.png"
              },
              {
                "order": 3,
                "text": "Select your photo and tap the green send button.",
                "image": "assets/images/whatsapp_step5.png"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "cat2",
    "title": "Smartphone Basics",
    "description": "Understand basic buttons, volume, and turning your phone on or off.",
    "imageAsset": "assets/images/basics.png",
    "tasks": [
      {
        "id": "task_basics_1",
        "title": "Adjust the Sound Volume",
        "description": "Learn how to make the ringtone and voice louder or softer.",
        "lessons": [
          {
            "id": "lesson_basics_1",
            "title": "Using the Volume Buttons",
            "description": "Press the long button on the side of your phone to adjust sound.",
            "steps": [
              {
                "order": 1,
                "text": "Locate the volume buttons on the left or right side of your phone.",
                "image": "assets/images/basics.png"
              },
              {
                "order": 2,
                "text": "Press the top button to make it louder, or the bottom button to make it quieter.",
                "image": "assets/images/basics.png"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "cat3",
    "title": "Google Maps",
    "description": "Find directions, search nearby clinics, grocery stores, and bus stops.",
    "imageAsset": "assets/images/maps.png",
    "tasks": [
      {
        "id": "task_maps_1",
        "title": "Search for a Place Nearby",
        "description": "Type a hospital, park, or shop name to see where it is.",
        "lessons": [
          {
            "id": "lesson_maps_1",
            "title": "Finding a Destination",
            "description": "Open Maps and type the address in the top search bar.",
            "steps": [
              {
                "order": 1,
                "text": "Tap the Google Maps icon on your home screen.",
                "image": "assets/images/maps.png"
              },
              {
                "order": 2,
                "text": "Tap the search bar at the very top and type the destination.",
                "image": "assets/images/maps.png"
              },
              {
                "order": 3,
                "text": "Tap the blue 'Directions' button to see how to get there.",
                "image": "assets/images/maps.png"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "cat4",
    "title": "QR Codes",
    "description": "Easily scan restaurant menus, payment codes, and information boards.",
    "imageAsset": "assets/images/qr.png",
    "tasks": [
      {
        "id": "task_qr_1",
        "title": "How to Scan a QR Code",
        "description": "Use your phone camera to scan a square barcode.",
        "lessons": [
          {
            "id": "lesson_qr_1",
            "title": "Point and Scan",
            "description": "Open the camera and point it at the square code.",
            "steps": [
              {
                "order": 1,
                "text": "Open your phone's Camera app.",
                "image": "assets/images/qr.png"
              },
              {
                "order": 2,
                "text": "Hold your phone steady in front of the black-and-white square.",
                "image": "assets/images/qr.png"
              },
              {
                "order": 3,
                "text": "A link will appear on your screen. Tap it to open.",
                "image": "assets/images/qr.png"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "cat5",
    "title": "Photos & Gallery",
    "description": "Look at family pictures, zoom in on photos, and organize albums.",
    "imageAsset": "assets/images/photos.png",
    "tasks": [
      {
        "id": "task_photos_1",
        "title": "Viewing and Zooming In",
        "description": "See your photos bigger by spreading two fingers on the screen.",
        "lessons": [
          {
            "id": "lesson_photos_1",
            "title": "Zooming into a Photo",
            "description": "Double-tap or pinch to make pictures larger and clearer.",
            "steps": [
              {
                "order": 1,
                "text": "Open the Photos or Gallery app.",
                "image": "assets/images/photos.png"
              },
              {
                "order": 2,
                "text": "Tap any photo once to open it full screen.",
                "image": "assets/images/photos.png"
              },
              {
                "order": 3,
                "text": "Pinch outward with two fingers to zoom in and see details.",
                "image": "assets/images/photos.png"
              }
            ]
          }
        ]
      }
    ]
  },
  {
    "id": "cat6",
    "title": "Internet & Browsing",
    "description": "Search for news, read recipes, and look up answers on the web.",
    "imageAsset": "assets/images/internet.png",
    "tasks": [
      {
        "id": "task_internet_1",
        "title": "Search for Information",
        "description": "Use Google to find answers to any question.",
        "lessons": [
          {
            "id": "lesson_internet_1",
            "title": "Searching on Chrome",
            "description": "Type your question into the address bar at the top.",
            "steps": [
              {
                "order": 1,
                "text": "Open the Chrome browser app.",
                "image": "assets/images/internet.png"
              },
              {
                "order": 2,
                "text": "Tap the bar at the top and type what you want to learn.",
                "image": "assets/images/internet.png"
              },
              {
                "order": 3,
                "text": "Press Search or Enter on your keyboard to see the results.",
                "image": "assets/images/internet.png"
              }
            ]
          }
        ]
      }
    ]
  }
]''';
}

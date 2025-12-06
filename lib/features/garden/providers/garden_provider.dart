// ============================================================================
// IDLEMAN v16.0 - FIREBASE GARDEN PROVIDER
// ============================================================================
// File: lib/features/garden/providers/garden_provider.dart
// Purpose: Community garden with anonymous time logging
// Philosophy: Shared growth, compassionate community
// ============================================================================

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// GARDEN STATE
// ============================================================================
@immutable
class GardenState {
  final bool isAuthenticated;
  final String? anonymousId;
  final int totalMinutesReclaimed;
  final int todayMinutesReclaimed;
  final int currentStreak;
  final int longestStreak;
  final List<GardenPlant> myPlants;
  final List<CommunityGardener> communityGardeners;
  final GardenWeather currentWeather;
  final bool isLoading;
  final String? error;

  const GardenState({
    this.isAuthenticated = false,
    this.anonymousId,
    this.totalMinutesReclaimed = 0,
    this.todayMinutesReclaimed = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.myPlants = const [],
    this.communityGardeners = const [],
    this.currentWeather = GardenWeather.sunny,
    this.isLoading = false,
    this.error,
  });

  GardenState copyWith({
    bool? isAuthenticated,
    String? anonymousId,
    int? totalMinutesReclaimed,
    int? todayMinutesReclaimed,
    int? currentStreak,
    int? longestStreak,
    List<GardenPlant>? myPlants,
    List<CommunityGardener>? communityGardeners,
    GardenWeather? currentWeather,
    bool? isLoading,
    String? error,
  }) {
    return GardenState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      anonymousId: anonymousId ?? this.anonymousId,
      totalMinutesReclaimed: totalMinutesReclaimed ?? this.totalMinutesReclaimed,
      todayMinutesReclaimed: todayMinutesReclaimed ?? this.todayMinutesReclaimed,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      myPlants: myPlants ?? this.myPlants,
      communityGardeners: communityGardeners ?? this.communityGardeners,
      currentWeather: currentWeather ?? this.currentWeather,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Garden level based on total minutes
  int get gardenLevel => (totalMinutesReclaimed / 60).floor().clamp(0, 50);

  // Experience progress to next level (0.0 - 1.0)
  double get levelProgress {
    final current = totalMinutesReclaimed % 60;
    return current / 60;
  }

  // Growth rate multiplier based on streak
  double get growthMultiplier {
    if (currentStreak >= 30) return 2.0;
    if (currentStreak >= 14) return 1.5;
    if (currentStreak >= 7) return 1.25;
    return 1.0;
  }
}

// ============================================================================
// GARDEN PLANT
// ============================================================================
class GardenPlant {
  final String id;
  final PlantType type;
  final int growthStage; // 0-4 (seed, sprout, growing, mature, blooming)
  final DateTime plantedAt;
  final int minutesInvested;
  final String? customName;

  const GardenPlant({
    required this.id,
    required this.type,
    this.growthStage = 0,
    required this.plantedAt,
    this.minutesInvested = 0,
    this.customName,
  });

  bool get isFullyGrown => growthStage >= 4;

  String get displayName => customName ?? type.defaultName;

  String get stageEmoji {
    switch (growthStage) {
      case 0:
        return '🌱';
      case 1:
        return type.sproutEmoji;
      case 2:
        return type.growingEmoji;
      case 3:
        return type.matureEmoji;
      case 4:
        return type.bloomEmoji;
      default:
        return '🌱';
    }
  }

  GardenPlant copyWith({
    String? id,
    PlantType? type,
    int? growthStage,
    DateTime? plantedAt,
    int? minutesInvested,
    String? customName,
  }) {
    return GardenPlant(
      id: id ?? this.id,
      type: type ?? this.type,
      growthStage: growthStage ?? this.growthStage,
      plantedAt: plantedAt ?? this.plantedAt,
      minutesInvested: minutesInvested ?? this.minutesInvested,
      customName: customName ?? this.customName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'growthStage': growthStage,
        'plantedAt': plantedAt.toIso8601String(),
        'minutesInvested': minutesInvested,
        'customName': customName,
      };

  factory GardenPlant.fromJson(Map<String, dynamic> json) => GardenPlant(
        id: json['id'] as String,
        type: PlantType.values[json['type'] as int],
        growthStage: json['growthStage'] as int,
        plantedAt: DateTime.parse(json['plantedAt'] as String),
        minutesInvested: json['minutesInvested'] as int? ?? 0,
        customName: json['customName'] as String?,
      );
}

enum PlantType {
  sunflower(
    defaultName: 'Sunflower',
    sproutEmoji: '🌿',
    growingEmoji: '🌻',
    matureEmoji: '🌻',
    bloomEmoji: '🌻',
    minutesToGrow: 60,
  ),
  tulip(
    defaultName: 'Tulip',
    sproutEmoji: '🌿',
    growingEmoji: '🌷',
    matureEmoji: '🌷',
    bloomEmoji: '🌷',
    minutesToGrow: 45,
  ),
  rose(
    defaultName: 'Rose',
    sproutEmoji: '🌿',
    growingEmoji: '🥀',
    matureEmoji: '🌹',
    bloomEmoji: '🌹',
    minutesToGrow: 90,
  ),
  cherry(
    defaultName: 'Cherry Blossom',
    sproutEmoji: '🌿',
    growingEmoji: '🌿',
    matureEmoji: '🌸',
    bloomEmoji: '🌸',
    minutesToGrow: 120,
  ),
  bamboo(
    defaultName: 'Bamboo',
    sproutEmoji: '🎍',
    growingEmoji: '🎍',
    matureEmoji: '🎋',
    bloomEmoji: '🎋',
    minutesToGrow: 180,
  ),
  bonsai(
    defaultName: 'Bonsai',
    sproutEmoji: '🌱',
    growingEmoji: '🌲',
    matureEmoji: '🌳',
    bloomEmoji: '🎄',
    minutesToGrow: 300,
  );

  final String defaultName;
  final String sproutEmoji;
  final String growingEmoji;
  final String matureEmoji;
  final String bloomEmoji;
  final int minutesToGrow;

  const PlantType({
    required this.defaultName,
    required this.sproutEmoji,
    required this.growingEmoji,
    required this.matureEmoji,
    required this.bloomEmoji,
    required this.minutesToGrow,
  });
}

// ============================================================================
// COMMUNITY GARDENER
// ============================================================================
class CommunityGardener {
  final String anonymousId;
  final String displayName; // Generated animal name
  final int totalMinutes;
  final int streak;
  final int plantCount;

  const CommunityGardener({
    required this.anonymousId,
    required this.displayName,
    required this.totalMinutes,
    required this.streak,
    required this.plantCount,
  });

  factory CommunityGardener.fromJson(Map<String, dynamic> json) => CommunityGardener(
        anonymousId: json['anonymousId'] as String,
        displayName: json['displayName'] as String,
        totalMinutes: json['totalMinutes'] as int,
        streak: json['streak'] as int,
        plantCount: json['plantCount'] as int,
      );
}

enum GardenWeather { sunny, cloudy, rainy, misty }

// ============================================================================
// GARDEN NOTIFIER
// ============================================================================
class GardenNotifier extends StateNotifier<GardenState> {
  Box? _gardenBox;
  Timer? _syncTimer;

  GardenNotifier() : super(const GardenState()) {
    debugPrint('[GardenNotifier] Initializing garden provider.');
    _initialize();
  }

  // -------------------------------------------------------------------------
  // INITIALIZATION
  // -------------------------------------------------------------------------
  Future<void> _initialize() async {
    debugPrint('[GardenNotifier::_initialize] Loading garden data.');

    try {
      state = state.copyWith(isLoading: true);
      _gardenBox = await Hive.openBox('garden');

      // Load local data
      final savedId = _gardenBox?.get('anonymousId') as String?;
      final savedMinutes = _gardenBox?.get('totalMinutes', defaultValue: 0) as int;
      final savedStreak = _gardenBox?.get('currentStreak', defaultValue: 0) as int;
      final savedLongestStreak = _gardenBox?.get('longestStreak', defaultValue: 0) as int;
      final savedPlants = _gardenBox?.get('plants', defaultValue: <dynamic>[]) as List;

      // Parse plants
      final plants = savedPlants
          .map((p) => GardenPlant.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();

      state = state.copyWith(
        anonymousId: savedId,
        isAuthenticated: savedId != null,
        totalMinutesReclaimed: savedMinutes,
        currentStreak: savedStreak,
        longestStreak: savedLongestStreak,
        myPlants: plants,
        currentWeather: _getWeatherForTime(),
        isLoading: false,
      );

      debugPrint('[GardenNotifier] Loaded: $savedMinutes minutes, $savedStreak streak, ${plants.length} plants');

      // Initialize Firebase
      await _initializeFirebase();

      // Start periodic sync
      _startPeriodicSync();

      // Load community data
      await _loadCommunityData();
    } catch (e) {
      debugPrint('[GardenNotifier::_initialize] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _initializeFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        debugPrint('[GardenNotifier] Firebase user found: ${user.uid}');
        state = state.copyWith(
          isAuthenticated: true,
          anonymousId: user.uid,
        );
        // Sync down latest data
        await _syncFromCloud();
      } else {
        debugPrint('[GardenNotifier] No Firebase user found.');
      }
    } catch (e) {
      debugPrint('[GardenNotifier] Firebase init error (likely offline or no config): $e');
      // Fallback to local mode is automatic since we already loaded from Hive
    }
  }

  GardenWeather _getWeatherForTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) return GardenWeather.misty;
    if (hour >= 10 && hour < 18) return GardenWeather.sunny;
    if (hour >= 18 && hour < 21) return GardenWeather.cloudy;
    return GardenWeather.misty;
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _syncToCloud();
    });
  }

  Future<void> _syncToCloud() async {
    if (!state.isAuthenticated || state.anonymousId == null) return;

    debugPrint('[GardenNotifier::_syncToCloud] Syncing to Firestore.');
    try {
      final userDoc = FirebaseFirestore.instance.collection('gardens').doc(state.anonymousId);
      
      await userDoc.set({
        'lastActive': FieldValue.serverTimestamp(),
        'totalMinutes': state.totalMinutesReclaimed,
        'streak': state.currentStreak,
        'longestStreak': state.longestStreak,
        'plantCount': state.myPlants.length,
        'displayName': _gardenBox?.get('displayName') ?? 'Anonymous Gardener',
        'plants': state.myPlants.map((p) => p.toJson()).toList(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      debugPrint('[GardenNotifier::_syncToCloud] Error: $e');
      // Silent fail - will retry next time or stay local
    }
  }

  Future<void> _syncFromCloud() async {
    if (!state.isAuthenticated || state.anonymousId == null) return;

    debugPrint('[GardenNotifier::_syncFromCloud] Fetching from Firestore.');
    try {
      final doc = await FirebaseFirestore.instance.collection('gardens').doc(state.anonymousId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final cloudMinutes = data['totalMinutes'] as int? ?? 0;
        final cloudStreak = data['streak'] as int? ?? 0;
        
        // Simple conflict resolution: take the higher values (assuming growth only)
        if (cloudMinutes > state.totalMinutesReclaimed) {
          state = state.copyWith(
            totalMinutesReclaimed: cloudMinutes,
            currentStreak: cloudStreak,
            longestStreak: data['longestStreak'] as int? ?? state.longestStreak,
          );
          
          // Update local storage
          await _gardenBox?.put('totalMinutes', cloudMinutes);
          await _gardenBox?.put('currentStreak', cloudStreak);
        }
      }
    } catch (e) {
      debugPrint('[GardenNotifier::_syncFromCloud] Error: $e');
    }
  }

  // -------------------------------------------------------------------------
  // AUTHENTICATION
  // -------------------------------------------------------------------------
  Future<void> signInAnonymously() async {
    debugPrint('[GardenNotifier::signInAnonymously] Signing in.');

    if (state.isAuthenticated) {
      debugPrint('[GardenNotifier] Already authenticated.');
      return;
    }

    try {
      state = state.copyWith(isLoading: true);

      // Authenticate with Firebase
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;
      
      if (user == null) throw Exception('Firebase sign in failed');

      final anonymousId = user.uid;
      
      // Check if we have a display name stored, if not generate one
      String displayName = _gardenBox?.get('displayName') as String? ?? '';
      if (displayName.isEmpty) {
        displayName = _generateAnimalName();
        await _gardenBox?.put('displayName', displayName);
      }

      await _gardenBox?.put('anonymousId', anonymousId);

      state = state.copyWith(
        isAuthenticated: true,
        anonymousId: anonymousId,
        isLoading: false,
      );

      debugPrint('[GardenNotifier] Signed in as: $displayName ($anonymousId)');
      
      // Initial sync
      await _syncFromCloud();
      await _syncToCloud();
      
    } catch (e) {
      debugPrint('[GardenNotifier::signInAnonymously] Error: $e');
      // Fallback to local-only ID if Firebase fails
      final localId = _generateAnonymousId();
      await _gardenBox?.put('anonymousId', localId);
      
      state = state.copyWith(
        isAuthenticated: true,
        anonymousId: localId,
        isLoading: false,
        error: 'Offline mode: $e',
      );
    }
  }

  String _generateAnonymousId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateAnimalName() {
    final adjectives = [
      'Peaceful', 'Gentle', 'Mindful', 'Calm', 'Focused',
      'Patient', 'Serene', 'Balanced', 'Centered', 'Present',
    ];
    final animals = [
      'Panda', 'Owl', 'Turtle', 'Deer', 'Rabbit',
      'Butterfly', 'Hummingbird', 'Dolphin', 'Koala', 'Sloth',
    ];

    final random = Random();
    return '${adjectives[random.nextInt(adjectives.length)]} ${animals[random.nextInt(animals.length)]}';
  }

  // -------------------------------------------------------------------------
  // TIME LOGGING
  // -------------------------------------------------------------------------
  Future<void> logTimeReclaimed(int minutes) async {
    debugPrint('[GardenNotifier::logTimeReclaimed] Logging $minutes minutes.');

    if (minutes <= 0) return;

    final newTotal = state.totalMinutesReclaimed + minutes;
    final newToday = state.todayMinutesReclaimed + minutes;

    state = state.copyWith(
      totalMinutesReclaimed: newTotal,
      todayMinutesReclaimed: newToday,
    );

    await _gardenBox?.put('totalMinutes', newTotal);

    // Check if plants can grow
    await _growPlants(minutes);

    // Update streak if first log today
    await _updateStreak();

    // Sync to cloud
    await _syncToCloud();
  }

  Future<void> _updateStreak() async {
    final today = DateTime.now();
    final lastActiveStr = _gardenBox?.get('lastActiveDate') as String?;

    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final daysDiff = today.difference(lastActive).inDays;

      if (daysDiff == 1) {
        // Consecutive day - increase streak
        final newStreak = state.currentStreak + 1;
        final newLongest = max(newStreak, state.longestStreak);

        state = state.copyWith(
          currentStreak: newStreak,
          longestStreak: newLongest,
        );

        await _gardenBox?.put('currentStreak', newStreak);
        await _gardenBox?.put('longestStreak', newLongest);
      } else if (daysDiff > 1) {
        // Streak broken
        state = state.copyWith(currentStreak: 1);
        await _gardenBox?.put('currentStreak', 1);
      }
      // daysDiff == 0: same day, no change
    } else {
      // First ever log
      state = state.copyWith(currentStreak: 1, longestStreak: 1);
      await _gardenBox?.put('currentStreak', 1);
      await _gardenBox?.put('longestStreak', 1);
    }

    await _gardenBox?.put('lastActiveDate', today.toIso8601String());
  }

  // -------------------------------------------------------------------------
  // PLANT MANAGEMENT
  // -------------------------------------------------------------------------
  Future<void> plantSeed(PlantType type, {String? name}) async {
    debugPrint('[GardenNotifier::plantSeed] Planting ${type.defaultName}.');

    final plant = GardenPlant(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      plantedAt: DateTime.now(),
      customName: name,
    );

    final plants = [...state.myPlants, plant];
    state = state.copyWith(myPlants: plants);

    await _savePlants();
  }

  Future<void> _growPlants(int minutesAdded) async {
    debugPrint('[GardenNotifier::_growPlants] Growing plants with $minutesAdded minutes.');

    final growthMinutes = (minutesAdded * state.growthMultiplier).round();
    final updatedPlants = <GardenPlant>[];

    for (final plant in state.myPlants) {
      if (plant.isFullyGrown) {
        updatedPlants.add(plant);
        continue;
      }

      final newMinutes = plant.minutesInvested + growthMinutes;
      final minutesPerStage = plant.type.minutesToGrow ~/ 4;
      final newStage = min(4, newMinutes ~/ minutesPerStage);

      updatedPlants.add(plant.copyWith(
        minutesInvested: newMinutes,
        growthStage: newStage,
      ));
    }

    state = state.copyWith(myPlants: updatedPlants);
    await _savePlants();
  }

  Future<void> renamePlant(String plantId, String newName) async {
    debugPrint('[GardenNotifier::renamePlant] Renaming $plantId to $newName.');

    final plants = state.myPlants
        .map((p) => p.id == plantId ? p.copyWith(customName: newName) : p)
        .toList();

    state = state.copyWith(myPlants: plants);
    await _savePlants();
  }

  Future<void> _savePlants() async {
    await _gardenBox?.put(
      'plants',
      state.myPlants.map((p) => p.toJson()).toList(),
    );
  }

  // -------------------------------------------------------------------------
  // COMMUNITY
  // -------------------------------------------------------------------------
  Future<void> _loadCommunityData() async {
    debugPrint('[GardenNotifier::_loadCommunityData] Loading community.');

    try {
      // Fetch top 10 gardeners by total minutes
      final snapshot = await FirebaseFirestore.instance
          .collection('gardens')
          .orderBy('totalMinutes', descending: true)
          .limit(10)
          .get();

      final gardeners = snapshot.docs.map((doc) {
        final data = doc.data();
        return CommunityGardener(
          anonymousId: doc.id,
          displayName: data['displayName'] as String? ?? 'Anonymous',
          totalMinutes: data['totalMinutes'] as int? ?? 0,
          streak: data['streak'] as int? ?? 0,
          plantCount: data['plantCount'] as int? ?? 0,
        );
      }).toList();

      if (gardeners.isNotEmpty) {
        state = state.copyWith(communityGardeners: gardeners);
      } else {
        // Fallback to mock if empty (e.g. first run)
        _loadMockCommunityData();
      }
    } catch (e) {
      debugPrint('[GardenNotifier::_loadCommunityData] Error: $e');
      // Fallback to mock on error
      _loadMockCommunityData();
    }
  }

  void _loadMockCommunityData() {
    final mockGardeners = [
      const CommunityGardener(
        anonymousId: 'user1',
        displayName: 'Peaceful Panda',
        totalMinutes: 2400,
        streak: 42,
        plantCount: 15,
      ),
      const CommunityGardener(
        anonymousId: 'user2',
        displayName: 'Mindful Owl',
        totalMinutes: 1800,
        streak: 28,
        plantCount: 12,
      ),
      const CommunityGardener(
        anonymousId: 'user3',
        displayName: 'Gentle Turtle',
        totalMinutes: 1200,
        streak: 21,
        plantCount: 8,
      ),
    ];
    state = state.copyWith(communityGardeners: mockGardeners);
  }

  Future<void> refreshCommunity() async {
    debugPrint('[GardenNotifier::refreshCommunity] Refreshing community data.');
    await _loadCommunityData();
  }

  // -------------------------------------------------------------------------
  // CLEANUP
  // -------------------------------------------------------------------------
  @override
  void dispose() {
    debugPrint('[GardenNotifier::dispose] Cleaning up.');
    _syncTimer?.cancel();
    super.dispose();
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================
final gardenProvider = StateNotifierProvider<GardenNotifier, GardenState>((ref) {
  return GardenNotifier();
});

// Convenience providers
final gardenLevelProvider = Provider<int>((ref) {
  return ref.watch(gardenProvider).gardenLevel;
});

final gardenStreakProvider = Provider<int>((ref) {
  return ref.watch(gardenProvider).currentStreak;
});

final gardenPlantsProvider = Provider<List<GardenPlant>>((ref) {
  return ref.watch(gardenProvider).myPlants;
});

final communityLeaderboardProvider = Provider<List<CommunityGardener>>((ref) {
  return ref.watch(gardenProvider).communityGardeners;
});

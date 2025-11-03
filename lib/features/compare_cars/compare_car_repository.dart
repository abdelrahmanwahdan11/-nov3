import 'dart:math';

import 'package:flutter/material.dart';

import 'car_models.dart';

class CompareCarRepository {
  static const int _networkDelayMs = 450;

  static const List<CompareCar> _cars = <CompareCar>[
    CompareCar(
      id: 'falcon-xr',
      brand: 'Falcon',
      model: 'XR Desert',
      year: 2024,
      seats: 5,
      doors: 4,
      transmission: 'Automatic',
      fuel: 'Electric',
      consumption: '18 kWh/100km',
      pricePerDay: 680,
      imageUrl:
          'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        '600km dune-ready range',
        'Adaptive desert suspension',
        'Glass cockpit with AR navigator',
      ],
      notes:
          'Ideal for long electric desert crossings with regenerative braking tuned for dunes.',
    ),
    CompareCar(
      id: 'sahara-elite',
      brand: 'Terra',
      model: 'Sahara Elite',
      year: 2023,
      seats: 7,
      doors: 5,
      transmission: 'Automatic',
      fuel: 'Hybrid',
      consumption: '6.2 L/100km',
      pricePerDay: 520,
      imageUrl:
          'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Panoramic sky lounge roof',
        'AI caravan planner',
        'Trail autopilot up to 40km/h',
      ],
      notes:
          'Best for family adventures that balance comfort and off-road autonomy.',
    ),
    CompareCar(
      id: 'dune-runner',
      brand: 'Nomad',
      model: 'Dune Runner RZ',
      year: 2024,
      seats: 2,
      doors: 2,
      transmission: 'Sequential',
      fuel: 'Petrol',
      consumption: '12.1 L/100km',
      pricePerDay: 420,
      imageUrl:
          'https://images.unsplash.com/photo-1549923746-c502d488b3ea?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Carbon frame with kinetic seats',
        'Sand launch control',
        'AR trail heads-up display',
      ],
      notes:
          'Performance buggy made for sunrise dune runs and adrenaline seekers.',
    ),
    CompareCar(
      id: 'oasis-cruiser',
      brand: 'Oryx',
      model: 'Oasis Cruiser',
      year: 2022,
      seats: 5,
      doors: 4,
      transmission: 'Automatic',
      fuel: 'Hybrid',
      consumption: '5.4 L/100km',
      pricePerDay: 360,
      imageUrl:
          'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Desert-cooled seating',
        'Integrated fridge and hydration pack',
        'Smart sand driving coach',
      ],
      notes:
          'Balanced for couples who want luxury touches without sacrificing range.',
    ),
    CompareCar(
      id: 'mirage-roadster',
      brand: 'Mirage',
      model: 'Roadster GT',
      year: 2024,
      seats: 4,
      doors: 3,
      transmission: 'Automatic',
      fuel: 'Electric',
      consumption: '15 kWh/100km',
      pricePerDay: 540,
      imageUrl:
          'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=70',
      highlights: <String>[
        'Convertible sky canopy',
        '0-100 in 4.3s sand mode',
        'Bi-directional charging for camps',
      ],
      notes:
          'Stylish cruiser for scenic drives and evening coastal escapes.',
    ),
    CompareCar(
      id: 'trail-mate',
      brand: 'Rovera',
      model: 'TrailMate X',
      year: 2021,
      seats: 5,
      doors: 5,
      transmission: 'Manual',
      fuel: 'Diesel',
      consumption: '7.8 L/100km',
      pricePerDay: 280,
      imageUrl:
          'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Locking differentials with crawl assist',
        'Modular roof rack system',
        '360° rock cameras',
      ],
      notes:
          'Dependable choice for rugged trails and overlanding setups.',
    ),
    CompareCar(
      id: 'city-glide',
      brand: 'Urbania',
      model: 'City Glide',
      year: 2023,
      seats: 4,
      doors: 5,
      transmission: 'Automatic',
      fuel: 'Electric',
      consumption: '12 kWh/100km',
      pricePerDay: 240,
      imageUrl:
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'City autopark with curb vision',
        'Modular cargo cabin',
        'Voice concierge with Arabic dialects',
      ],
      notes:
          'Optimized for city-to-desert weekend getaways with flexible storage.',
    ),
    CompareCar(
      id: 'ridge-pro',
      brand: 'Atlas',
      model: 'Ridge Pro',
      year: 2022,
      seats: 5,
      doors: 4,
      transmission: 'Automatic',
      fuel: 'Diesel',
      consumption: '8.3 L/100km',
      pricePerDay: 310,
      imageUrl:
          'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=60',
      highlights: <String>[
        'High-clearance adaptive chassis',
        'Dual fuel tanks for 1100km range',
        'Satellite comms baked in',
      ],
      notes:
          'Workhorse SUV for expeditions needing serious autonomy.',
    ),
    CompareCar(
      id: 'sand-ev',
      brand: 'Volt',
      model: 'Sand EV Flex',
      year: 2024,
      seats: 5,
      doors: 5,
      transmission: 'Automatic',
      fuel: 'Electric',
      consumption: '17 kWh/100km',
      pricePerDay: 330,
      imageUrl:
          'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Solar awning extension',
        'Sand mode torque vectoring',
        'Removable camp battery packs',
      ],
      notes:
          'Electric crossover focused on remote camp support and efficiency.',
    ),
    CompareCar(
      id: 'heritage-lx',
      brand: 'Legacy',
      model: 'Heritage LX',
      year: 2020,
      seats: 5,
      doors: 4,
      transmission: 'Manual',
      fuel: 'Petrol',
      consumption: '9.6 L/100km',
      pricePerDay: 190,
      imageUrl:
          'https://images.unsplash.com/photo-1541447271487-09612b3f49c7?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Classic analog dash',
        'Remastered cooling vents',
        'Retro sand ladder kit included',
      ],
      notes:
          'Authentic throwback for travelers wanting mechanical feel with modern safety.',
    ),
    CompareCar(
      id: 'coastal-surf',
      brand: 'Azure',
      model: 'Coastal Surf',
      year: 2021,
      seats: 4,
      doors: 3,
      transmission: 'Automatic',
      fuel: 'Hybrid',
      consumption: '5.9 L/100km',
      pricePerDay: 260,
      imageUrl:
          'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?auto=format&fit=crop&w=1200&q=80',
      highlights: <String>[
        'Surfboard side mounts',
        'Marine-grade interior fabrics',
        'Wave forecasting companion app',
      ],
      notes:
          'Weekend favorite for Red Sea road trips with water sport gear.',
    ),
  ];

  static Future<List<CompareCar>> fetchCars({
    required int page,
    required int pageSize,
    String query = '',
    CarComparisonFilters filters = const CarComparisonFilters(),
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: _networkDelayMs));
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = _cars.where((CompareCar car) {
      final matchesQuery = normalizedQuery.isEmpty ||
          car.displayName.toLowerCase().contains(normalizedQuery) ||
          car.highlights.any(
            (highlight) => highlight.toLowerCase().contains(normalizedQuery),
          );
      return matchesQuery && filters.matches(car);
    }).toList();
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filtered.length) {
      return <CompareCar>[];
    }
    final endIndex = min(startIndex + pageSize, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  static List<String> brands() {
    return _cars.map((CompareCar car) => car.brand).toSet().toList()..sort();
  }

  static List<String> fuels() {
    return _cars.map((CompareCar car) => car.fuel).toSet().toList()..sort();
  }

  static List<String> transmissions() {
    return _cars.map((CompareCar car) => car.transmission).toSet().toList()
      ..sort();
  }

  static RangeValues priceBounds() {
    final prices = _cars.map((CompareCar car) => car.pricePerDay).toList();
    prices.sort();
    return RangeValues(prices.first.toDouble(), prices.last.toDouble());
  }

  static CompareCar? findById(String id) {
    try {
      return _cars.firstWhere((CompareCar car) => car.id == id);
    } catch (_) {
      return null;
    }
  }
}

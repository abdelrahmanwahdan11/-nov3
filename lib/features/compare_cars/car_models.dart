import 'package:flutter/material.dart';

@immutable
class CompareCar {
  const CompareCar({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.seats,
    required this.doors,
    required this.transmission,
    required this.fuel,
    required this.consumption,
    required this.pricePerDay,
    required this.imageUrl,
    required this.highlights,
    required this.notes,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final int seats;
  final int doors;
  final String transmission;
  final String fuel;
  final String consumption;
  final int pricePerDay;
  final String imageUrl;
  final List<String> highlights;
  final String notes;

  String get displayName => '$brand $model';
}

@immutable
class CarComparisonFilters {
  const CarComparisonFilters({
    this.brands = const <String>{},
    this.fuels = const <String>{},
    this.transmissions = const <String>{},
    this.priceRange = const RangeValues(180, 680),
  });

  final Set<String> brands;
  final Set<String> fuels;
  final Set<String> transmissions;
  final RangeValues priceRange;

  bool matches(CompareCar car) {
    final inBrand = brands.isEmpty || brands.contains(car.brand);
    final inFuel = fuels.isEmpty || fuels.contains(car.fuel);
    final inTransmission =
        transmissions.isEmpty || transmissions.contains(car.transmission);
    final inPrice = car.pricePerDay >= priceRange.start &&
        car.pricePerDay <= priceRange.end;
    return inBrand && inFuel && inTransmission && inPrice;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'brands': brands.toList(),
      'fuels': fuels.toList(),
      'transmissions': transmissions.toList(),
      'priceStart': priceRange.start,
      'priceEnd': priceRange.end,
    };
  }

  static CarComparisonFilters fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CarComparisonFilters();
    }
    final brands = map['brands'];
    final fuels = map['fuels'];
    final transmissions = map['transmissions'];
    final start = map['priceStart'];
    final end = map['priceEnd'];
    return CarComparisonFilters(
      brands: _decodeSet(brands),
      fuels: _decodeSet(fuels),
      transmissions: _decodeSet(transmissions),
      priceRange: start is num && end is num
          ? RangeValues(start.toDouble(), end.toDouble())
          : const RangeValues(180, 680),
    );
  }

  CarComparisonFilters copyWith({
    Set<String>? brands,
    Set<String>? fuels,
    Set<String>? transmissions,
    RangeValues? priceRange,
  }) {
    return CarComparisonFilters(
      brands: brands ?? this.brands,
      fuels: fuels ?? this.fuels,
      transmissions: transmissions ?? this.transmissions,
      priceRange: priceRange ?? this.priceRange,
    );
  }

  static Set<String> _decodeSet(dynamic value) {
    if (value is Iterable) {
      return value.map((dynamic item) => item.toString()).toSet();
    }
    return <String>{};
  }
}

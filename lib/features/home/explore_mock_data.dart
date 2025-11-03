import 'package:travelmate/features/place/models/explore_place.dart';

/// Static mock data used across the explore and search experiences.
class ExploreMockData {
  const ExploreMockData._();

  static const List<ExplorePlace> places = [
    ExplorePlace(
      id: 'aurora-cliffs',
      title: 'Aurora Cliffs',
      subtitle: 'Sun-drenched canyon lookout',
      description:
          'Hike the sandstone ridge for a sunrise panorama over ancient rock formations and hidden valleys.',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'AlUla, Saudi Arabia',
      distanceText: '3.2 km',
      rating: 4.9,
      tags: ['hero', 'ai'],
    ),
    ExplorePlace(
      id: 'floating-garden',
      title: 'Floating Garden',
      subtitle: 'Glass observatory above the oasis',
      description:
          'Ride the sky elevator to a suspended botanical garden with curated exhibits and soft ambient music.',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Riyadh, Saudi Arabia',
      distanceText: '8.5 km',
      rating: 4.8,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'midnight-souk',
      title: 'Midnight Souk',
      subtitle: 'Lantern-lit artisan market',
      description:
          'Discover handwoven textiles, oud fragrances, and street performances after dusk in a tucked-away market.',
      imageUrl:
          'https://images.unsplash.com/photo-1520357456838-1d93c1f0840d?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Jeddah, Saudi Arabia',
      distanceText: '2.1 km',
      rating: 4.7,
      tags: ['hidden'],
    ),
    ExplorePlace(
      id: 'whispering-dunes',
      title: 'Whispering Dunes',
      subtitle: 'Soundscape desert trek',
      description:
          'Guided evening walk where shifting dunes create natural melodies amplified by gentle desert winds.',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-5fce5f43d0d2?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Empty Quarter, Saudi Arabia',
      distanceText: '42 km',
      rating: 4.6,
      tags: ['hidden', 'ai'],
    ),
    ExplorePlace(
      id: 'artisan-roastery',
      title: 'Artisan Roastery',
      subtitle: 'Slow-brew micro café',
      description:
          'Sip experimental blends crafted with single-origin beans while learning roasting techniques from baristas.',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Diriyah, Saudi Arabia',
      distanceText: '5.4 km',
      rating: 4.5,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'sky-terrace',
      title: 'Sky Terrace',
      subtitle: 'City skyline sunset deck',
      description:
          'Chill on a terraced rooftop with live oud sessions as the city lights flicker to life beneath you.',
      imageUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Khobar, Saudi Arabia',
      distanceText: '11 km',
      rating: 4.4,
    ),
    ExplorePlace(
      id: 'cinnamon-harbor',
      title: 'Cinnamon Harbor',
      subtitle: 'Floating spice kitchen',
      description:
          'Taste aromatic stews simmering on dhow boats while storytellers share seafaring tales.',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Al Bahah, Saudi Arabia',
      distanceText: '18 km',
      rating: 4.3,
    ),
    ExplorePlace(
      id: 'emerald-oasis',
      title: 'Emerald Oasis',
      subtitle: 'Hidden canyon lagoon',
      description:
          'Swim beneath natural waterfalls surrounded by palm groves and luminous limestone walls.',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Najran, Saudi Arabia',
      distanceText: '65 km',
      rating: 4.8,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'desert-library',
      title: 'Desert Library',
      subtitle: 'Nomadic pop-up book lounge',
      description:
          'Borrow limited-edition travelogues in a linen tent with mint tea service and ambient oud playlists.',
      imageUrl:
          'https://images.unsplash.com/photo-1477346611705-65d1883cee1e?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Hail, Saudi Arabia',
      distanceText: '24 km',
      rating: 4.6,
      tags: ['hidden'],
    ),
    ExplorePlace(
      id: 'lagoon-market',
      title: 'Lagoon Market',
      subtitle: 'Waterfront tasting trail',
      description:
          'Sample chef-led tasting menus as you stroll beside mirrored waters lit with floating lanterns.',
      imageUrl:
          'https://images.unsplash.com/photo-1498654200943-1088dd4438ae?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Jazan, Saudi Arabia',
      distanceText: '14 km',
      rating: 4.2,
    ),
    ExplorePlace(
      id: 'crystal-cove',
      title: 'Crystal Cove',
      subtitle: 'Shimmering tidal caves',
      description:
          'Kayak through sea caves where bioluminescent waters cast prismatic reflections onto limestone walls.',
      imageUrl:
          'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Farasan Islands, Saudi Arabia',
      distanceText: '32 km',
      rating: 4.9,
      tags: ['hero'],
    ),
    ExplorePlace(
      id: 'celestial-observatory',
      title: 'Celestial Observatory',
      subtitle: 'Stargazing dunes lounge',
      description:
          'Recline on plush loungers with guided constellation tours beneath some of the clearest skies in the region.',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-7e55b9a0ff71?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Tabuk, Saudi Arabia',
      distanceText: '71 km',
      rating: 4.7,
      tags: ['hidden'],
    ),
    ExplorePlace(
      id: 'saffron-atrium',
      title: 'Saffron Atrium',
      subtitle: 'Immersive dining greenhouse',
      description:
          'A greenhouse restaurant with aromatic herb gardens, live oud, and chef-led tasting menus.',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Al Hofuf, Saudi Arabia',
      distanceText: '9.4 km',
      rating: 4.6,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'mirror-sands',
      title: 'Mirror Sands',
      subtitle: 'Reflective desert art walk',
      description:
          'Mirrored monoliths reflect rolling dunes on a curated art trail lit with ambient installations.',
      imageUrl:
          'https://images.unsplash.com/photo-1529920561557-90c2e0dcca38?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Qassim, Saudi Arabia',
      distanceText: '54 km',
      rating: 4.5,
    ),
    ExplorePlace(
      id: 'lunar-camp',
      title: 'Lunar Camp',
      subtitle: 'Futuristic desert retreat',
      description:
          'Geo-domes with panoramic star ceilings, aroma therapy, and chef-prepared meals in the dunes.',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'NEOM, Saudi Arabia',
      distanceText: '120 km',
      rating: 4.8,
      tags: ['ai', 'hidden'],
    ),
    ExplorePlace(
      id: 'odyssey-bay',
      title: 'Odyssey Bay',
      subtitle: 'Sailing gallery pier',
      description:
          'Sunset sails depart from an art-lined pier featuring rotating exhibits and live acoustic sets.',
      imageUrl:
          'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Yanbu, Saudi Arabia',
      distanceText: '38 km',
      rating: 4.4,
    ),
    ExplorePlace(
      id: 'ember-bazaar',
      title: 'Ember Bazaar',
      subtitle: 'Night market supper club',
      description:
          'A roving feast with chef pop-ups, live music, and handcrafted goods illuminated by fire lanterns.',
      imageUrl:
          'https://images.unsplash.com/photo-1473093226795-af9932fe5856?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Taif, Saudi Arabia',
      distanceText: '27 km',
      rating: 4.7,
      tags: ['hidden'],
    ),
    ExplorePlace(
      id: 'horizon-boardwalk',
      title: 'Horizon Boardwalk',
      subtitle: 'Seaside kinetic light trail',
      description:
          'Interactive light sculptures respond to footsteps along a floating walkway above turquoise waters.',
      imageUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Dammam, Saudi Arabia',
      distanceText: '6.8 km',
      rating: 4.3,
    ),
    ExplorePlace(
      id: 'starlit-conservatory',
      title: 'Starlit Conservatory',
      subtitle: 'Botanical glasshouse lounge',
      description:
          'A towering conservatory with cascading plants, light projections, and evening tea ceremonies.',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Abha, Saudi Arabia',
      distanceText: '16 km',
      rating: 4.5,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'ember-heights',
      title: 'Ember Heights',
      subtitle: 'Cliffside sky bridge',
      description:
          'Glass-bottom walkway connecting two cliffs with augmented reality storytelling nodes.',
      imageUrl:
          'https://images.unsplash.com/photo-1477346611705-65d1883cee1e?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Tabuk, Saudi Arabia',
      distanceText: '48 km',
      rating: 4.6,
    ),
    ExplorePlace(
      id: 'zenith-hotsprings',
      title: 'Zenith Hotsprings',
      subtitle: 'Mineral-rich canyon pools',
      description:
          'Terraced hot pools overlooking desert vistas with guided stargazing and aromatherapy.',
      imageUrl:
          'https://images.unsplash.com/photo-1502082553048-f009c37129b9?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Al Madinah, Saudi Arabia',
      distanceText: '58 km',
      rating: 4.9,
      tags: ['hidden'],
    ),
  ];
}

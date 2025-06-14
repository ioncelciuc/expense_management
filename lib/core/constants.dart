import 'package:flutter/material.dart';

const kPagePadding = EdgeInsets.all(16);

final Map<String, IconData> kIconRegistry = {
  //Empty
  'question': Icons.question_mark,

  // Groceries & Food
  'shopping_cart': Icons.shopping_cart,
  'shopping_basket': Icons.shopping_basket,
  'fruits': Icons.emoji_nature,
  'vegetables': Icons.eco,

  // Dining & Drinks
  'restaurant': Icons.restaurant,
  'fast_food': Icons.fastfood,
  'cafe': Icons.local_cafe,
  'coffee': Icons.coffee,
  'ice_cream': Icons.icecream,
  'bar': Icons.local_bar,

  // Home & Utilities
  'rent': Icons.home,
  'electricity': Icons.flash_on,
  'water': Icons.opacity,
  'gas': Icons.local_gas_station,
  'internet': Icons.wifi,
  'phone': Icons.phone,
  'toilet': Icons.wc,
  'cleaning_services': Icons.cleaning_services,
  'laundry': Icons.local_laundry_service,
  'perfume': Icons.spa,

  // Transport & Travel
  'car': Icons.directions_car,
  'bus': Icons.directions_bus,
  'train': Icons.train,
  'flight': Icons.flight,
  'hotel': Icons.hotel,
  'boat': Icons.directions_boat,
  'fuel': Icons.local_gas_station,
  'taxi': Icons.local_taxi,

  // Subscriptions & Bills
  'subscriptions': Icons.subscriptions,
  'auto_renew': Icons.autorenew,
  'bill': Icons.receipt_long,
  'insurance': Icons.shield,
  'taxes': Icons.account_balance,
  'loan': Icons.account_balance_wallet,

  // Health & Fitness
  'medical': Icons.medical_services,
  'hospital': Icons.local_hospital,
  'pharmacy': Icons.local_pharmacy,
  'gym': Icons.fitness_center,

  // Entertainment & Leisure
  'movie': Icons.movie,
  'tv': Icons.live_tv,
  'music': Icons.music_note,
  'games': Icons.videogame_asset,
  'theater': Icons.theaters,
  'travel': Icons.card_travel,

  // Shopping & Personal
  'shopping_bag': Icons.shopping_bag,
  'clothing': Icons.checkroom,
  'electronics': Icons.electrical_services,
  'gifts': Icons.card_giftcard,
  'charity': Icons.volunteer_activism,

  // Miscellaneous
  'education': Icons.school,
  'books': Icons.menu_book,
  'beauty': Icons.brush,
  'pets': Icons.pets,
  'parking': Icons.local_parking,
  'parking_ticket': Icons.confirmation_number,
  'parking_garage': Icons.garage,
};

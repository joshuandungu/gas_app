import 'package:flutter/material.dart';

// String uri = "https://ecommerce-server-xi-sandy.vercel.app";
String uri = "http://192.168.74.199:3000";

class GlobalVariables {
  // COLORS
  // static const appBarGradient = LinearGradient(
  //   colors: [
  //     Color.fromARGB(255, 29, 201, 192),
  //     Color.fromARGB(255, 125, 221, 216),
  //   ],
  //   stops: [0.5, 1.0],
  // );

  // Màu chủ đạo của app
  static const primaryColor =
      Color.fromARGB(255, 0, 123, 255); // Xanh dương đậm
  static const secondaryColor =
      Color.fromARGB(255, 0, 180, 216); // Xanh dương nhạt

  static const appBarGradient = LinearGradient(
    colors: [
      primaryColor,
      secondaryColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cập nhật các màu khác để phù hợp với theme mới
  static const backgroundColor = Colors.white;
  static const Color greyBackgroundColor = Color(0xffebecee);
  static var selectedNavBarColor =
      primaryColor; // Thay đổi từ cyan sang primaryColor
  static const unselectedNavBarColor = Colors.black87;

  // STATIC IMAGES
  static const List<String> carouselImages = [
    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=800&h=400&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
  ];

  static const List<Map<String, dynamic>> categoryImages = [
    {
      'title': 'Mobiles',
      'image': 'assets/images/mobiles.jpeg',
    },
    {
      'title': 'Essentials',
      'image': 'assets/images/essentials.jpeg',
    },
    {
      'title': 'Appliances',
      'image': 'assets/images/appliances.jpeg',
    },
    {
      'title': 'Books',
      'image': 'assets/images/books.jpeg',
    },
    {
      'title': 'Fashion',
      'image': 'assets/images/fashion.jpeg',
    },
    {
      'title': 'Gas Products',
      'icon': Icons.local_fire_department,
    },
  ];
}

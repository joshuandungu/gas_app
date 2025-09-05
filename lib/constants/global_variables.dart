import 'package:flutter/material.dart';

// String uri = "https://ecommerce-server-xi-sandy.vercel.app";
String uri = "http://192.168.20.70:3000";

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
    'assets/images/gas_banner/gas_banner.webp',
    'assets/images/gas_banner/gas_banner2.webp',
    'assets/images/gas_banner/gas_banner3.webp',
    'assets/images/gas_banner/gas_banner4.jpg',
    'assets/images/gas_banner/gas_banner5.webp',
    'assets/images/gas_banner/gas_banner6.webp',
    'assets/images/gas_banner/gas_banner7.webp',
    'assets/images/gas_banner/gas_banner8.webp',
    'assets/images/gas_banner/gas_banner9.jpg',
    'assets/images/gas_banner/gas_banner10.webp',
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

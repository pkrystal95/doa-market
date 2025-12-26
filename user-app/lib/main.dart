import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/category_provider.dart';
import 'providers/address_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/point_provider.dart';
import 'providers/checkin_provider.dart';
import 'providers/notice_provider.dart';
import 'providers/review_provider.dart';
import 'providers/inquiry_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/my_page_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/address_management_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/point_history_screen.dart';
import 'screens/notice_list_screen.dart';
import 'screens/notice_detail_screen.dart';
import 'screens/my_reviews_screen.dart';
import 'screens/inquiry_list_screen.dart';
import 'screens/inquiry_detail_screen.dart';
import 'screens/inquiry_write_screen.dart';
import 'screens/order_returns_screen.dart';
import 'screens/order_cancel_request_screen.dart';
import 'screens/daily_checkin_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PointProvider()),
        ChangeNotifierProvider(create: (_) => CheckinProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => InquiryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DOA Market',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/product': (context) => const ProductDetailScreen(),
              '/cart': (context) => const CartScreen(),
              '/mypage': (context) => const MyPageScreen(),
              '/wishlist': (context) => const WishlistScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/addresses': (context) => const AddressManagementScreen(),
              '/orders': (context) => const OrderHistoryScreen(),
              '/search': (context) => const SearchScreen(),
              '/profile-edit': (context) => const ProfileEditScreen(),
              '/point-history': (context) => const PointHistoryScreen(),
              '/daily-checkin': (context) => const DailyCheckinScreen(),
              '/notices': (context) => const NoticeListScreen(),
              '/notice-detail': (context) => const NoticeDetailScreen(),
              '/my-reviews': (context) => const MyReviewsScreen(),
              '/inquiries': (context) => const InquiryListScreen(),
              '/inquiry-detail': (context) => const InquiryDetailScreen(),
              '/inquiry-write': (context) => const InquiryWriteScreen(),
              '/order-returns': (context) => const OrderReturnsScreen(),
              '/order-cancel-request': (context) => const OrderCancelRequestScreen(),
            },
          );
        },
      ),
    );
  }
}

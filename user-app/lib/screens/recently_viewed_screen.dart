import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Load recently viewed products from local storage
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // TODO: Get recently viewed products from local storage
    // For now, show all products as placeholder
    final products = productProvider.products;

    return products.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: '최근 본 상품이 없습니다',
              message: '상품을 둘러보고 다시 확인해보세요',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.575,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length > 20 ? 20 : products.length, // 최대 20개만 표시
              itemBuilder: (context, index) {
                final product = products[index];
                final isInWishlist = wishlistProvider.isInWishlist(product.id ?? '');

                return ProductCard(
                  product: product,
                  isInWishlist: isInWishlist,
                  onTap: () {
                    Navigator.of(context).pushNamed('/product', arguments: product.id);
                  },
                  onAddToCart: () async {
                    try {
                      await cartProvider.addItem(product, quantity: 1);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('장바구니에 추가되었습니다')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류: $e')),
                        );
                      }
                    }
                  },
                  onToggleWishlist: () async {
                    if (authProvider.userId == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인이 필요합니다')),
                        );
                      }
                      return;
                    }

                    try {
                      await wishlistProvider.toggleWishlist(
                        authProvider.userId!,
                        product.id ?? '',
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류: $e')),
                        );
                      }
                    }
                  },
                );
              },
            );
  }
}

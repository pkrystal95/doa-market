import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/category_provider.dart';
import '../providers/theme_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/product_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
      _loadWishlist();
      _loadCategories();
    });
  }

  Future<void> _loadProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.fetchProducts();
  }

  Future<void> _loadWishlist() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await wishlistProvider.fetchWishlist(authProvider.userId!);
    }
  }

  Future<void> _loadCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.fetchCategories();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DOA Market'),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
          // Cart button with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),
              Consumer<CartProvider>(
                builder: (context, cart, child) {
                  if (cart.itemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: AppSpacing.xs,
                    top: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.badge,
                        borderRadius: AppSpacing.borderRadiusFull,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildCategoriesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '카테고리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer3<ProductProvider, CartProvider, WishlistProvider>(
      builder: (context, productProvider, cartProvider, wishlistProvider, child) {
        if (productProvider.isLoading) {
          return GridView.builder(
            padding: AppSpacing.paddingMD,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const ProductCardSkeleton(),
          );
        }

        if (productProvider.error != null) {
          return EmptyState(
            icon: Icons.error_outline,
            title: '오류가 발생했습니다',
            message: productProvider.error,
            actionLabel: '다시 시도',
            onAction: _loadProducts,
          );
        }

        if (productProvider.products.isEmpty) {
          return const EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: '등록된 상품이 없습니다',
            message: '곧 새로운 상품이 추가될 예정입니다',
          );
        }

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        return RefreshIndicator(
          onRefresh: _loadProducts,
          child: GridView.builder(
            padding: AppSpacing.paddingMD,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
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
                  if (!authProvider.isAuthenticated) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 필요합니다')),
                      );
                    }
                    return;
                  }

                  await wishlistProvider.toggleWishlist(
                    authProvider.userId!,
                    product.id!,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(categoryProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadCategories,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        if (categoryProvider.categories.isEmpty) {
          return const Center(
            child: Text('카테고리가 없습니다'),
          );
        }

        // 카테고리별 상품이 선택된 경우
        if (categoryProvider.selectedCategory != null) {
          return _buildCategoryProducts(categoryProvider);
        }

        // 카테고리 목록 표시
        return RefreshIndicator(
          onRefresh: _loadCategories,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: categoryProvider.rootCategories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.rootCategories[index];
              return _buildCategoryCard(category, categoryProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category, CategoryProvider categoryProvider) {
    return GestureDetector(
      onTap: () {
        categoryProvider.selectCategory(category);
      },
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 50,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProducts(CategoryProvider categoryProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Column(
      children: [
        // 카테고리 헤더 (뒤로가기 버튼 포함)
        Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: AppSpacing.elevationSM,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  categoryProvider.selectCategory(null);
                },
              ),
              Expanded(
                child: Text(
                  categoryProvider.selectedCategory?.name ?? '카테고리',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 카테고리별 상품 목록
        Expanded(
          child: categoryProvider.isLoadingProducts
              ? GridView.builder(
                  padding: AppSpacing.paddingMD,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const ProductCardSkeleton(),
                )
              : categoryProvider.categoryProducts.isEmpty
                  ? const EmptyState(
                      icon: Icons.category_outlined,
                      title: '상품이 없습니다',
                      message: '이 카테고리에 등록된 상품이 없습니다',
                    )
                  : GridView.builder(
                      padding: AppSpacing.paddingMD,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                      ),
                      itemCount: categoryProvider.categoryProducts.length,
                      itemBuilder: (context, index) {
                        final product = categoryProvider.categoryProducts[index];
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
                            if (!authProvider.isAuthenticated) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('로그인이 필요합니다')),
                                );
                              }
                              return;
                            }

                            await wishlistProvider.toggleWishlist(
                              authProvider.userId!,
                              product.id!,
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (!auth.isAuthenticated) {
          // 로그인하지 않은 경우
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '로그인이 필요합니다',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '로그인하고 더 많은 기능을 이용해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/signup');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 로그인한 경우 - 마이페이지로 이동
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                auth.userId ?? '사용자',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/mypage');
                },
                icon: const Icon(Icons.account_circle),
                label: const Text(
                  '마이페이지로 이동',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

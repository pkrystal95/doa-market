import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/category_provider.dart';
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
  int _currentBannerIndex = 0;
  late PageController _pageController;
  Timer? _bannerTimer;
  Category? _selectedMainCategory; // 선택된 대분류 카테고리

  final List<Map<String, String>> _banners = [
    {'title': '신년 대축제', 'subtitle': '최대 50% 할인'},
    {'title': '신규 회원 혜택', 'subtitle': '3만원 쿠폰팩 증정'},
    {'title': '무료배송 이벤트', 'subtitle': '전 상품 무료배송'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startBannerAutoPlay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startBannerAutoPlay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentBannerIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);

    await Future.wait([
      productProvider.fetchProducts(),
      categoryProvider.fetchCategories(),
    ]);

    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await wishlistProvider.fetchWishlist(authProvider.userId!);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // 카테고리 탭으로 전환 시 첫 번째 대분류 선택
      if (index == 1 && _selectedMainCategory == null) {
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        if (categoryProvider.rootCategories.isNotEmpty) {
          _selectedMainCategory = categoryProvider.rootCategories.first;
        }
      }

      // 다른 탭으로 전환 시 선택된 대분류 초기화
      if (index != 1) {
        _selectedMainCategory = null;
      }
    });

    // 각 탭별 네비게이션
    switch (index) {
      case 0: // 홈
        break;
      case 1: // 카테고리
        break;
      case 2: // 히스토리
        Navigator.of(context).pushNamed('/orders');
        break;
      case 3: // 내 정보
        Navigator.of(context).pushNamed('/mypage');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _selectedIndex == 0
          ? _buildHomeTab()
          : _selectedIndex == 1
              ? _buildCategoriesTab()
              : Container(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'DOA Market',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // 검색 버튼
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pushNamed('/search');
          },
        ),
        // 장바구니 버튼
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
            ),
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.itemCount == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps),
          label: '카테고리',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: '주문내역',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배너 슬라이더
            _buildBannerSlider(),
            const SizedBox(height: 8),

            // 카테고리 섹션
            _buildHomeCategorySection(),
            const SizedBox(height: 8),

            // 빠른 메뉴
            _buildQuickMenu(),
            const SizedBox(height: 16),

            // 인기 상품
            _buildProductSection(
              title: '🔥 인기 상품',
              description: '지금 가장 핫한 상품',
              type: 'popular',
            ),

            // 신상품
            _buildProductSection(
              title: '✨ 신상품',
              description: '새로 들어온 상품',
              type: 'new',
            ),

            // 할인 상품
            _buildProductSection(
              title: '💰 특가 상품',
              description: '놓치면 후회할 가격',
              type: 'sale',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider() {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // 페이지 인디케이터
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCategorySection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '카테고리',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // 카테고리 탭으로 이동
                  });
                },
                child: const Row(
                  children: [
                    Text('전체보기', style: TextStyle(fontSize: 13)),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final categories = categoryProvider.rootCategories;
              if (categories.isEmpty) {
                return const SizedBox.shrink();
              }

              // 최대 10개 (5x2 그리드)
              final displayCategories = categories.take(10).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: displayCategories.length,
                itemBuilder: (context, index) {
                  final category = displayCategories[index];
                  return _buildCategoryItem(category);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = 1; // 카테고리 탭으로 이동
        });
        final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
        categoryProvider.selectCategory(category);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(category.name),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    if (categoryName.contains('전자') || categoryName.contains('디지털')) {
      return Icons.devices;
    } else if (categoryName.contains('의류') || categoryName.contains('패션')) {
      return Icons.checkroom;
    } else if (categoryName.contains('식품') || categoryName.contains('음식')) {
      return Icons.restaurant;
    } else if (categoryName.contains('가구') || categoryName.contains('인테리어')) {
      return Icons.weekend;
    } else if (categoryName.contains('뷰티') || categoryName.contains('화장품')) {
      return Icons.face;
    } else if (categoryName.contains('스포츠') || categoryName.contains('운동')) {
      return Icons.fitness_center;
    } else if (categoryName.contains('도서') || categoryName.contains('책')) {
      return Icons.menu_book;
    } else if (categoryName.contains('완구') || categoryName.contains('장난감')) {
      return Icons.toys;
    }
    return Icons.category;
  }

  Widget _buildQuickMenu() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickMenuItem(
            icon: Icons.local_fire_department,
            label: '타임특가',
            color: Colors.red,
            onTap: () {},
          ),
          _buildQuickMenuItem(
            icon: Icons.star,
            label: '베스트',
            color: Colors.amber,
            onTap: () {},
          ),
          _buildQuickMenuItem(
            icon: Icons.new_releases,
            label: '신상품',
            color: Colors.green,
            onTap: () {},
          ),
          _buildQuickMenuItem(
            icon: Icons.percent,
            label: '쿠폰',
            color: Colors.purple,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection({
    required String title,
    required String description,
    required String type,
  }) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // 검색 화면으로 이동하거나, 상품 목록 화면으로 이동
                    setState(() {
                      _selectedIndex = 1; // 카테고리 탭으로 이동
                    });
                  },
                  child: const Row(
                    children: [
                      Text('전체보기'),
                      Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Consumer3<ProductProvider, CartProvider, WishlistProvider>(
            builder: (context, productProvider, cartProvider, wishlistProvider, child) {
              if (productProvider.isLoading) {
                return SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          width: 150,
                          child: ProductCardSkeleton(),
                        ),
                      );
                    },
                  ),
                );
              }

              final products = _getProductsByType(productProvider.products, type);

              if (products.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('등록된 상품이 없습니다'),
                  ),
                );
              }

              final authProvider = Provider.of<AuthProvider>(context, listen: false);

              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: products.length > 10 ? 10 : products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isInWishlist = wishlistProvider.isInWishlist(product.id ?? '');

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        width: 160,
                        child: ProductCard(
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
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Product> _getProductsByType(List<Product> allProducts, String type) {
    switch (type) {
      case 'popular':
        // 인기 상품: 재고가 많고 가격이 적당한 상품
        return allProducts.where((p) => (p.stock ?? 0) > 10).toList();
      case 'new':
        // 신상품: 최근 등록된 상품 (실제로는 createdAt 기준)
        return allProducts.reversed.toList();
      case 'sale':
        // 할인 상품: 가격이 낮은 순
        final sorted = List<Product>.from(allProducts);
        sorted.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        return sorted;
      default:
        return allProducts;
    }
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
                  onPressed: _loadData,
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

        // 좌우 분할 레이아웃: 왼쪽 대분류, 오른쪽 중분류
        return Row(
          children: [
            // 왼쪽: 대분류 목록
            Container(
              width: 120,
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: categoryProvider.rootCategories.length,
                itemBuilder: (context, index) {
                  final category = categoryProvider.rootCategories[index];
                  final isSelected = _selectedMainCategory?.id == category.id;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMainCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey[100],
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 오른쪽: 중분류 목록
            Expanded(
              child: Container(
                color: Colors.white,
                child: _selectedMainCategory == null
                    ? const Center(
                        child: Text(
                          '카테고리를 선택하세요',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : _buildSubCategoryList(categoryProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubCategoryList(CategoryProvider categoryProvider) {
    final subCategories = categoryProvider.categories
        .where((cat) => cat.parentId == _selectedMainCategory!.id)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // "전체" 옵션
        InkWell(
          onTap: () {
            categoryProvider.selectCategory(_selectedMainCategory!);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Text(
              '전체',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const Divider(height: 1),

        // 중분류 목록
        ...subCategories.map((subCategory) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  categoryProvider.selectCategory(subCategory);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    subCategory.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
            ],
          );
        }).toList(),
      ],
    );
  }

  // 대분류 카드 (2열 그리드용)
  Widget _buildMainCategoryCard(Category category, CategoryProvider categoryProvider) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMainCategory = category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 중분류 선택 화면
  Widget _buildSubCategorySelection(CategoryProvider categoryProvider) {
    if (_selectedMainCategory == null) {
      return const SizedBox.shrink();
    }

    // 해당 대분류의 중분류 찾기
    final subCategories = categoryProvider.categories
        .where((cat) => cat.parentId == _selectedMainCategory!.id)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_selectedMainCategory!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedMainCategory = null;
            });
          },
        ),
      ),
      body: subCategories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('하위 카테고리가 없습니다'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      categoryProvider.selectCategory(_selectedMainCategory!);
                    },
                    child: const Text('전체 상품 보기'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCategory = subCategories[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMainCategory = null;
                    });
                    categoryProvider.selectCategory(subCategory);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          subCategory.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildCategoryCard(Category category, CategoryProvider categoryProvider) {
    return InkWell(
      onTap: () {
        categoryProvider.selectCategory(category);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(category.name),
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // 카테고리 헤더
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 상품 목록
          Expanded(
            child: categoryProvider.isLoadingProducts
                ? GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
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
      ),
    );
  }
}

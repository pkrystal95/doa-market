import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<SearchProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      searchProvider.fetchPopularKeywords();

      if (authProvider.userId != null) {
        searchProvider.fetchSearchHistory(authProvider.userId!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String keyword) {
    if (keyword.trim().isEmpty) return;

    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.searchProducts(keyword.trim());
  }

  void _onKeywordTap(String keyword) {
    _searchController.text = keyword;
    _performSearch(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchProvider = Provider.of<SearchProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 검색'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: AppSpacing.paddingMD,
            child: SearchBarWidget(
              controller: _searchController,
              hintText: '검색어를 입력하세요',
              autofocus: true,
              onSubmitted: _performSearch,
              onChanged: (value) {
                if (value.isEmpty) {
                  searchProvider.clearSearchResults();
                }
              },
              onClear: () {
                searchProvider.clearSearchResults();
              },
            ),
          ),

          // Content
          Expanded(
            child: searchProvider.currentKeyword.isEmpty
                ? _buildSearchSuggestions(isDark, searchProvider)
                : _buildSearchResults(
                    isDark,
                    searchProvider,
                    authProvider,
                    cartProvider,
                    wishlistProvider,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions(bool isDark, SearchProvider searchProvider) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular keywords
          if (searchProvider.popularKeywords.isNotEmpty) ...[
            Text(
              '인기 검색어',
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: searchProvider.popularKeywords.take(10).map((keyword) {
                return ActionChip(
                  label: Text(keyword),
                  onPressed: () => _onKeywordTap(keyword),
                  backgroundColor: isDark
                      ? AppColors.backgroundSecondaryDark
                      : AppColors.backgroundSecondary,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Search history
          if (searchProvider.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 검색어',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...searchProvider.searchHistory.take(10).map((keyword) {
              return ListTile(
                leading: Icon(
                  Icons.history,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                title: Text(
                  keyword,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.north_west,
                  size: AppSpacing.iconSM,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiary,
                ),
                onTap: () => _onKeywordTap(keyword),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    bool isDark,
    SearchProvider searchProvider,
    AuthProvider authProvider,
    CartProvider cartProvider,
    WishlistProvider wishlistProvider,
  ) {
    if (searchProvider.isLoading) {
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

    if (searchProvider.searchResults.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: '검색 결과가 없습니다',
        message: '다른 검색어로 시도해보세요',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHorizontalMD,
          child: Text(
            '검색 결과 ${searchProvider.searchResults.length}개',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: GridView.builder(
            padding: AppSpacing.paddingMD,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final product = searchProvider.searchResults[index];
              final isInWishlist = wishlistProvider.isInWishlist(product.id!);

              return ProductCard(
                product: product,
                isInWishlist: isInWishlist,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product',
                    arguments: product.id,
                  );
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
                  if (authProvider.userId != null) {
                    await wishlistProvider.toggleWishlist(
                      authProvider.userId!,
                      product.id!,
                    );
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 필요합니다')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

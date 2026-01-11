import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/product_provider.dart';
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
  String _selectedCategory = '전체';
  String _sortBy = '추천순';
  bool _freeShippingOnly = false;

  final List<String> _categories = ['전체', '선크림', '헤라', '달바', '셀푸진'];
  final List<String> _sortOptions = ['추천순', '낮은 가격순', '높은 가격순', '최신순'];

  @override
  void initState() {
    super.initState();
    // TODO: Enable popular keywords and search history when backend endpoints are ready
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //
    //   searchProvider.fetchPopularKeywords();
    //
    //   if (authProvider.userId != null) {
    //     searchProvider.fetchSearchHistory(authProvider.userId!);
    //   }
    // });
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
    final searchProvider = Provider.of<SearchProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.black87),
                  onPressed: () => _performSearch(_searchController.text),
                ),
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                if (value.isEmpty) {
                  searchProvider.clearSearchResults();
                }
              },
            ),
          ),

          // Content
          Expanded(
            child: searchProvider.currentKeyword.isEmpty
                ? _buildSearchSuggestions(searchProvider)
                : _buildSearchResults(
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

  Widget _buildSearchSuggestions(SearchProvider searchProvider) {
    // 인기 검색어 목록 (임시 데이터)
    final popularKeywords = [
      '선크림', '토너', '에센스', '마스크팩',
      '클렌징', '크림', '세럼', '아이크림',
      '립밤', '쿠션'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 실시간 인기 검색어 랭킹
          const Row(
            children: [
              Icon(Icons.trending_up, color: Colors.red, size: 20),
              SizedBox(width: 6),
              Text(
                '실시간 인기 검색어',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2열 그리드로 표시
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 4.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: popularKeywords.length,
            itemBuilder: (context, index) {
              final keyword = popularKeywords[index];
              final isTop3 = index < 3;

              return InkWell(
                onTap: () => _onKeywordTap(keyword),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isTop3 ? Colors.red.shade200 : Colors.grey.shade300,
                      width: isTop3 ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // 랭킹 번호
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isTop3 ? Colors.red : Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 키워드
                      Expanded(
                        child: Text(
                          keyword,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isTop3 ? FontWeight.w600 : FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 상승/하강 표시
                      Icon(
                        index % 3 == 0 ? Icons.arrow_upward :
                        index % 3 == 1 ? Icons.arrow_downward : Icons.remove,
                        size: 14,
                        color: index % 3 == 0 ? Colors.red :
                               index % 3 == 1 ? Colors.blue : Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Search history (if available)
          if (searchProvider.searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 검색어',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Clear search history
                  },
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchProvider.searchHistory.take(10).map<Widget>((keyword) {
                return Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    // TODO: Remove individual keyword
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    SearchProvider searchProvider,
    AuthProvider authProvider,
    CartProvider cartProvider,
    WishlistProvider wishlistProvider,
  ) {
    if (searchProvider.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.575,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      );
    }

    if (searchProvider.searchResults.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: '검색 결과가 없습니다',
        message: '다른 검색어로 시도해보세요',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filters
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: Colors.black87,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? Colors.black87 : Colors.grey[300]!,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Results count and sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '총 ${searchProvider.searchResults.length}개의 검색 결과',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _sortOptions.map((option) {
                            return ListTile(
                              title: Text(option),
                              trailing: _sortBy == option
                                  ? const Icon(Icons.check, color: Colors.blue)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _sortBy = option;
                                });
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Text(
                      _sortBy,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '상세검색',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Free shipping filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Checkbox(
                value: _freeShippingOnly,
                onChanged: (value) {
                  setState(() {
                    _freeShippingOnly = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Text(
                '무료배송',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Section title
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '이 상품을 추천드려요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        // Product grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.575,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            itemCount: searchProvider.searchResults.length,
            itemBuilder: (context, index) {
              final product = searchProvider.searchResults[index];
              final isInWishlist = wishlistProvider.isInWishlist(product.id ?? '');

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
                      product.id ?? '',
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

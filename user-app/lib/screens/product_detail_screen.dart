import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/format_utils.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  Product? _product;
  bool _isLoading = true;
  int _quantity = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final productId = ModalRoute.of(context)?.settings.arguments as String?;
    if (productId != null && productId.isNotEmpty) {
      _loadProduct(productId);
    }
  }

  Future<void> _loadProduct(String productId) async {
    setState(() {
      _isLoading = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final product = await productProvider.fetchProduct(productId);

    setState(() {
      _product = product;
      _isLoading = false;
    });
  }

  void _addToCart() {
    if (_product == null || _product!.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('재고가 부족합니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(_product!, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('장바구니에 $_quantity개 추가되었습니다'),
        action: SnackBarAction(
          label: '장바구니로',
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _product?.name ?? '상품 상세',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          Consumer2<AuthProvider, WishlistProvider>(
            builder: (context, auth, wishlist, child) {
              if (!auth.isAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인이 필요합니다')),
                    );
                    Navigator.of(context).pushNamed('/login');
                  },
                );
              }

              final isInWishlist = _product != null && wishlist.isInWishlist(_product!.id);

              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : Colors.black87,
                ),
                onPressed: _product == null
                    ? null
                    : () async {
                        final success = await wishlist.toggleWishlist(
                          auth.userId!,
                          _product!.id,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isInWishlist ? '찜 목록에서 제거했습니다' : '찜 목록에 추가했습니다',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('상품을 찾을 수 없습니다'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 상품 이미지
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                color: Colors.grey[100],
                                child: _product!.imageUrl != null
                                    ? Image.network(
                                        _product!.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.image_not_supported, size: 100),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Icon(Icons.shopping_bag, size: 100),
                                      ),
                              ),
                            ),

                            // 상품 기본 정보
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 브랜드/판매자
                                  Text(
                                    'DOA',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // 상품명
                                  Text(
                                    _product!.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // 별점
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.blue[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.8 (830)',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // 가격 정보
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '64%',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        FormatUtils.formatPrice(_product!.price),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    FormatUtils.formatPrice(_product!.price * 2.8),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // 배송 정보
                                  _buildInfoRow('배송비', '무료배송'),
                                  const Divider(height: 24),
                                  _buildInfoRow('도착 예정', '내일 도착 보장', isBlue: true),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),

                            // 탭 메뉴
                            Container(
                              color: Colors.white,
                              child: TabBar(
                                controller: _tabController,
                                labelColor: Colors.blue[700],
                                unselectedLabelColor: Colors.grey[600],
                                indicatorColor: Colors.blue[700],
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                tabs: const [
                                  Tab(text: '상세설명'),
                                  Tab(text: '구매후기'),
                                  Tab(text: '상품문의'),
                                  Tab(text: '교환/반품'),
                                ],
                              ),
                            ),

                            // 탭 콘텐츠
                            SizedBox(
                              height: 400,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildDetailTab(),
                                  _buildReviewTab(),
                                  _buildInquiryTab(),
                                  _buildReturnTab(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // 함께 보면 좋은 상품
                            _buildRelatedProducts(),

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomSheet: _product != null
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _product!.stock > 0 ? _addToCart : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.blue[700]!),
                        ),
                        child: Text(
                          '장바구니',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _product!.stock > 0 ? () {} : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '구매하기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBlue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isBlue ? Colors.blue[700] : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '함께 보면 좋은 상품이에요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _product!.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '상품 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('제조사', 'DOA'),
          _buildSpecRow('원산지', '대한민국'),
          _buildSpecRow('배송', '무료배송'),
          _buildSpecRow('재고', '${_product!.stock}개'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          '리뷰가 아직 없습니다',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInquiryTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          '문의가 아직 없습니다',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildReturnTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '교환/반품 안내',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '• 상품 수령 후 7일 이내 교환/반품 가능\n'
            '• 제품의 하자가 있을 경우 무료 교환/반품\n'
            '• 단순 변심의 경우 왕복 배송비 고객 부담\n'
            '• 착용 또는 사용한 제품은 교환/반품 불가',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products.take(3).toList();

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '함께 보면 좋은 상품이에요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Container(
                      width: 165,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: ProductCard(
                        product: product,
                        isInWishlist: false,
                        onTap: () {
                          Navigator.of(context).pushNamed('/product', arguments: product.id);
                        },
                        showActions: false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final int displayOrder;
  final bool isActive;
  final List<Category>? subcategories;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.displayOrder = 0,
    this.isActive = true,
    this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      parentId: json['parentId'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
              .map((subcat) => Category.fromJson(subcat))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': id,
      'name': name,
      'slug': slug,
      'parentId': parentId,
      'displayOrder': displayOrder,
      'isActive': isActive,
      if (subcategories != null)
        'subcategories': subcategories!.map((c) => c.toJson()).toList(),
    };
  }
}

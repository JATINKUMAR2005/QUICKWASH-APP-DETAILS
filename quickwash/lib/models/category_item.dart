class CategoryItem {
  final String name;
  final String emoji;
  final int itemCount;

  const CategoryItem({
    required this.name,
    required this.emoji,
    required this.itemCount,
  });

  static const List<CategoryItem> all = [
    CategoryItem(name: 'Tops', emoji: '👕', itemCount: 42),
    CategoryItem(name: 'Bottoms', emoji: '👖', itemCount: 28),
    CategoryItem(name: 'Ethnic Wear', emoji: '🥻', itemCount: 56),
    CategoryItem(name: 'Formals', emoji: '👔', itemCount: 18),
    CategoryItem(name: 'Shoes', emoji: '👟', itemCount: 15),
    CategoryItem(name: 'Bedding', emoji: '🛏', itemCount: 32),
  ];
}

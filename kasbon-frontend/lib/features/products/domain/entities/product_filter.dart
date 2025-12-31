/// Sort options for product list
enum ProductSortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  stockAsc,
  stockDesc;

  /// Display label for the sort option
  String get label {
    switch (this) {
      case ProductSortOption.nameAsc:
        return 'Nama A-Z';
      case ProductSortOption.nameDesc:
        return 'Nama Z-A';
      case ProductSortOption.priceAsc:
        return 'Harga Terendah';
      case ProductSortOption.priceDesc:
        return 'Harga Tertinggi';
      case ProductSortOption.stockAsc:
        return 'Stok Terendah';
      case ProductSortOption.stockDesc:
        return 'Stok Tertinggi';
    }
  }
}

/// Stock status filter options
enum StockFilter {
  all,
  available,
  lowStock,
  outOfStock;

  /// Display label for the stock filter
  String get label {
    switch (this) {
      case StockFilter.all:
        return 'Semua';
      case StockFilter.available:
        return 'Tersedia';
      case StockFilter.lowStock:
        return 'Stok Rendah';
      case StockFilter.outOfStock:
        return 'Habis';
    }
  }
}

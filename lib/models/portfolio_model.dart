class PortfolioHolding {
  final String id;
  final String companyName;
  final String companyLogo;
  final String symbol;
  final int quantity;
  final double purchasePrice;
  final double currentPrice;
  final DateTime purchaseDate;
  final String category;
  final double dividendYield;

  PortfolioHolding({
    required this.id,
    required this.companyName,
    required this.companyLogo,
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
    required this.purchaseDate,
    required this.category,
    this.dividendYield = 0.0,
  });

  double get totalValue => quantity * currentPrice;
  double get totalCost => quantity * purchasePrice;
  double get profitLoss => totalValue - totalCost;
  double get profitLossPercentage =>
      ((currentPrice - purchasePrice) / purchasePrice) * 100;
  bool get isProfit => profitLoss >= 0;

  // Convert from Supabase JSON
  factory PortfolioHolding.fromJson(Map<String, dynamic> json) {
    return PortfolioHolding(
      id: json['id'],
      companyName: json['company_name'],
      companyLogo: json['company_logo'] ?? '',
      symbol: json['symbol'],
      quantity: json['quantity'],
      purchasePrice: double.parse(json['purchase_price'].toString()),
      currentPrice: double.parse(json['current_price'].toString()),
      purchaseDate: DateTime.parse(json['purchase_date']),
      category: json['category'],
      dividendYield: double.parse(json['dividend_yield']?.toString() ?? '0.0'),
    );
  }

  // Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'company_logo': companyLogo,
      'symbol': symbol,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'current_price': currentPrice,
      'purchase_date': purchaseDate.toIso8601String(),
      'category': category,
      'dividend_yield': dividendYield,
    };
  }

  PortfolioHolding copyWith({
    String? id,
    String? companyName,
    String? companyLogo,
    String? symbol,
    int? quantity,
    double? purchasePrice,
    double? currentPrice,
    DateTime? purchaseDate,
    String? category,
    double? dividendYield,
  }) {
    return PortfolioHolding(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      category: category ?? this.category,
      dividendYield: dividendYield ?? this.dividendYield,
    );
  }

  static List<PortfolioHolding> getSampleData() {
    final now = DateTime.now();
    return [
      PortfolioHolding(
        id: '1',
        companyName: 'TechCorp Solutions',
        companyLogo:
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop&crop=center',
        symbol: 'TECH',
        quantity: 50,
        purchasePrice: 485.0,
        currentPrice: 520.0,
        purchaseDate: now.subtract(const Duration(days: 30)),
        category: 'Technology',
        dividendYield: 2.5,
      ),
      PortfolioHolding(
        id: '2',
        companyName: 'FinanceGrow Ltd',
        companyLogo:
            'https://images.pexels.com/photos/3483098/pexels-photo-3483098.jpeg?w=100&h=100&fit=crop&crop=center',
        symbol: 'FGRO',
        quantity: 75,
        purchasePrice: 335.0,
        currentPrice: 342.0,
        purchaseDate: now.subtract(const Duration(days: 45)),
        category: 'Finance',
        dividendYield: 3.2,
      ),
      PortfolioHolding(
        id: '3',
        companyName: 'HealthTech Innovations',
        companyLogo:
            'https://images.pixabay.com/photo/2017/06/16/07/26/network-2407499_1280.jpg?w=100&h=100&fit=crop&crop=center',
        symbol: 'HLTH',
        quantity: 100,
        purchasePrice: 300.0,
        currentPrice: 285.0,
        purchaseDate: now.subtract(const Duration(days: 60)),
        category: 'Healthcare',
        dividendYield: 1.8,
      ),
      PortfolioHolding(
        id: '4',
        companyName: 'EcoEnergy Systems',
        companyLogo:
            'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=100&h=100&fit=crop&crop=center',
        symbol: 'ECOS',
        quantity: 25,
        purchasePrice: 550.0,
        currentPrice: 580.0,
        purchaseDate: now.subtract(const Duration(days: 15)),
        category: 'Energy',
        dividendYield: 4.1,
      ),
    ];
  }
}

class PortfolioTransaction {
  final String id;
  final String holdingId;
  final String companyName;
  final String symbol;
  final TransactionType type;
  final int quantity;
  final double price;
  final DateTime date;
  final double fees;

  PortfolioTransaction({
    required this.id,
    required this.holdingId,
    required this.companyName,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
    this.fees = 0.0,
  });

  double get totalAmount => (quantity * price) + fees;

  // Convert from Supabase JSON
  factory PortfolioTransaction.fromJson(Map<String, dynamic> json) {
    return PortfolioTransaction(
      id: json['id'],
      holdingId: json['holding_id'] ?? '',
      companyName: json['company_name'],
      symbol: json['symbol'],
      type: TransactionType.values.firstWhere(
        (type) => type.name == json['transaction_type'],
        orElse: () => TransactionType.buy,
      ),
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      date: DateTime.parse(json['transaction_date']),
      fees: double.parse(json['fees']?.toString() ?? '0.0'),
    );
  }

  // Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'holding_id': holdingId.isEmpty ? null : holdingId,
      'company_name': companyName,
      'symbol': symbol,
      'transaction_type': type.name,
      'quantity': quantity,
      'price': price,
      'transaction_date': date.toIso8601String(),
      'fees': fees,
    };
  }

  static List<PortfolioTransaction> getSampleData() {
    final now = DateTime.now();
    return [
      PortfolioTransaction(
        id: '1',
        holdingId: '1',
        companyName: 'TechCorp Solutions',
        symbol: 'TECH',
        type: TransactionType.buy,
        quantity: 50,
        price: 485.0,
        date: now.subtract(const Duration(days: 30)),
        fees: 15.0,
      ),
      PortfolioTransaction(
        id: '2',
        holdingId: '2',
        companyName: 'FinanceGrow Ltd',
        symbol: 'FGRO',
        type: TransactionType.buy,
        quantity: 75,
        price: 335.0,
        date: now.subtract(const Duration(days: 45)),
        fees: 20.0,
      ),
      PortfolioTransaction(
        id: '3',
        holdingId: '3',
        companyName: 'HealthTech Innovations',
        symbol: 'HLTH',
        type: TransactionType.buy,
        quantity: 100,
        price: 300.0,
        date: now.subtract(const Duration(days: 60)),
        fees: 25.0,
      ),
      PortfolioTransaction(
        id: '4',
        holdingId: '4',
        companyName: 'EcoEnergy Systems',
        symbol: 'ECOS',
        type: TransactionType.buy,
        quantity: 25,
        price: 550.0,
        date: now.subtract(const Duration(days: 15)),
        fees: 12.0,
      ),
      PortfolioTransaction(
        id: '5',
        holdingId: '3',
        companyName: 'HealthTech Innovations',
        symbol: 'HLTH',
        type: TransactionType.sell,
        quantity: 20,
        price: 290.0,
        date: now.subtract(const Duration(days: 10)),
        fees: 8.0,
      ),
    ];
  }
}

enum TransactionType {
  buy,
  sell,
  dividend,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
      case TransactionType.dividend:
        return 'Dividend';
    }
  }

  String get colorCode {
    switch (this) {
      case TransactionType.buy:
        return 'green';
      case TransactionType.sell:
        return 'red';
      case TransactionType.dividend:
        return 'blue';
    }
  }
}

class PortfolioSummary {
  final double totalValue;
  final double totalCost;
  final double dailyChange;
  final double dailyChangePercentage;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final int totalHoldings;

  PortfolioSummary({
    required this.totalValue,
    required this.totalCost,
    required this.dailyChange,
    required this.dailyChangePercentage,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    required this.totalHoldings,
  });

  bool get isDailyGain => dailyChange >= 0;
  bool get isTotalGain => totalProfitLoss >= 0;

  static PortfolioSummary getSampleData() {
    return PortfolioSummary(
      totalValue: 1547250.0,
      totalCost: 1485000.0,
      dailyChange: 12450.0,
      dailyChangePercentage: 0.81,
      totalProfitLoss: 62250.0,
      totalProfitLossPercentage: 4.19,
      totalHoldings: 4,
    );
  }
}

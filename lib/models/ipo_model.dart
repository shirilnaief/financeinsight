class IPOModel {
  final String id;
  final String companyName;
  final String companyLogo;
  final String priceRange;
  final int lotSize;
  final String issueSize;
  final DateTime openDate;
  final DateTime closeDate;
  final DateTime? listingDate;
  final IPOStatus status;
  final String category;
  final String description;
  final bool isBookmarked;

  IPOModel({
    required this.id,
    required this.companyName,
    required this.companyLogo,
    required this.priceRange,
    required this.lotSize,
    required this.issueSize,
    required this.openDate,
    required this.closeDate,
    this.listingDate,
    required this.status,
    required this.category,
    required this.description,
    this.isBookmarked = false,
  });

  IPOModel copyWith({
    String? id,
    String? companyName,
    String? companyLogo,
    String? priceRange,
    int? lotSize,
    String? issueSize,
    DateTime? openDate,
    DateTime? closeDate,
    DateTime? listingDate,
    IPOStatus? status,
    String? category,
    String? description,
    bool? isBookmarked,
  }) {
    return IPOModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      priceRange: priceRange ?? this.priceRange,
      lotSize: lotSize ?? this.lotSize,
      issueSize: issueSize ?? this.issueSize,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      listingDate: listingDate ?? this.listingDate,
      status: status ?? this.status,
      category: category ?? this.category,
      description: description ?? this.description,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  // Convert from Supabase JSON
  factory IPOModel.fromJson(Map<String, dynamic> json) {
    return IPOModel(
      id: json['id'],
      companyName: json['company_name'],
      companyLogo: json['company_logo'] ?? '',
      priceRange: json['price_range'],
      lotSize: json['lot_size'],
      issueSize: json['issue_size'],
      openDate: DateTime.parse(json['open_date']),
      closeDate: DateTime.parse(json['close_date']),
      listingDate: json['listing_date'] != null
          ? DateTime.parse(json['listing_date'])
          : null,
      status: IPOStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => IPOStatus.upcoming,
      ),
      category: json['category'],
      description: json['description'] ?? '',
      isBookmarked: json['is_bookmarked'] ?? false,
    );
  }

  // Convert to Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'company_logo': companyLogo,
      'price_range': priceRange,
      'lot_size': lotSize,
      'issue_size': issueSize,
      'open_date': openDate.toIso8601String(),
      'close_date': closeDate.toIso8601String(),
      'listing_date': listingDate?.toIso8601String(),
      'status': status.name,
      'category': category,
      'description': description,
    };
  }

  static List<IPOModel> getSampleData() {
    final now = DateTime.now();
    return [
      IPOModel(
        id: '1',
        companyName: 'TechCorp Solutions',
        companyLogo:
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop&crop=center',
        priceRange: '₹450-500',
        lotSize: 30,
        issueSize: '₹2,500 Cr',
        openDate: now.add(const Duration(days: 5)),
        closeDate: now.add(const Duration(days: 8)),
        listingDate: now.add(const Duration(days: 15)),
        status: IPOStatus.upcoming,
        category: 'Technology',
        description: 'Leading technology solutions provider',
      ),
      IPOModel(
        id: '2',
        companyName: 'FinanceGrow Ltd',
        companyLogo:
            'https://images.pexels.com/photos/3483098/pexels-photo-3483098.jpeg?w=100&h=100&fit=crop&crop=center',
        priceRange: '₹320-350',
        lotSize: 50,
        issueSize: '₹1,800 Cr',
        openDate: now.subtract(const Duration(days: 2)),
        closeDate: now.add(const Duration(days: 1)),
        status: IPOStatus.ongoing,
        category: 'Finance',
        description: 'Financial services and investment solutions',
      ),
      IPOModel(
        id: '3',
        companyName: 'HealthTech Innovations',
        companyLogo:
            'https://images.pixabay.com/photo/2017/06/16/07/26/network-2407499_1280.jpg?w=100&h=100&fit=crop&crop=center',
        priceRange: '₹280-320',
        lotSize: 40,
        issueSize: '₹1,200 Cr',
        openDate: now.subtract(const Duration(days: 10)),
        closeDate: now.subtract(const Duration(days: 7)),
        listingDate: now.subtract(const Duration(days: 2)),
        status: IPOStatus.listed,
        category: 'Healthcare',
        description: 'Healthcare technology and telemedicine',
      ),
      IPOModel(
        id: '4',
        companyName: 'EcoEnergy Systems',
        companyLogo:
            'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=100&h=100&fit=crop&crop=center',
        priceRange: '₹520-580',
        lotSize: 25,
        issueSize: '₹3,200 Cr',
        openDate: now.subtract(const Duration(days: 15)),
        closeDate: now.subtract(const Duration(days: 12)),
        status: IPOStatus.closed,
        category: 'Energy',
        description: 'Renewable energy and sustainable solutions',
      ),
      IPOModel(
        id: '5',
        companyName: 'RetailMax Corporation',
        companyLogo:
            'https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?w=100&h=100&fit=crop&crop=center',
        priceRange: '₹180-220',
        lotSize: 60,
        issueSize: '₹950 Cr',
        openDate: now.add(const Duration(days: 12)),
        closeDate: now.add(const Duration(days: 15)),
        listingDate: now.add(const Duration(days: 22)),
        status: IPOStatus.upcoming,
        category: 'Retail',
        description: 'Multi-brand retail and e-commerce platform',
      ),
      IPOModel(
        id: '6',
        companyName: 'AutoDrive Technologies',
        companyLogo:
            'https://images.pixabay.com/photo/2016/11/19/14/00/code-1839406_1280.jpg?w=100&h=100&fit=crop&crop=center',
        priceRange: '₹650-750',
        lotSize: 20,
        issueSize: '₹4,100 Cr',
        openDate: now.subtract(const Duration(days: 1)),
        closeDate: now.add(const Duration(days: 2)),
        status: IPOStatus.ongoing,
        category: 'Automotive',
        description: 'Autonomous vehicle technology and AI solutions',
      ),
    ];
  }
}

enum IPOStatus {
  upcoming,
  ongoing,
  closed,
  listed,
}

extension IPOStatusExtension on IPOStatus {
  String get displayName {
    switch (this) {
      case IPOStatus.upcoming:
        return 'Upcoming';
      case IPOStatus.ongoing:
        return 'Ongoing';
      case IPOStatus.closed:
        return 'Closed';
      case IPOStatus.listed:
        return 'Listed';
    }
  }

  String get colorCode {
    switch (this) {
      case IPOStatus.upcoming:
        return 'blue';
      case IPOStatus.ongoing:
        return 'green';
      case IPOStatus.closed:
        return 'orange';
      case IPOStatus.listed:
        return 'purple';
    }
  }
}

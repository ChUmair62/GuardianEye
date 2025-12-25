class Officer {
  final String id;
  final String name;
  final String rank;
  final String department;
  final String badgeNumber;
  final String email;
  final String phone;

  Officer({
    required this.id,
    required this.name,
    required this.rank,
    required this.department,
    required this.badgeNumber,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rank': rank,
      'department': department,
      'badgeNumber': badgeNumber,
      'email': email,
      'phone': phone,
    };
  }

  factory Officer.fromMap(String id, Map<String, dynamic> data) {
    return Officer(
      id: id,
      name: data['name'] ?? '',
      rank: data['rank'] ?? '',
      department: data['department'] ?? '',
      badgeNumber: data['badgeNumber'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }
}

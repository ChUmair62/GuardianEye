class Suspect {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String address;
  final String caseNumber;
  final String notes;

  Suspect({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.address,
    required this.caseNumber,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'address': address,
      'caseNumber': caseNumber,
      'notes': notes,
    };
  }

  factory Suspect.fromMap(String id, Map<String, dynamic> data) {
    return Suspect(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      address: data['address'] ?? '',
      caseNumber: data['caseNumber'] ?? '',
      notes: data['notes'] ?? '',
    );
  }
}

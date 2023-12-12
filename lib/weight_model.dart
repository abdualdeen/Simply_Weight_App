class Weight {
  int id = 0;
  double weight = 0;
  DateTime dateTime = DateTime.parse('0000-00-00');

  Weight.empty();

  Weight({
    required this.id,
    required this.weight,
    required this.dateTime,
  });

  factory Weight.fromMap(Map<String, dynamic> json) {
    return Weight(
      id: json['id'],
      weight: json['weight'],
      dateTime: json['dateTime'],
    );
  }

  Map<String, dynamic> toMap() => {
        'weight': weight,
        'dateTime': dateTime,
      };
}

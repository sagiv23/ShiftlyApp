import 'package:hive/hive.dart';

part 'automatic_expense.g.dart';

@HiveType(typeId: 5)
class AutomaticExpense extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  AutomaticExpense({required this.description, required this.amount});

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
  };

  factory AutomaticExpense.fromJson(Map<String, dynamic> json) =>
      AutomaticExpense(
        description: json['description']?.toString() ?? '',
        amount: json['amount'] != null
            ? double.parse(json['amount'].toString())
            : 0.0,
      );

  AutomaticExpense copyWith({String? description, double? amount}) {
    return AutomaticExpense(
      description: description ?? this.description,
      amount: amount ?? this.amount,
    );
  }
}

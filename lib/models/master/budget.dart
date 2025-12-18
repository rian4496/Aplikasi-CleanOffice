import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    @JsonKey(name: 'fiscal_year') required int fiscalYear,
    @JsonKey(name: 'source_name') required String sourceName, // e.g., 'APBD Murni'
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'remaining_amount') required double remainingAmount,
    required String status, // 'active', 'closed'
    String? description,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
}

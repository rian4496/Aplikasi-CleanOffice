
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/master/budget.dart';
import 'master_providers.dart';

part 'budget_view_providers.g.dart';

// --- State Providers ---

@riverpod
class BudgetFilterYear extends _$BudgetFilterYear {
  @override
  int build() {
    return DateTime.now().year; // Default to current year
  }

  void setYear(int year) {
    state = year;
  }
}

// --- Derived Providers ---

@riverpod
List<Budget> filteredBudgets(Ref ref) {
  final budgetsAsync = ref.watch(budgetsProvider);
  final year = ref.watch(budgetFilterYearProvider);

  return budgetsAsync.maybeWhen(
    data: (budgets) {
      return budgets.where((b) => b.fiscalYear == year).toList();
    },
    orElse: () => [],
  );
}

@riverpod
BudgetStats budgetGlobalStats(Ref ref) {
  final budgets = ref.watch(filteredBudgetsProvider);

  double totalPagu = 0;
  double totalRemaining = 0;

  for (var b in budgets) {
    if (b.status == 'active' || b.status == 'planning') { // Include planning? Maybe only active. Let's include both for Total Pagu.
       totalPagu += b.totalAmount;
       totalRemaining += b.remainingAmount;
    }
  }

  final totalRealized = totalPagu - totalRemaining;
  final percent = totalPagu > 0 ? (totalRealized / totalPagu) : 0.0;

  return BudgetStats(
    totalPagu: totalPagu,
    totalRemaining: totalRemaining,
    totalRealized: totalRealized,
    realizationPercent: percent,
    totalBudgets: budgets.length,
  );
}

// --- Helper Model ---
class BudgetStats {
  final double totalPagu;
  final double totalRemaining;
  final double totalRealized;
  final double realizationPercent;
  final int totalBudgets;

  BudgetStats({
    required this.totalPagu,
    required this.totalRemaining,
    required this.totalRealized,
    required this.realizationPercent,
    required this.totalBudgets,
  });
}

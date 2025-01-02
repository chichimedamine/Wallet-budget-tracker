import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

import '../../Model/ListInfo.dart';

part 'analysis_event.dart';
part 'analysis_state.dart';

class AnalysisBloc extends Bloc<AnalysisEvent, AnalysisState> {
  AnalysisBloc() : super(AnalysisInitial()) {
    on<LaunchAnalysisEvent>((event, emit) async {
      emit(AnalysisLoading());
      final transctionData = await Hive.openBox('transaction');
      final List expensesadata = transctionData.values
          .where((t) => t.type == "Expense")
          .map((t) => {
                'category': t.category ?? '',
                'amount': double.parse(t.amount ?? "0"),
                'percentage': 0
              })
          .toList();

      final List incomesadata = transctionData.values
          .where((t) => t.type == "Income")
          .map((t) => {
                'category': t.category ?? '',
                'amount': double.parse(t.amount ?? "0"),
                'percentage': 0
              })
          .toList();
      if (event.value == "Expenses" && expensesadata.isEmpty) {
        emit(AnalysisEmpty(selectedValue: event.value));
      } else if (event.value == "Income" && incomesadata.isEmpty) {
        emit(AnalysisEmpty(selectedValue: event.value));
      } else {
        add(FetchAnalysisEvent(event.value));
      }

      // TODO: implement event handler
    });
    on<FetchAnalysisEvent>((event, emit) async {
      double percentages = 0;
      emit(AnalysisLoading());
      final transctionData = await Hive.openBox('transaction');
      final List expensesadata = transctionData.values
          .where((t) => t.type == "Expense")
          .map((t) => {
                'category': t.category ?? '',
                'amount': double.parse(t.amount ?? "0"),
                'percentage': 0,
                'date': t.date ?? '',
                'account': t.fromAccount
              })
          .toList();

      final List incomesadata = transctionData.values
          .where((t) => t.type == "Income")
          .map((t) => {
                'category': t.category ?? '',
                'amount': double.parse(t.amount ?? "0"),
                'percentage': 0,
                'date': t.date ?? '',
                'account': t.fromAccount
              })
          .toList();
      print("dataaa income $incomesadata");

      //percentages expenses
      Map<String, double> dataMapExp = {};
      Map<String, List> dataMapexpCategory = {};

      double totalExpenses = expensesadata.isNotEmpty
          ? expensesadata.map((t) => t['amount']).reduce((a, b) => a + b)
          : 0;
      List expensescategory = expensesadata.isNotEmpty
          ? expensesadata.map((t) => t['category']).toSet().toList()
          : [];
      List expensesamounts = expensesadata.isNotEmpty
          ? expensesadata.map((t) => t['amount']).toList()
          : [];
      percentages = expensesamounts.isNotEmpty
          ? expensesamounts
              .map((t) => t / totalExpenses)
              .reduce((a, b) => a + b)
          : 0;
      //percentage each category :
      print(expensescategory);
      if (expensescategory.isNotEmpty) {
        for (var i = 0; i < expensescategory.length; i++) {
          double percentageCategory = 0;
          double amountCategory = 0;
          List<ListInfo> datalist = [];

          double date = 0;
          for (var j = 0; j < expensesadata.length; j++) {
            expensesadata[j]['percentage'] =
                (expensesamounts[j] / totalExpenses) * 100;
            if (expensesadata[j]['category'] == expensescategory[i]) {
              date = expensesadata[j]['date'].millisecondsSinceEpoch.toDouble();
              datalist.add(ListInfo(
                  account: expensesadata[j]['account'],
                  date: date,
                  amount: expensesadata[j]['amount']));
              percentageCategory =
                  expensesadata[j]['percentage'] + percentageCategory;
              amountCategory = expensesadata[j]['amount'] + amountCategory;
            }
          }
          print(
              "category: ${expensescategory[i]} ,percentage: $percentageCategory");
          dataMapExp.putIfAbsent(expensescategory[i], () => percentageCategory);
          dataMapexpCategory.putIfAbsent(
              expensescategory[i], () => [amountCategory, datalist]);
        }
      }

      //percentages incomes
      Map<String, double> dataMapin = {};
      Map<String, List> dataMapIncCategory = {};
      double totalIncomes = 0;
      if (incomesadata.isNotEmpty) {
        totalIncomes =
            incomesadata.map((t) => t['amount']).reduce((a, b) => a + b);
        List incomecategory =
            incomesadata.map((t) => t['category']).toSet().toList();
        List incomeamounts = incomesadata.map((t) => t['amount']).toList();
        percentages =
            incomeamounts.map((t) => t / totalIncomes).reduce((a, b) => a + b);
        //percentage each category :
        print(incomecategory);

        for (var i = 0; i < incomecategory.length; i++) {
          double percentageCategory = 0;
          double amountCategory = 0;
          double date = 0;
          List<ListInfo> datalist2 = [];

          for (var j = 0; j < incomesadata.length; j++) {
            incomesadata[j]['percentage'] =
                (incomeamounts[j] / totalIncomes) * 100;
            if (incomesadata[j]['category'] == incomecategory[i]) {
              date = incomesadata[j]['date'].millisecondsSinceEpoch.toDouble();
              print(
                  "tes4 ${incomesadata[j]['account']} ${incomesadata[j]['amount']}, $date");
              datalist2.add(ListInfo(
                  account: incomesadata[j]['account'],
                  date: date,
                  amount: incomesadata[j]['amount']));
              print("tes5");
              percentageCategory =
                  incomesadata[j]['percentage'] + percentageCategory;
              amountCategory = incomesadata[j]['amount'] + amountCategory;
            }
          }
          print(
              "Income / category: ${incomecategory[i]} ,percentage: $percentageCategory");
          dataMapin.putIfAbsent(incomecategory[i], () => percentageCategory);
          dataMapIncCategory.putIfAbsent(
              incomecategory[i], () => [amountCategory, datalist2]);
        }
      }
      print("selected value: ${event.value}");
      print("dataMapExp: $dataMapExp");
      print("dataMapin: $dataMapin");

      print("dataMapexpCategory: $dataMapexpCategory");
      print("dataMapIncCategory: $dataMapIncCategory");

      emit(AnalysisLoaded(
        selectedValue: event.value,
        dataMapExpense: dataMapExp,
        dataMapIncome: dataMapin,
        expensesData: dataMapexpCategory,
        incomesData: dataMapIncCategory,
      ));
    });
    on<ChangeAnalysisEvent>((event, emit) async {
      emit(AnalysisLoading());
      final transctionData = await Hive.openBox('transaction');
      final List expensesadata = transctionData.values
          .where((t) => t.type == "Expense")
          .map((t) => {
                'category': t.category ?? '',
                'amount': double.parse(t.amount ?? "0"),
                'percentage': 0
              })
          .toList();

      final List incomesadata = transctionData.values
          .where((t) => t.type == "Income")
          .map((t) => {
                'category': t.category ?? '',
                'amount': double.parse(t.amount ?? "0"),
                'percentage': 0
              })
          .toList();
      print("ddddd ${incomesadata.isEmpty}");
      print("selected value: ${event.value}");

      if (event.value == "Expenses" && expensesadata.isEmpty) {
        emit(AnalysisEmpty(selectedValue: event.value));
      } else if (event.value == "Income" && incomesadata.isEmpty) {
        emit(AnalysisEmpty(selectedValue: event.value));
      } else {
        add(FetchAnalysisEvent(event.value));
      }
    });
  }
}

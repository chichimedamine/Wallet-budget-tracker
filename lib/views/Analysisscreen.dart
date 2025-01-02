import 'dart:convert';

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:wallet_budget_tracker/Model/ListInfo.dart';
import 'package:wallet_budget_tracker/views/homescreen.dart';

import '../bloc/analysis/analysis_bloc.dart';
import '../components/backgroundcard.dart';
import '../components/barchart.dart';
import '../helper/colors.dart';
import '../helper/fonts.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class Analysisscreen extends StatelessWidget {
  const Analysisscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BackgroundCard(body: const Bodycard()),
            BlocProvider(
              create: (context) =>
                  AnalysisBloc()..add(const LaunchAnalysisEvent()),
              child: BlocBuilder<AnalysisBloc, AnalysisState>(
                builder: (context, state) {
                  if (state is AnalysisLoading) {
                    return const SizedBox(
                        height: 300,
                        width: 300,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: ColorsHelper.green,
                        )));
                  }
                  if (state is AnalysisLoaded) {
                    Map<String, double> dataMap = {};
                    Map<String, List> data = {};

                    state.selectedValue == "Expenses"
                        ? dataMap = state.dataMapExpense
                        : dataMap = state.dataMapIncome;
                    state.selectedValue == "Expenses"
                        ? data = state.expensesData
                        : data = state.incomesData;
                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 300,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                  color: ColorsHelper.green,
                                ),
                              ),
                              menuItemStyleData: MenuItemStyleData(
                                overlayColor:
                                    WidgetStateProperty.all(ColorsHelper.green),
                                height: 40,
                                padding: const EdgeInsets.only(left: 10),
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  LucideIcons.chevronDown,
                                  color: Colors.white,
                                ),
                              ),
                              isExpanded: true,
                              hint: Text(
                                'Select an option',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              value: state.selectedValue,
                              buttonStyleData: ButtonStyleData(
                                  decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                color: ColorsHelper.green,
                              )),
                              onChanged: (String? newValue) {
                                print(newValue);
                                context
                                    .read<AnalysisBloc>()
                                    .add(ChangeAnalysisEvent(newValue!));
                              },
                              items: ["Expenses", "Income"]
                                  .map((String value) =>
                                      DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: FontsHelper.boldTextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            )),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        PieChartWidget(state.selectedValue, data, dataMap),
                        /*  ElevatedButton(
                            onPressed: () {
                              ShowBottomSheet(context);
                            },
                            child: Text(
                              "View details",
                              style: FontsHelper.boldTextStyle(fontSize: 18),
                            )),*/
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  }
                  if (state is AnalysisEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: state.selectedValue,
                            icon: const Icon(LucideIcons.chevronDown),
                            iconSize: 24,
                            elevation: 16,
                            style: FontsHelper.boldTextStyle(fontSize: 18),
                            onChanged: (String? newValue) {
                              print(newValue);

                              context
                                  .read<AnalysisBloc>()
                                  .add(ChangeAnalysisEvent(newValue!));
                            },
                            items: <String>["Expenses", "Income"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(
                            height: 150,
                            width: 150,
                            child: Icon(
                              LucideIcons.ban,
                              size: 100,
                              color: ColorsHelper.lightGray,
                            ),
                          ),
                          Text("No analysis for this month",
                              style: FontsHelper.boldTextStyle(
                                  fontSize: 20, color: ColorsHelper.lightGray)),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsHelper.green,
        child: const Icon(
          Icons.add,
          color: ColorsHelper.white,
        ),
        onPressed: () {},
      ),
    );
  }
}

Widget PieChartWidget(
    String selectedValue, Map<String, List> data, Map<String, double> dataMap) {
  return StatefulBuilder(
    builder: (context, setState) => Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: const BoxDecoration(
            color: ColorsHelper.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Center(
              child: SizedBox(
            child: PieChart(
              centerTextStyle: FontsHelper.smallTextStyle(
                fontSize: 12,
                color: ColorsHelper.black,
              ),
              chartType: ChartType.disc,
              dataMap: dataMap,
              chartValuesOptions: const ChartValuesOptions(
                showChartValuesInPercentage: false,
                showChartValues: false,
                showChartValuesOutside: false,
                decimalPlaces: 1,
              ),
              legendOptions: LegendOptions(
                showLegends: true,
                legendPosition: LegendPosition.right,
                legendTextStyle: FontsHelper.smallTextStyle(
                    fontSize: 12, color: ColorsHelper.black),
              ),
            ),
          )),
        ),
        Container(
          width: double.infinity,
          /*  decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border(
                top: BorderSide(
                  color: selectedValue == "Expenses"
                      ? ColorsHelper.red
                      : ColorsHelper.green,
                  width: 2.0,
                ),
                bottom: BorderSide(
                  color: selectedValue == "Expenses"
                      ? ColorsHelper.red
                      : ColorsHelper.green,
                  width: 2.0,
                ),
                left: BorderSide(
                  color: selectedValue == "Expenses"
                      ? ColorsHelper.red
                      : ColorsHelper.green,
                  width: 2.0,
                ),
                right: BorderSide(
                  color: selectedValue == "Expenses"
                      ? ColorsHelper.red
                      : ColorsHelper.green,
                  width: 2.0,
                ),
              )),*/
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          height: 200,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => ListTile(
                onTap: () {
                  setState(() {});

                  ShowBottomSheet(context, data, index, selectedValue,
                      dataMap.keys.toList()[index]);
                },
                trailing:
                    dataMap.keys.toList()[index] == data.keys.toList()[index]
                        ? Text(
                            "${selectedValue == "Expenses" ? "-" : "+"} ${data.values.toList()[index][0]} DT",
                            style: FontsHelper.boldTextStyle(
                                fontSize: 12,
                                color: selectedValue == "Expenses"
                                    ? ColorsHelper.red
                                    : ColorsHelper.green),
                          )
                        : Text(
                            "${data.values.toList()[index]} DT",
                            style: FontsHelper.boldTextStyle(
                                fontSize: 12, color: ColorsHelper.black),
                          ),
                leading: SizedBox(
                    height: 40,
                    width: 40,
                    child: DashedCircularProgressBar.aspectRatio(
                      aspectRatio: 1, // width ÷ height
                      valueNotifier: ValueNotifier(
                        dataMap.values.toList()[index],
                      ),
                      progress: dataMap.values.toList()[index],
                      maxProgress: 100,
                      corners: StrokeCap.butt,
                      foregroundColor: selectedValue == "Expenses"
                          ? ColorsHelper.red
                          : ColorsHelper.green,
                      backgroundColor: const Color(0xffeeeeee),
                      foregroundStrokeWidth: 2,
                      backgroundStrokeWidth: 2,
                      animation: true,
                      child: Center(
                        child: ValueListenableBuilder(
                          valueListenable: ValueNotifier(
                            dataMap.values.toList()[index],
                          ),
                          builder: (_, double value, __) =>
                              Text('${value.toInt()}%',
                                  style: FontsHelper.boldTextStyle(
                                    fontSize: 12,
                                    color: ColorsHelper.black,
                                  )),
                        ),
                      ),
                    )),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      dataMap.keys.toList()[index],
                      style: FontsHelper.boldTextStyle(
                          fontSize: 12, color: ColorsHelper.black),
                    ),
                  ],
                )),
            itemCount: dataMap.length,
            shrinkWrap: true,
          ),
        ),
      ],
    ),
  );
}

ShowBottomSheet(context, Map<String, List> data, int indexg,
    String selectedValue, String countryname) {
  List dataw = data.values.toList()[indexg][1];
  print("qqq ${dataw.length}");
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
            height: 300,
            width: double.infinity,
            color: ColorsHelper.green,
            child: Column(children: [
              Row(
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        countryname,
                        style: FontsHelper.boldTextStyle(
                            color: ColorsHelper.white, fontSize: 18),
                      ),
                      Text(
                        "$selectedValue category",
                        style: FontsHelper.smallTextStyle(
                            color: ColorsHelper.white, fontSize: 5),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        LucideIcons.x,
                        color: ColorsHelper.white,
                      ))
                ],
              ),
              const Divider(
                color: ColorsHelper.white,
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ListTile(
                      trailing: Container(
                        height: 30,
                        width: 120,
                        decoration: BoxDecoration(
                          color: ColorsHelper.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selectedValue == "Expenses"
                                  ? ColorsHelper.red
                                  : ColorsHelper.green),
                        ),
                        child: Center(
                          child: Text(
                            "${selectedValue == "Expenses" ? "-" : "+"} ${dataw[index].amount} DT",
                            style: FontsHelper.boldTextStyle(
                                fontSize: 18,
                                color: selectedValue == "Expenses"
                                    ? ColorsHelper.red
                                    : ColorsHelper.green),
                          ),
                        ),
                      ),
                      leading: const Icon(
                        LucideIcons.dot,
                        color: ColorsHelper.white,
                      ),
                      title: Text(
                        "${dataw[index].account}",
                        style: FontsHelper.boldTextStyle(
                            color: ColorsHelper.white, fontSize: 18),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                dataw[index].date.toInt())),
                        style: FontsHelper.smallTextStyle(
                            color: ColorsHelper.white, fontSize: 18),
                      ),
                    );
                  },
                  itemCount: dataw.length,
                ),
              )
            ]) //BarChartSample2(),
            );
      });
}

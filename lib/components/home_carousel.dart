import 'package:flutter/material.dart';
import 'package:wallet_budget_tracker/components/ExpenseOverview.dart';
import 'package:wallet_budget_tracker/helper/colors.dart';

import 'IncomeOverview.dart';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({super.key});

  @override
  _HomeCarouselState createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  List<Widget> items = [
    const IncomeOverview(),
    const ExpenseOverview(),
  ];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: CarouselView(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: ColorsHelper.green,
                    width: 5,
                  ),
                ),
                backgroundColor: ColorsHelper.white,
                itemExtent: 500,
                itemSnapping: true,
                elevation: 5,
                shrinkExtent: 50,
                children: items),
          ),
        );
      },
    );
  }
}

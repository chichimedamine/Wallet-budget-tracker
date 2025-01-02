import 'package:flutter/material.dart';
import 'package:wallet_budget_tracker/components/backgroundcard.dart';
import 'package:wallet_budget_tracker/helper/colors.dart';
import 'package:wallet_budget_tracker/helper/fonts.dart';
import '../components/ListRecords.dart';

import '../components/home_carousel.dart';
import 'add_transaction.dart';

class Bodycard extends StatelessWidget {
  const Bodycard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 90),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome !",
                    style: FontsHelper.boldTextStyle(
                        fontSize: 30.0, color: ColorsHelper.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(
                      Icons.more_vert,
                      color: ColorsHelper.white,
                    ),
                  )
                ],
              ),
              Text(
                "Mohamed Amine",
                style: FontsHelper.mediumTextStyle(
                    fontSize: 20, color: ColorsHelper.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: ColorsHelper.green,
            child: const Icon(
              Icons.add,
              color: ColorsHelper.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen()),
              );
            },
          ),
          /* const SizedBox(
            height: 10,
          ),
          const AIBot(),*/
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackgroundCard(body: const Bodycard()),
              const Align(
                alignment: Alignment.bottomCenter,
                child: HomeCarousel(),
              ),
              const SizedBox(
                height: 100,
              ),
              const Listrecords(),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

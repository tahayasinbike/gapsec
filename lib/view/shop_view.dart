import 'package:flutter/material.dart';

import 'package:gapsec/utils/constants.dart';
import 'package:gapsec/widgets/main_menu_widget/token_counter.dart';
import 'package:gapsec/widgets/shop_view_widget/buy_token_container.dart';
import 'package:gapsec/widgets/shop_view_widget/watch_ad_button.dart';

class ShopView extends StatelessWidget {
  const ShopView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Shop', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple[800],
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                //amount of token
                const Text(
                  '10',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
                const SizedBox(
                  width: 6,
                ),
                //token icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.6),
                        spreadRadius: 4,
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Image.asset(
                    Constants.tokenImagePath,
                    height: 30,
                    width: 30,
                  ),
                )
              ],
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple[800]!, Colors.purple[200]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return BuyTokenContainer(
                    tokens: (index + 1) * 20,
                    price: priceFunc(index, 6),
                  );
                },
              ),
            ),
            const WatchAdButton(),
          ],
        ),
      ),
    );
  }
}

double priceFunc(int index, int itemCount) {
  double carpimKatsayisi = 1.0 - (index * 0.05);
  double price = carpimKatsayisi * (index + 1) * 5;
  return price;
}
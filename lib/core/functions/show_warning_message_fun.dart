import 'package:flutter/material.dart';
import 'package:tiktok/core/utils/naviagator_extention.dart';

Future<void> showWarningMessageFun(
    {required BuildContext context, required String text}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/warning.png',
            height: 120,
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => context.popView(),
            child: const Text(
              'Ok',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showWarningMessageFunction(
    {required BuildContext context,
    required String text,
    required Function onTapYes}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/warning.png',
            height: 80,
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => context.popView(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.popView();
                  onTapYes();
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Future<void> showWarningMessageFunction2(
    {required BuildContext context,
    required String text,
    required Function onTapYes}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => context.popView(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.popView();
                  onTapYes();
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

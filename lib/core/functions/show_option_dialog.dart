import 'package:flutter/material.dart';

Future showOptionDialog({required BuildContext context}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop('camera');
              },
              child: const ListTile(
                leading: Icon(
                  Icons.camera,
                ),
                title: Text('camera'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop('gallery');
              },
              child: const ListTile(
                leading: Icon(
                  Icons.photo,
                ),
                title: Text('gallery'),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop('cancel');
              },
              child: const ListTile(
                leading: Icon(
                  Icons.remove,
                ),
                title: Text('cancel'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

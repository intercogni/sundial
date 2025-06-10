import 'package:flutter/material.dart';

class SundialDivider extends StatelessWidget {
  final TimeOfDay time;
  final String label;

  const SundialDivider({Key? key, required this.time, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 32.0, right: 32.0, bottom: 8.0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white, thickness: 1.5)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '${time.hour.toString()}:${time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

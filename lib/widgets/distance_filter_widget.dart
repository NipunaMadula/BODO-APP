import 'package:flutter/material.dart';

class DistanceFilterWidget extends StatelessWidget {
  final double currentRadius;
  final Function(double) onRadiusChanged;

  const DistanceFilterWidget({
    required this.currentRadius,
    required this.onRadiusChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${currentRadius.round()} km',
                style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: currentRadius,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: Colors.lightBlueAccent,
            label: '${currentRadius.round()} km',
            onChanged: onRadiusChanged,
          ),
        ],
      ),
    );
  }
}
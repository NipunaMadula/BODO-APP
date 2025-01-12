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
    final size = MediaQuery.of(context).size;
    
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Radius',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.width * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Text(
                  '${currentRadius.round()} km',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.04,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.width * 0.02),
          SliderTheme(
            data: SliderThemeData(
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: size.width * 0.03,
              ),
            ),
            child: Slider(
              value: currentRadius,
              min: 1,
              max: 50,
              divisions: 49,
              activeColor: Colors.blue,
              label: '${currentRadius.round()} km',
              onChanged: onRadiusChanged,
            ),
          ),
        ],
      ),
    );
  }
}
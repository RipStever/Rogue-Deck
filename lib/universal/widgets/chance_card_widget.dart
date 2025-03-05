import 'package:flutter/material.dart';
import '../models/chance_card_data.dart';

class ChanceCardWidget extends StatelessWidget {
  final ChanceCardData cardData;
  final bool isHovered;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  const ChanceCardWidget({
    super.key,
    required this.cardData,
    required this.isHovered,
    required this.isSelected,
    required this.onTap,
    this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.black, width: 2),
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.0),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: _getHeaderColor(cardData.type),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      cardData.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        fontFamily: 'RobotoMono',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Body
                  Expanded(
                    child: Container(
                      color: Colors.black, // Set body background color to black
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Text(
                          cardData.effect,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white, // Set text color to white
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Footer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Chance',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Determine the header color based on card type
  Color _getHeaderColor(String type) {
    switch (type) {
      case 'Blunder':
        return Colors.black;
      case 'Miss':
        return Colors.red;
      case 'Partial Hit':
        return Colors.lightBlue;
      case 'Hit':
        return Colors.green;
      case 'Hit+':
        return Colors.purpleAccent;
      case 'Crit':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

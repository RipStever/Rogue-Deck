import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for input formatters
import '../playarea/max_hand_size_control.dart';

class StatsAreaWidget extends StatefulWidget {
  final int maxHandSize;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const StatsAreaWidget({
    super.key,
    required this.maxHandSize,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  _StatsAreaWidgetState createState() => _StatsAreaWidgetState();
}





class _StatsAreaWidgetState extends State<StatsAreaWidget> {
  int maxHP = 180; // Default Max HP
  int currentHP = 180; // Starts at Max HP
  int overhealth = 0; // Additional temporary HP
  bool autoApplyArmor = false; // Checkbox state

  String _selectedArmor = 'None'; // Default armor type
  int breakpoint = 180; // Default breakpoint, matching maxHP

  final TextEditingController _damageController = TextEditingController();
  final TextEditingController _overhealthController = TextEditingController();

    void _updateBreakpoint() {
    setState(() {
      switch (_selectedArmor) {
        case 'None':
          breakpoint = maxHP; // 100% of max HP
          break;
        case 'Light':
          breakpoint = (maxHP * 0.9).ceil(); // 90% of max HP
          break;
        case 'Medium':
          breakpoint = (maxHP * 0.8).ceil(); // 80% of max HP
          break;
        case 'Heavy':
          breakpoint = (maxHP * 0.7).ceil(); // 70% of max HP
          break;
        default:
          breakpoint = maxHP;
      }
    });
  }


  void _applyDamage() {
    final String input = _damageController.text.trim();
    if (input.isEmpty || !RegExp(r'^-?\d+$').hasMatch(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number for damage/healing.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      int appliedDamage = int.parse(input);

      if (appliedDamage > 0) {
        // Apply armor reduction only if the value is positive
        if (autoApplyArmor) {
          appliedDamage = (appliedDamage / 2).ceil();
        }

        if (overhealth > 0) {
          // Apply damage to Overhealth first
          if (appliedDamage <= overhealth) {
            overhealth -= appliedDamage;
            appliedDamage = 0;
          } else {
            appliedDamage -= overhealth;
            overhealth = 0;
          }
        }

        // Apply remaining positive damage to current HP
        currentHP -= appliedDamage;
      } else {
        // Apply negative values (healing) directly to current HP
        currentHP += appliedDamage.abs();
      }

      // Cap Current HP at Max HP
      if (currentHP > maxHP) currentHP = maxHP;

      // Update the Overhealth TextBox
      _overhealthController.text = overhealth.toString();

      _damageController.clear();
    });
  }


  Color _getCurrentHPColor() {
    double percentage = currentHP / maxHP;

    if (percentage > 0.8) {
      return Colors.green[400]!; // Light green
    } else if (percentage > 0.5) {
      return const Color.fromARGB(255, 206, 169, 4); // Yellow
    } else if (percentage > 0.25) {
      return Colors.pink[300]!; // Pink
    } else if (percentage > 0) {
      return Colors.red[700]!; // Red
    } else {
      return Colors.black; // Black when <= 0
    }
  }

 void _showSetMaxHPDialog() {
  final TextEditingController maxHPController =
      TextEditingController(text: maxHP.toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Set Max HP'),
        content: TextField(
          controller: maxHPController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Enter new max HP',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = maxHPController.text.trim();
              if (input.isEmpty || int.tryParse(input) == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }

              setState(() {
                maxHP = int.parse(input);
                if (currentHP > maxHP) {
                  currentHP = maxHP;
                }
                _updateBreakpoint(); // Recalculate breakpoint when max HP changes
              });

              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    // A slightly off-white background to distinguish from pure white
    return Container(
      width: 350, // Optionally widen it a bit
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1) Max Hand Size Section
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: MaxHandSizeWidget(
                maxHandSize: widget.maxHandSize,
                onIncrement: widget.onIncrement,
                onDecrement: widget.onDecrement,
              ),
            ),
          ),
          const SizedBox(height: 10),

          /// 2) Character Stats
          /// Character Stats Section
          /// Row to position Hit Points and Speed cards side by side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Hit Points Card
              SizedBox(
                width: 175, // Adjust the width as desired
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hit Points',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        /// Max HP Display
                        GestureDetector(
                          onTap: _showSetMaxHPDialog, // Open dialog on tap
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Max HP: $maxHP',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Current HP Display
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getCurrentHPColor(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Current HP: $currentHP',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Breakpoint Display
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: currentHP < breakpoint ? Colors.black : Colors.blue[700],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Breakpoint: $breakpoint',
                            style: TextStyle(
                              fontSize: 16,
                              color: currentHP < breakpoint ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Spacing between Hit Points and Speed cards

              /// Speed Card
              SizedBox(
                width: 80, // Adjust the width as desired
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Speed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                      /// Speed Display
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Adjust the background color as needed
                            borderRadius: BorderRadius.circular(5), // Rounded corners
                            border: Border.all( // Black border
                              color: Colors.black,
                              width: 1, // Border thickness
                            ),
                          ),
                          child: const Text(
                            '5m',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),



          /// 3) Armor, Overhealth, and Record Damage
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Armor Card
                Expanded(
                  flex: 2, // Adjust flex value to occupy more space
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: const Color.fromARGB(255, 207, 207, 207),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Armor',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Reduces all incoming damage by 50%.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: (currentHP < breakpoint && overhealth <= 0)
                                    ? false // Reset to false when disabled
                                    : autoApplyArmor,
                                onChanged: (currentHP < breakpoint && overhealth <= 0)
                                    ? null // Disable the checkbox if conditions are met
                                    : (value) {
                                        setState(() {
                                          autoApplyArmor = value ?? false;
                                        });
                                      },
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  'Apply armor',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: (currentHP < breakpoint && overhealth <= 0)
                                        ? Colors.grey // Make text grey if checkbox is disabled
                                        : Colors.black,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Armor Mechanics'),
                                        content: const Text(
                                          'Armor reduces all incoming damage by 50%. '
                                          'When this checkbox is selected, the reduction is automatically applied when recording damage.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Got it'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16), // Add spacing between "Apply Armor" and dropdown
                          
                          /// Armor Type Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedArmor,
                            items: const [
                              DropdownMenuItem(
                                value: 'None',
                                child: Text(
                                  'None',
                                  style: TextStyle(fontSize: 12), // Set the font size here
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Light',
                                child: Text(
                                  'Light',
                                  style: TextStyle(fontSize: 12), // Set the font size here
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text(
                                  'Medium',
                                  style: TextStyle(fontSize: 12), // Set the font size here
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Heavy',
                                child: Text(
                                  'Heavy',
                                  style: TextStyle(fontSize: 12), // Set the font size here
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedArmor = value ?? 'None';
                                _updateBreakpoint(); // Update breakpoint when armor type changes
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Armor Type',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 10),

              /// Overhealth & Record Damage stacked
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    /// Overhealth Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overhealth',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _overhealthController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^-?\d*'),
                                )
                              ],
                              onChanged: (value) {
                                setState(() {
                                  overhealth = int.tryParse(value) ?? 0;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: '',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    

                    /// Record Damage Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Record Damage',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _damageController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^-?\d*'),
                                      )
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: '',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _applyDamage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[800],
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// 4) Surge Charge & Counter
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  /// Surge Charge
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: 0,
                      items: List.generate(6, (index) => index)
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              ))
                          .toList(),
                      onChanged: (value) {},
                      decoration: const InputDecoration(
                        labelText: 'Surge Charge',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// Counter
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: 0,
                      items: List.generate(11, (index) => index)
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              ))
                          .toList(),
                      onChanged: (value) {},
                      decoration: const InputDecoration(
                        labelText: 'Counter',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


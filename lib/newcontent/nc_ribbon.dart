// lib/newcontent/NC_Ribbon.dart
import 'package:flutter/material.dart';
import 'package:card_game/newcontent/nc_screen.dart';
import 'package:card_game/newcontent/talents/nc_talentlistcolumn.dart';
import 'package:card_game/newcontent/talents/nc_talentdetailscolumn.dart';

class NewContentRibbon extends StatelessWidget {
  final void Function(Widget) setActiveWidget;

  const NewContentRibbon({
    super.key,
    required this.setActiveWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Container(
            color: const Color.fromARGB(255, 197, 197, 197),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildNavButtons(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavButtons(BuildContext context) {
    final navItems = [
      {
        'icon': Icons.auto_awesome,
        'label': 'Feats',
        'color': const Color.fromARGB(255, 75, 44, 156),
        'textColor': Colors.white,
        'onTap': () {
          setActiveWidget(
            const FeatManagementScreen(), // Use the public class
          );
        },
      },
      {
        'icon': Icons.star,
        'label': 'Talents',
        'color': const Color.fromARGB(255, 44, 156, 75),
        'textColor': Colors.white,
        'onTap': () {
          setActiveWidget(
            const TalentManagementScreen(), // Use the public class
          );
        },
      },
      {
        'icon': Icons.shield,
        'label': 'Weapons',
        'color': Colors.grey,
        'textColor': Colors.white,
        'onTap': () {
          setActiveWidget(
            const WeaponManagementScreen(), // Use the public class
          );
        },
      },
    ];

    return navItems.map((item) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        color: item['color'] as Color,
        child: ListTile(
          leading: Icon(
            item['icon'] as IconData,
            color: item['textColor'] as Color,
          ),
          title: Text(
            item['label'] as String,
            style: TextStyle(
              color: item['textColor'] as Color,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: item['onTap'] as VoidCallback?,
        ),
      );
    }).toList();
  }
}

// Add this new widget to manage the talent interface state
class TalentManagementScreen extends StatefulWidget {
  const TalentManagementScreen({super.key});

  @override
  _TalentManagementScreenState createState() => _TalentManagementScreenState();
}

class _TalentManagementScreenState extends State<TalentManagementScreen> {
  String selectedTalentName = '';
  final GlobalKey<TalentListColumnState> _talentsListKey = GlobalKey<TalentListColumnState>();

  void onTalentSelected(String talentName) {
    setState(() {
      selectedTalentName = talentName;
    });
  }

  void _refreshTalentList() {
    _talentsListKey.currentState?.refreshTalents();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Talent List Column
        Expanded(
          flex: 2, // Keeps the list column size consistent
          child: TalentListColumn(
            key: _talentsListKey,
            onTalentSelected: onTalentSelected,
          ),
        ),

        // Talent Details Column (fills remaining space)
        Expanded(
          flex: 3, // Allocates more space for TalentDetailsColumn
          child: TalentDetailsColumn(
            selectedTalentName: selectedTalentName,
            onTalentListRefresh: _refreshTalentList,
          ),
        ),

        // Blank Column
        Expanded(
          flex: 3, // Adjust flex as needed for the blank column
          child: Container(
            color: Colors.grey.shade200, // Optional: Background color for visibility
          ),
        ),
      ],
    );
  }
}
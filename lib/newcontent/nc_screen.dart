import 'package:flutter/material.dart';
import 'package:card_game/newcontent/nc_ribbon.dart';
import 'package:card_game/newcontent/feats/nc_featslistcolumn.dart';
import 'package:card_game/newcontent/feats/nc_featdetailscolumn.dart';
import 'package:card_game/newcontent/talents/nc_talentlistcolumn.dart';
import 'package:card_game/newcontent/talents/nc_talentdetailscolumn.dart';
import 'package:card_game/newcontent/weapons/nc_weaponslistcolumn.dart'; // Import Weapons
import 'package:card_game/newcontent/weapons/nc_weapondetailscolumn.dart'; // Import Weapons

class NewContentScreen extends StatefulWidget {
  const NewContentScreen({super.key});

  @override
  _NewContentScreenState createState() => _NewContentScreenState();
}

class _NewContentScreenState extends State<NewContentScreen> {
  Widget? _activeWidget;

  void setActiveWidget(Widget widget) {
    setState(() {
      _activeWidget = widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Content'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Ribbon
          Container(
            width: 250,
            color: Colors.grey.shade200,
            child: NewContentRibbon(
              setActiveWidget: setActiveWidget,
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: _activeWidget ??
                  const Center(
                    child: Text('Select an option from the menu to begin'),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget to manage Feats
class FeatManagementScreen extends StatefulWidget {
  const FeatManagementScreen({super.key});

  @override
  FeatManagementScreenState createState() => FeatManagementScreenState();
}

class FeatManagementScreenState extends State<FeatManagementScreen> {
  String selectedFeatName = '';
  final GlobalKey<FeatsListColumnState> _featsListKey = GlobalKey<FeatsListColumnState>();

  void onFeatSelected(String featName) {
    setState(() {
      selectedFeatName = featName;
    });
  }

  void _refreshFeatList() {
    _featsListKey.currentState?.refreshFeats();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: FeatsListColumn(
            key: _featsListKey,
            onFeatSelected: onFeatSelected,
          ),
        ),
        Expanded(
          flex: 4,
          child: FeatDetailsColumn(
            selectedFeatName: selectedFeatName,
            onFeatListRefresh: _refreshFeatList,
          ),
        ),
      ],
    );
  }
}

// Widget to manage Talents
class TalentManagementScreen extends StatefulWidget {
  const TalentManagementScreen({super.key});

  @override
  TalentManagementScreenState createState() => TalentManagementScreenState();
}

class TalentManagementScreenState extends State<TalentManagementScreen> {
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
        Expanded(
          flex: 1,
          child: TalentListColumn(
            key: _talentsListKey,
            onTalentSelected: onTalentSelected,
          ),
        ),
        Expanded(
          flex: 4,
          child: TalentDetailsColumn(
            selectedTalentName: selectedTalentName,
            onTalentListRefresh: _refreshTalentList,
          ),
        ),
      ],
    );
  }
}

// Widget to manage Weapons
class WeaponManagementScreen extends StatefulWidget {
  const WeaponManagementScreen({super.key});

  @override
  WeaponManagementScreenState createState() => WeaponManagementScreenState();
}

class WeaponManagementScreenState extends State<WeaponManagementScreen> {
  String selectedWeaponName = '';
  final GlobalKey<WeaponsListColumnState> _weaponsListKey = GlobalKey<WeaponsListColumnState>();

  void onWeaponSelected(String weaponName) {
    setState(() {
      selectedWeaponName = weaponName;
    });
  }

  void _refreshWeaponList() {
    _weaponsListKey.currentState?.refreshWeapons();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: WeaponsListColumn(
            key: _weaponsListKey,
            onWeaponSelected: onWeaponSelected,
          ),
        ),
        Expanded(
          flex: 4,
          child: WeaponsDetailsColumn(
            selectedWeaponName: selectedWeaponName,
            onWeaponListRefresh: _refreshWeaponList,
          ),
        ),
      ],
    );
  }
}
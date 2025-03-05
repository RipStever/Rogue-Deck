import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'universal/welcome_screen.dart';
import 'universal/cardtext/keyword_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the keyword service
  await KeywordService().initialize();
  
  runApp(
    const ProviderScope(
      child: CardGameApp(),
    ),
  );
}

class CardGameApp extends StatelessWidget {
  const CardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rogue Deck',
      debugShowCheckedModeBanner: false, // Remove debug banner for web
      theme: ThemeData(
        // Base theme settings
        primarySwatch: Colors.blue,
        
        // Card theme for feat cards
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // Chip theme for tags and filters
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade100,
          selectedColor: Colors.blue.shade100,
          secondarySelectedColor: Colors.blue.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          labelStyle: TextStyle(color: Colors.grey.shade800),
          secondaryLabelStyle: const TextStyle(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Input decoration theme for search fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),

        // Checkbox theme for feat selection
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(color: Colors.grey.shade400),
        ),

        // Icon theme for various icons
        iconTheme: IconThemeData(
          color: Colors.grey.shade600,
          size: 24,
        ),

        // Text theme for consistent typography
        textTheme: TextTheme(
          // Feat titles
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
          // Feat descriptions
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
          // Tags and labels
          labelMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),

        // Colors for type-based styling
        extensions: <ThemeExtension<dynamic>>[
          CustomColors(
            attackColor: Colors.red.shade800.withOpacity(0.8),
            movementColor: Colors.green.shade800.withOpacity(0.8),
            specialColor: Colors.purple.shade800.withOpacity(0.8),
            selectedColor: Colors.green.shade700,
            wishlistColor: Colors.blue.shade600,
          ),
        ],
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Custom colors extension for feat types
class CustomColors extends ThemeExtension<CustomColors> {
  final Color attackColor;
  final Color movementColor;
  final Color specialColor;
  final Color selectedColor;
  final Color wishlistColor;

  CustomColors({
    required this.attackColor,
    required this.movementColor,
    required this.specialColor,
    required this.selectedColor,
    required this.wishlistColor,
  });

  @override
  ThemeExtension<CustomColors> copyWith({
    Color? attackColor,
    Color? movementColor,
    Color? specialColor,
    Color? selectedColor,
    Color? wishlistColor,
  }) {
    return CustomColors(
      attackColor: attackColor ?? this.attackColor,
      movementColor: movementColor ?? this.movementColor,
      specialColor: specialColor ?? this.specialColor,
      selectedColor: selectedColor ?? this.selectedColor,
      wishlistColor: wishlistColor ?? this.wishlistColor,
    );
  }

  @override
  ThemeExtension<CustomColors> lerp(
    ThemeExtension<CustomColors>? other,
    double t,
  ) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      attackColor: Color.lerp(attackColor, other.attackColor, t)!,
      movementColor: Color.lerp(movementColor, other.movementColor, t)!,
      specialColor: Color.lerp(specialColor, other.specialColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      wishlistColor: Color.lerp(wishlistColor, other.wishlistColor, t)!,
    );
  }
}
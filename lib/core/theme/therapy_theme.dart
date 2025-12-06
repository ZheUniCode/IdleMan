// ============================================================================
// IDLEMAN v16.0 - THERAPY THEME
// ============================================================================
// File: lib/core/theme/therapy_theme.dart
// Purpose: Defines the "Therapy Paper" visual identity system
// Philosophy: Calm, tactile, non-aggressive - like a wellness journal
// ============================================================================

// Import Flutter's material design library for theme components
import 'package:flutter/material.dart';

// Import Google Fonts for Playfair Display (Serif) and Nunito (Sans)
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// THERAPY COLORS
// ============================================================================
// The "Calm" color palette - designed to lower cortisol levels
// Mimics high-end cardstock and fountain pen ink
// ============================================================================
class TherapyColors {
  // -------------------------------------------------------------------------
  // Private constructor to prevent instantiation
  // This class is a namespace for static color constants only
  // -------------------------------------------------------------------------
  TherapyColors._();

  // -------------------------------------------------------------------------
  // CANVAS (Background) - Warm Cream/Paper
  // Usage: Main scaffold background
  // Metaphor: Warm, unbleached paper from a wellness journal
  // Hex: #F7F5F2
  // -------------------------------------------------------------------------
  static const Color canvas = Color(0xFFF7F5F2);

  // -------------------------------------------------------------------------
  // SURFACE (Cards/Modals) - Pure White
  // Usage: Interactive elements, cards, modals, sheets
  // Metaphor: Fresh paper cardstock floating above the canvas
  // Hex: #FFFFFF
  // -------------------------------------------------------------------------
  static const Color surface = Color(0xFFFFFFFF);

  // -------------------------------------------------------------------------
  // INK (Primary Text) - Soft Charcoal
  // Usage: H1, H2, Body text
  // Metaphor: Fountain pen ink - NEVER use pure black (#000000)
  // Hex: #2D3436
  // -------------------------------------------------------------------------
  static const Color ink = Color(0xFF2D3436);

  // -------------------------------------------------------------------------
  // GRAPHITE (Secondary Text) - Slate Grey
  // Usage: Metadata, subtitles, timestamps, hints
  // Metaphor: Pencil markings, less prominent than ink
  // Hex: #636E72
  // -------------------------------------------------------------------------
  static const Color graphite = Color(0xFF636E72);

  // -------------------------------------------------------------------------
  // BOUNDARY (Accent - Negative) - Muted Terra Cotta
  // Usage: Timers, blocks, boundaries, warnings
  // Metaphor: Correction pen - signals "stop" but warmly
  // Hex: #E76F51
  // -------------------------------------------------------------------------
  static const Color boundary = Color(0xFFE76F51);

  // -------------------------------------------------------------------------
  // GROWTH (Accent - Positive) - Sage Green
  // Usage: Success states, streaks, the Garden, progress
  // Metaphor: Nature, growth, life - calming and encouraging
  // Hex: #84A98C
  // -------------------------------------------------------------------------
  static const Color growth = Color(0xFF84A98C);

  // -------------------------------------------------------------------------
  // SHADOW COLOR - Very Light Black (5% opacity)
  // Usage: Diffused ambient shadows for cards
  // Metaphor: Subtle elevation, paper floating above surface
  // Hex: #0D000000 (Black at 5% opacity)
  // -------------------------------------------------------------------------
  static const Color shadow = Color(0x0D000000);

  // -------------------------------------------------------------------------
  // DEBUG METHOD: Log all colors on initialization
  // Used to verify correct color values during development
  // -------------------------------------------------------------------------
  static void debugLogColors() {
    // Log entry into the debug method
    debugPrint('[TherapyColors::debugLogColors] Started.');
    
    // Log each color value for verification
    debugPrint('[TherapyColors::debugLogColors] Canvas: $canvas');
    debugPrint('[TherapyColors::debugLogColors] Surface: $surface');
    debugPrint('[TherapyColors::debugLogColors] Ink: $ink');
    debugPrint('[TherapyColors::debugLogColors] Graphite: $graphite');
    debugPrint('[TherapyColors::debugLogColors] Boundary: $boundary');
    debugPrint('[TherapyColors::debugLogColors] Growth: $growth');
    debugPrint('[TherapyColors::debugLogColors] Shadow: $shadow');
    
    // Log exit from the debug method
    debugPrint('[TherapyColors::debugLogColors] Completed.');
  }
}

// ============================================================================
// THERAPY TEXT STYLES
// ============================================================================
// Typography system using Playfair Display (Serif) for authority
// and Nunito (Rounded Sans) for approachability
// ============================================================================
class TherapyText {
  // -------------------------------------------------------------------------
  // Private constructor to prevent instantiation
  // This class is a namespace for static text style constants only
  // -------------------------------------------------------------------------
  TherapyText._();

  // -------------------------------------------------------------------------
  // HEADING 1 - Large Serif (Playfair Display)
  // Usage: Main screen titles, therapeutic messaging
  // Rationale: Serif fonts imply history, authority, medical/therapeutic feel
  // -------------------------------------------------------------------------
  static TextStyle heading1() {
    // Log entry into the method
    debugPrint('[TherapyText::heading1] Creating H1 text style.');
    
    // Create the text style using Google Fonts Playfair Display
    final style = GoogleFonts.playfairDisplay(
      // Set font size to 32 logical pixels
      fontSize: 32,
      // Use bold weight for emphasis
      fontWeight: FontWeight.w700,
      // Use Ink color (Soft Charcoal) for the text
      color: TherapyColors.ink,
      // Set letter spacing slightly tighter for elegance
      letterSpacing: -0.5,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::heading1] H1 style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // HEADING 2 - Medium Serif (Playfair Display)
  // Usage: Section headers, card titles
  // Rationale: Maintains authority while being less prominent than H1
  // -------------------------------------------------------------------------
  static TextStyle heading2() {
    // Log entry into the method
    debugPrint('[TherapyText::heading2] Creating H2 text style.');
    
    // Create the text style using Google Fonts Playfair Display
    final style = GoogleFonts.playfairDisplay(
      // Set font size to 24 logical pixels
      fontSize: 24,
      // Use semi-bold weight
      fontWeight: FontWeight.w600,
      // Use Ink color (Soft Charcoal) for the text
      color: TherapyColors.ink,
      // Set letter spacing slightly tighter
      letterSpacing: -0.3,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::heading2] H2 style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // HEADING 3 - Small Serif (Playfair Display)
  // Usage: Sub-section headers, list item titles
  // Rationale: Smallest serif heading, still maintains authority
  // -------------------------------------------------------------------------
  static TextStyle heading3() {
    // Log entry into the method
    debugPrint('[TherapyText::heading3] Creating H3 text style.');
    
    // Create the text style using Google Fonts Playfair Display
    final style = GoogleFonts.playfairDisplay(
      // Set font size to 18 logical pixels
      fontSize: 18,
      // Use medium weight
      fontWeight: FontWeight.w500,
      // Use Ink color (Soft Charcoal) for the text
      color: TherapyColors.ink,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::heading3] H3 style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // BODY - Rounded Sans (Nunito)
  // Usage: Main content text, paragraphs, descriptions
  // Rationale: Highly legible and friendly, rounded terminals reduce aggression
  // -------------------------------------------------------------------------
  static TextStyle body() {
    // Log entry into the method
    debugPrint('[TherapyText::body] Creating body text style.');
    
    // Create the text style using Google Fonts Nunito
    final style = GoogleFonts.nunito(
      // Set font size to 16 logical pixels
      fontSize: 16,
      // Use regular weight
      fontWeight: FontWeight.w400,
      // Use Ink color (Soft Charcoal) for the text
      color: TherapyColors.ink,
      // Set line height to 1.5 for comfortable reading
      height: 1.5,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::body] Body style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // BODY BOLD - Rounded Sans Bold (Nunito)
  // Usage: Emphasized body text, important information
  // Rationale: Same friendliness as body but with emphasis
  // -------------------------------------------------------------------------
  static TextStyle bodyBold() {
    // Log entry into the method
    debugPrint('[TherapyText::bodyBold] Creating body bold text style.');
    
    // Create the text style using Google Fonts Nunito
    final style = GoogleFonts.nunito(
      // Set font size to 16 logical pixels
      fontSize: 16,
      // Use bold weight for emphasis
      fontWeight: FontWeight.w700,
      // Use Ink color (Soft Charcoal) for the text
      color: TherapyColors.ink,
      // Set line height to 1.5 for comfortable reading
      height: 1.5,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::bodyBold] Body bold style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // CAPTION - Small Rounded Sans (Nunito)
  // Usage: Metadata, timestamps, hints, helper text
  // Rationale: Smaller and lighter for secondary information
  // -------------------------------------------------------------------------
  static TextStyle caption() {
    // Log entry into the method
    debugPrint('[TherapyText::caption] Creating caption text style.');
    
    // Create the text style using Google Fonts Nunito
    final style = GoogleFonts.nunito(
      // Set font size to 14 logical pixels
      fontSize: 14,
      // Use regular weight
      fontWeight: FontWeight.w400,
      // Use Graphite color (Slate Grey) for secondary text
      color: TherapyColors.graphite,
      // Set line height to 1.4
      height: 1.4,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::caption] Caption style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // CAPTION BOLD - Small Rounded Sans Bold (Nunito)
  // Usage: Emphasized metadata, small headers
  // -------------------------------------------------------------------------
  static TextStyle captionBold() {
    debugPrint('[TherapyText::captionBold] Creating caption bold text style.');
    return GoogleFonts.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: TherapyColors.ink,
      height: 1.4,
    );
  }

  // -------------------------------------------------------------------------
  // BUTTON - Medium Rounded Sans (Nunito)
  // Usage: Button labels, call-to-action text
  // Rationale: Clear, readable, friendly button text
  // -------------------------------------------------------------------------
  static TextStyle button() {
    // Log entry into the method
    debugPrint('[TherapyText::button] Creating button text style.');
    
    // Create the text style using Google Fonts Nunito
    final style = GoogleFonts.nunito(
      // Set font size to 16 logical pixels
      fontSize: 16,
      // Use semi-bold weight for buttons
      fontWeight: FontWeight.w600,
      // Use Ink color (Soft Charcoal) for the text
      color: TherapyColors.ink,
      // Set letter spacing slightly wider for readability
      letterSpacing: 0.5,
    );
    
    // Log exit from the method
    debugPrint('[TherapyText::button] Button style created successfully.');
    
    // Return the constructed text style
    return style;
  }

  // -------------------------------------------------------------------------
  // DEBUG METHOD: Log all text styles on initialization
  // Used to verify correct text style configuration during development
  // -------------------------------------------------------------------------
  static void debugLogTextStyles() {
    // Log entry into the debug method
    debugPrint('[TherapyText::debugLogTextStyles] Started.');
    
    // Log that we're creating each style for verification
    debugPrint('[TherapyText::debugLogTextStyles] Verifying heading1...');
    heading1();
    debugPrint('[TherapyText::debugLogTextStyles] Verifying heading2...');
    heading2();
    debugPrint('[TherapyText::debugLogTextStyles] Verifying heading3...');
    heading3();
    debugPrint('[TherapyText::debugLogTextStyles] Verifying body...');
    body();
    debugPrint('[TherapyText::debugLogTextStyles] Verifying bodyBold...');
    bodyBold();
    debugPrint('[TherapyText::debugLogTextStyles] Verifying caption...');
    caption();
    debugPrint('[TherapyText::debugLogTextStyles] Verifying button...');
    button();
    
    // Log exit from the debug method
    debugPrint('[TherapyText::debugLogTextStyles] All text styles verified.');
  }
}

// ============================================================================
// THERAPY SHADOWS
// ============================================================================
// Soft, diffused shadows that make elements feel like floating paper
// No hard drop shadows - only ambient occlusion
// ============================================================================
class TherapyShadows {
  // -------------------------------------------------------------------------
  // Private constructor to prevent instantiation
  // This class is a namespace for static shadow constants only
  // -------------------------------------------------------------------------
  TherapyShadows._();

  // -------------------------------------------------------------------------
  // CARD SHADOW - Diffused ambient shadow for cards
  // Usage: All card-like components (CardContainer, Modals, Sheets)
  // Physics: blurRadius: 16, offset: (0, 4) - subtle lift effect
  // -------------------------------------------------------------------------
  static List<BoxShadow> card() {
    // Log entry into the method
    debugPrint('[TherapyShadows::card] Creating card shadow.');
    
    // Create the shadow list with a single diffused shadow
    final shadows = [
      BoxShadow(
        // Use the shadow color (5% black opacity)
        color: TherapyColors.shadow,
        // Set blur radius to 16 for soft diffusion
        blurRadius: 16,
        // Offset slightly downward (4 pixels) for lift effect
        offset: const Offset(0, 4),
        // Spread radius is 0 to prevent shadow from extending beyond blur
        spreadRadius: 0,
      ),
    ];
    
    // Log exit from the method
    debugPrint('[TherapyShadows::card] Card shadow created successfully.');
    
    // Return the shadow list
    return shadows;
  }

  // -------------------------------------------------------------------------
  // ELEVATED SHADOW - Slightly stronger shadow for floating elements
  // Usage: FABs, elevated buttons, modal dialogs
  // Physics: blurRadius: 24, offset: (0, 8) - more pronounced lift
  // -------------------------------------------------------------------------
  static List<BoxShadow> elevated() {
    // Log entry into the method
    debugPrint('[TherapyShadows::elevated] Creating elevated shadow.');
    
    // Create the shadow list with a stronger diffused shadow
    final shadows = [
      BoxShadow(
        // Use slightly more opaque shadow (8% black opacity)
        color: const Color(0x14000000),
        // Set blur radius to 24 for softer, wider diffusion
        blurRadius: 24,
        // Offset more downward (8 pixels) for higher lift effect
        offset: const Offset(0, 8),
        // Spread radius is 0
        spreadRadius: 0,
      ),
    ];
    
    // Log exit from the method
    debugPrint('[TherapyShadows::elevated] Elevated shadow created successfully.');
    
    // Return the shadow list
    return shadows;
  }
}

// ============================================================================
// THERAPY SHAPES
// ============================================================================
// Rounded shapes that feel tactile and approachable
// Cards use 24px radius, Buttons use 100px (pill shape)
// ============================================================================
class TherapyShapes {
  // -------------------------------------------------------------------------
  // Private constructor to prevent instantiation
  // This class is a namespace for static shape constants only
  // -------------------------------------------------------------------------
  TherapyShapes._();

  // -------------------------------------------------------------------------
  // CARD RADIUS - 24px rounded corners for cards
  // Usage: All card-like components
  // Rationale: Soft, tactile corners that feel like rounded paper
  // -------------------------------------------------------------------------
  static const double cardRadius = 24.0;

  // -------------------------------------------------------------------------
  // BUTTON RADIUS - 100px for pill-shaped buttons
  // Usage: Primary and secondary buttons
  // Rationale: Fully rounded ends create friendly, approachable buttons
  // -------------------------------------------------------------------------
  static const double buttonRadius = 100.0;

  // -------------------------------------------------------------------------
  // SMALL RADIUS - 12px for smaller components
  // Usage: Chips, tags, small cards
  // Rationale: Proportionally rounded for smaller elements
  // -------------------------------------------------------------------------
  static const double smallRadius = 12.0;

  // -------------------------------------------------------------------------
  // CARD BORDER RADIUS - Pre-built BorderRadius for cards
  // Usage: Container decorations, Card widgets
  // -------------------------------------------------------------------------
  static BorderRadius cardBorderRadius() {
    // Log entry into the method
    debugPrint('[TherapyShapes::cardBorderRadius] Creating card border radius.');
    
    // Create border radius with card radius value
    final radius = BorderRadius.circular(cardRadius);
    
    // Log exit from the method
    debugPrint('[TherapyShapes::cardBorderRadius] Card border radius created: $cardRadius');
    
    // Return the border radius
    return radius;
  }

  // -------------------------------------------------------------------------
  // BUTTON BORDER RADIUS - Pre-built BorderRadius for buttons
  // Usage: ElevatedButton, OutlinedButton decorations
  // -------------------------------------------------------------------------
  static BorderRadius buttonBorderRadius() {
    // Log entry into the method
    debugPrint('[TherapyShapes::buttonBorderRadius] Creating button border radius.');
    
    // Create border radius with button radius value (pill shape)
    final radius = BorderRadius.circular(buttonRadius);
    
    // Log exit from the method
    debugPrint('[TherapyShapes::buttonBorderRadius] Button border radius created: $buttonRadius');
    
    // Return the border radius
    return radius;
  }

  // -------------------------------------------------------------------------
  // CARD SHAPE - Pre-built RoundedRectangleBorder for cards
  // Usage: Card widgets, Material widgets
  // -------------------------------------------------------------------------
  static RoundedRectangleBorder cardShape() {
    // Log entry into the method
    debugPrint('[TherapyShapes::cardShape] Creating card shape.');
    
    // Create rounded rectangle border with card radius
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadius),
    );
    
    // Log exit from the method
    debugPrint('[TherapyShapes::cardShape] Card shape created successfully.');
    
    // Return the shape
    return shape;
  }

  // -------------------------------------------------------------------------
  // BUTTON SHAPE - Pre-built RoundedRectangleBorder for buttons
  // Usage: ElevatedButton, OutlinedButton shape property
  // -------------------------------------------------------------------------
  static RoundedRectangleBorder buttonShape() {
    // Log entry into the method
    debugPrint('[TherapyShapes::buttonShape] Creating button shape.');
    
    // Create rounded rectangle border with button radius (pill)
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonRadius),
    );
    
    // Log exit from the method
    debugPrint('[TherapyShapes::buttonShape] Button shape created successfully.');
    
    // Return the shape
    return shape;
  }
}

// ============================================================================
// THERAPY THEME DATA
// ============================================================================
// Complete ThemeData object that combines all Therapy Paper elements
// Use this in MaterialApp's theme property
// ============================================================================
class TherapyTheme {
  // -------------------------------------------------------------------------
  // Private constructor to prevent instantiation
  // This class is a namespace for the static theme getter
  // -------------------------------------------------------------------------
  TherapyTheme._();

  // -------------------------------------------------------------------------
  // GET THEME - Returns the complete Therapy Paper ThemeData
  // Usage: MaterialApp(theme: TherapyTheme.theme)
  // -------------------------------------------------------------------------
  static ThemeData get theme {
    // Log entry into the method
    debugPrint('[TherapyTheme::theme] Building Therapy Paper theme...');
    
    // Log that we're constructing the ThemeData
    debugPrint('[TherapyTheme::theme] Setting scaffold background to Canvas color.');
    
    // Build and return the complete ThemeData
    final themeData = ThemeData(
      // Set the overall brightness to light (Therapy Paper is light-themed)
      brightness: Brightness.light,
      
      // Use Material 3 design system
      useMaterial3: true,
      
      // Set the scaffold background to Canvas (Warm Cream)
      scaffoldBackgroundColor: TherapyColors.canvas,
      
      // Set the primary color to Growth (Sage Green)
      primaryColor: TherapyColors.growth,
      
      // Configure the color scheme
      colorScheme: const ColorScheme.light(
        // Primary is Growth (Sage Green)
        primary: TherapyColors.growth,
        // Secondary is Boundary (Terra Cotta)
        secondary: TherapyColors.boundary,
        // Surface is pure white
        surface: TherapyColors.surface,
        // Background is Canvas (Warm Cream)
        // ignore: deprecated_member_use
        background: TherapyColors.canvas,
        // Error color uses Boundary (Terra Cotta) - NOT aggressive red
        error: TherapyColors.boundary,
        // On-surface text uses Ink (Soft Charcoal)
        onSurface: TherapyColors.ink,
        // On-primary text uses Surface (White)
        onPrimary: TherapyColors.surface,
        // On-secondary text uses Surface (White)
        onSecondary: TherapyColors.surface,
      ),
      
      // Configure the AppBar theme
      appBarTheme: AppBarTheme(
        // AppBar uses Canvas background for seamless look
        backgroundColor: TherapyColors.canvas,
        // Remove elevation shadow
        elevation: 0,
        // Center the title
        centerTitle: true,
        // Use Ink color for icons
        iconTheme: const IconThemeData(color: TherapyColors.ink),
        // Use Heading2 style for title
        titleTextStyle: TherapyText.heading2(),
      ),
      
      // Configure the Card theme
      cardTheme: CardThemeData(
        // Cards use Surface (White) color
        color: TherapyColors.surface,
        // Remove default elevation (we use custom shadows)
        elevation: 0,
        // Use card shape with 24px radius
        shape: TherapyShapes.cardShape(),
      ),
      
      // Configure the ElevatedButton theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // Background uses Growth (Sage Green)
          backgroundColor: TherapyColors.growth,
          // Text uses Surface (White)
          foregroundColor: TherapyColors.surface,
          // Remove default elevation
          elevation: 0,
          // Use pill shape
          shape: TherapyShapes.buttonShape(),
          // Add comfortable padding
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          // Use button text style
          textStyle: TherapyText.button(),
        ),
      ),
      
      // Configure the OutlinedButton theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          // Text uses Ink (Soft Charcoal)
          foregroundColor: TherapyColors.ink,
          // Use pill shape
          shape: TherapyShapes.buttonShape(),
          // Add comfortable padding
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          // Border uses Graphite color
          side: const BorderSide(color: TherapyColors.graphite, width: 1.5),
          // Use button text style
          textStyle: TherapyText.button(),
        ),
      ),
      
      // Configure the TextButton theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // Text uses Growth (Sage Green) for positive actions
          foregroundColor: TherapyColors.growth,
          // Use button text style
          textStyle: TherapyText.button(),
        ),
      ),
      
      // Configure the Input Decoration theme (text fields)
      inputDecorationTheme: InputDecorationTheme(
        // Use Surface (White) for fill
        filled: true,
        fillColor: TherapyColors.surface,
        // Use small radius for input fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TherapyShapes.smallRadius),
          borderSide: BorderSide.none,
        ),
        // Focus border uses Growth color
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TherapyShapes.smallRadius),
          borderSide: const BorderSide(color: TherapyColors.growth, width: 2),
        ),
        // Error border uses Boundary color
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TherapyShapes.smallRadius),
          borderSide: const BorderSide(color: TherapyColors.boundary, width: 2),
        ),
        // Content padding
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Configure the Divider theme
      dividerTheme: const DividerThemeData(
        // Dividers use Graphite at low opacity
        color: TherapyColors.graphite,
        thickness: 0.5,
        space: 1,
      ),
    );
    
    // Log successful theme creation
    debugPrint('[TherapyTheme::theme] Therapy Paper theme built successfully.');
    
    // Return the complete theme
    return themeData;
  }

  // -------------------------------------------------------------------------
  // DEBUG METHOD: Initialize and log all theme components
  // Call this at app startup to verify theme configuration
  // -------------------------------------------------------------------------
  static void debugInitialize() {
    // Log entry into the debug initialization
    debugPrint('[TherapyTheme::debugInitialize] ================================');
    debugPrint('[TherapyTheme::debugInitialize] IDLEMAN v16.0 - THERAPY PAPER');
    debugPrint('[TherapyTheme::debugInitialize] Initializing theme system...');
    debugPrint('[TherapyTheme::debugInitialize] ================================');
    
    // Log all colors
    TherapyColors.debugLogColors();
    
    // Log all text styles
    TherapyText.debugLogTextStyles();
    
    // Log theme creation
    debugPrint('[TherapyTheme::debugInitialize] Creating theme data...');
    theme; // This triggers the theme getter which logs its creation
    
    // Log completion
    debugPrint('[TherapyTheme::debugInitialize] ================================');
    debugPrint('[TherapyTheme::debugInitialize] Theme initialization complete!');
    debugPrint('[TherapyTheme::debugInitialize] ================================');
  }
}

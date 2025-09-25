# Flutter POS App

A Vietnamese Point of Sale (POS) mobile application built with Flutter, designed for restaurants and cafes.

## Features

- **Order Management**: Create and manage customer orders
- **Vietnamese Localization**: Full Vietnamese language support with proper currency formatting
- **Product Management**: Add, remove, and modify order items
- **Real-time Calculations**: Automatic price calculations with discounts and VAT
- **Staff Management**: Track orders by staff members
- **Table Management**: Organize orders by table numbers and positions

## Screenshots

The app replicates the interface shown in your reference image with:
- Header with navigation and action buttons
- Customer info cards (Price check, Staff name, Menu selection)
- Order details with table and position information
- Item list with quantity controls and prices
- Order summary with totals and discounts
- Action buttons for kitchen notification and payment

## Getting Started

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation

1. Navigate to the project directory:
```bash
cd flutter_pos_app
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── menu_item.dart
│   ├── order_item.dart
│   └── order.dart
├── providers/                # State management
│   └── order_provider.dart
├── screens/                  # App screens
│   └── order_screen.dart
├── widgets/                  # Custom widgets
│   ├── action_button.dart
│   ├── order_item_card.dart
│   └── quantity_selector.dart
└── utils/                    # Utilities
    └── currency_formatter.dart
```

## Key Components

### Models
- **MenuItem**: Represents menu items with pricing
- **OrderItem**: Represents items in an order with quantities
- **Order**: Complete order with customer info and calculations

### Widgets
- **OrderItemCard**: Displays individual order items
- **QuantitySelector**: Controls for item quantities
- **ActionButton**: Styled buttons for actions

### Utils
- **CurrencyFormatter**: Vietnamese currency formatting (đ symbol)

## Usage

The app automatically creates a sample order when launched, demonstrating:
- Multiple product types (beverages, time-based items)
- Quantity controls and units (ly, lon)
- Price calculations with Vietnamese formatting
- Discount and VAT calculations
- Staff and table information

## Customization

- Modify sample data in `order_screen.dart` `_initializeOrder()` method
- Adjust colors and styling in theme configuration
- Add new menu items through the `MenuItem` model
- Extend functionality with additional screens and features

## Dependencies

- `provider`: State management
- `intl`: Internationalization and number formatting
- `cupertino_icons`: iOS-style icons
- `flutter_lints`: Code analysis

## Development

The app uses Provider for state management and follows Flutter best practices with:
- Clean separation of concerns
- Responsive design
- Vietnamese localization support
- Proper error handling
- Extensible architecture
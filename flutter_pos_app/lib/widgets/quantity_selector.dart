import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final int minQuantity;
  final int maxQuantity;

  const QuantitySelector({
    Key? key,
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 0,
    this.maxQuantity = 99,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.remove,
          onPressed: quantity > minQuantity
              ? () => onQuantityChanged(quantity - 1)
              : null,
        ),
        Container(
          width: 50,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        _buildButton(
          icon: Icons.add,
          onPressed: quantity < maxQuantity
              ? () => onQuantityChanged(quantity + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.orange : Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
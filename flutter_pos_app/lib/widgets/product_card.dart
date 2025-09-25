import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import '../utils/currency_formatter.dart';

class ProductCard extends StatelessWidget {
  final MenuItem menuItem;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ProductCard({
    Key? key,
    required this.menuItem,
    required this.onTap,
    this.category,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _buildContentSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: category?.color.withOpacity(0.1) ?? Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: menuItem.imageUrl != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      menuItem.imageUrl!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
                    ),
                  )
                : _buildDefaultIcon(),
          ),
          if (!menuItem.isActive)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'NGƯNG BÁN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (menuItem.stock == 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HẾT HÀNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (menuItem.isTimeBased)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    IconData iconData;
    if (category?.icon == 'local_drink') {
      iconData = Icons.local_drink;
    } else if (category?.icon == 'restaurant') {
      iconData = Icons.restaurant;
    } else if (category?.icon == 'room_service') {
      iconData = Icons.room_service;
    } else if (category?.icon == 'schedule') {
      iconData = Icons.schedule;
    } else {
      iconData = Icons.fastfood;
    }

    return Icon(
      iconData,
      size: 40,
      color: category?.color ?? Colors.grey.shade400,
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                menuItem.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (menuItem.description != null) ...[
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    menuItem.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (menuItem.unit != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    menuItem.unit!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              if (menuItem.isTimeBased && menuItem.timeRange != null) ...[
                const SizedBox(height: 4),
                Text(
                  menuItem.timeRange!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                CurrencyFormatter.formatPrice(menuItem.price),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: menuItem.isActive ? Colors.orange : Colors.grey,
                ),
              ),
            ),
            if (menuItem.stock > 0 && menuItem.stock != -1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SL: ${menuItem.stock}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
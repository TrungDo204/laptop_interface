import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';
import 'order_screen.dart';
import 'product_selection_screen.dart';
import 'product_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final menuProvider = context.read<MenuProvider>();
    await menuProvider.loadCategories();
    await menuProvider.loadMenuItems();
    await menuProvider.initializeWithSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('POS System'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              title: 'Tạo đơn hàng',
              subtitle: 'Bắt đầu đơn hàng mới',
              icon: Icons.shopping_cart,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderScreen()),
              ),
            ),
            _buildMenuCard(
              title: 'Chọn sản phẩm',
              subtitle: 'Xem danh sách sản phẩm',
              icon: Icons.inventory_2,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductSelectionScreen()),
              ),
            ),
            _buildMenuCard(
              title: 'Quản lý sản phẩm',
              subtitle: 'Thêm, sửa, xóa sản phẩm',
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
              ),
            ),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                final hasOrder = orderProvider.currentOrder != null &&
                                orderProvider.currentOrder!.items.isNotEmpty;
                return _buildMenuCard(
                  title: 'Đơn hiện tại',
                  subtitle: hasOrder
                      ? '${orderProvider.currentOrder!.items.length} sản phẩm'
                      : 'Chưa có đơn hàng',
                  icon: Icons.receipt_long,
                  color: hasOrder ? Colors.orange : Colors.grey,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderScreen()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
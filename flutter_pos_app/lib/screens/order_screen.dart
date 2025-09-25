import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';
import '../widgets/order_item_card.dart';
import '../widgets/action_button.dart';
import '../utils/currency_formatter.dart';
import 'product_selection_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrder();
    });
  }

  void _initializeOrder() {
    final orderProvider = context.read<OrderProvider>();
    if (orderProvider.currentOrder == null) {
      orderProvider.createNewOrder(
        tableNumber: "BÀN SỐ 1",
        position: "Vị trí A",
        staffName: "Anh Luis Thái",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final order = orderProvider.currentOrder;
          if (order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeaderCards(order),
              Expanded(
                child: _buildOrderContent(order),
              ),
              _buildOrderSummary(order),
              _buildActionButtons(),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Đơn hàng',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long, color: Colors.blue),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.folder, color: Colors.blue),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.orange),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeaderCards(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildHeaderCard(
              icon: Icons.price_check,
              title: 'Giá niêm yết',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildHeaderCard(
              icon: Icons.person,
              title: order.staffName,
              isStaff: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductSelectionScreen(),
                ),
              ),
              child: _buildHeaderCard(
                icon: Icons.restaurant_menu,
                title: 'Chọn món',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required IconData icon,
    required String title,
    bool isStaff = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: isStaff ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContent(Order order) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.tableNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  order.position,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                return OrderItemCard(orderItem: order.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryRow(
            'Tổng thanh tiền',
            '${order.items.length}',
            CurrencyFormatter.formatPrice(order.subtotal),
            isTotal: true,
          ),
          _buildSummaryRow(
            'Tổng chiết khấu',
            '',
            '- ${CurrencyFormatter.formatPrice(order.discountAmount)}',
          ),
          _buildSummaryRow(
            'VAT (%)',
            '',
            CurrencyFormatter.formatPrice(order.vatAmount),
          ),
          const Divider(),
          _buildSummaryRow(
            'Khách phải trả',
            '',
            CurrencyFormatter.formatPrice(order.total),
            isFinal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String count,
    String amount, {
    bool isTotal = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isFinal ? 16 : 14,
                fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
                color: isFinal ? Colors.black : Colors.grey.shade700,
              ),
            ),
          ),
          if (count.isNotEmpty)
            Text(
              count,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          const SizedBox(width: 16),
          Text(
            amount,
            style: TextStyle(
              fontSize: isFinal ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: isFinal ? Colors.black : (isTotal ? Colors.orange : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ActionButton(
              text: 'BÁO CHẾ BIẾN',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã báo chế biến')),
                );
              },
              backgroundColor: Colors.orange.shade600,
              icon: Icons.restaurant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ActionButton(
              text: 'THANH TOÁN',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xử lý thanh toán')),
                );
              },
              backgroundColor: Colors.orange,
              icon: Icons.payment,
            ),
          ),
        ],
      ),
    );
  }
}
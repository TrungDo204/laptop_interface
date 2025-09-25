import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/product_card.dart';
import '../utils/currency_formatter.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final menuProvider = context.read<MenuProvider>();
    await menuProvider.loadCategories();
    await menuProvider.loadMenuItems();
    await menuProvider.initializeWithSampleData();

    if (menuProvider.categories.isNotEmpty && !mounted) return;

    setState(() {
      _tabController = TabController(
        length: menuProvider.categories.length + 1, // +1 for "All" tab
        vsync: this,
      );
    });

    _tabController.addListener(() {
      final menuProvider = context.read<MenuProvider>();
      if (_tabController.index == 0) {
        menuProvider.selectCategory(null); // "All" tab
      } else {
        final category = menuProvider.categories[_tabController.index - 1];
        menuProvider.selectCategory(category.id);
      }
    });
  }

  @override
  void dispose() {
    if (_tabController.hasListeners) {
      _tabController.dispose();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (menuProvider.categories.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              if (_showSearch) _buildSearchBar(menuProvider),
              _buildCategoryTabs(menuProvider),
              Expanded(
                child: _buildProductGrid(menuProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Chọn sản phẩm'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        IconButton(
          icon: Icon(_showSearch ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                context.read<MenuProvider>().searchItems('');
              }
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSearchBar(MenuProvider menuProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    menuProvider.searchItems('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => menuProvider.searchItems(value),
      ),
    );
  }

  Widget _buildCategoryTabs(MenuProvider menuProvider) {
    if (menuProvider.categories.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.orange,
        tabs: [
          const Tab(text: 'Tất cả'),
          ...menuProvider.categories.map((category) => Tab(text: category.name)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(MenuProvider menuProvider) {
    final items = menuProvider.filteredItems;

    if (items.isEmpty) {
      return _buildEmptyProductsState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ProductCard(
          menuItem: items[index],
          onTap: () => _addToOrder(items[index]),
          category: menuProvider.getCategoryById(items[index].categoryId),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm sản phẩm đầu tiên',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _addToOrder(MenuItem item) {
    final orderProvider = context.read<OrderProvider>();
    if (orderProvider.currentOrder == null) {
      orderProvider.createNewOrder(
        tableNumber: "BÀN SỐ 1",
        position: "Vị trí A",
        staffName: "Anh Luis Thái",
      );
    }

    orderProvider.addItem(item, unit: item.unit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${item.name} vào đơn hàng'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }
}

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({Key? key}) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _unitController = TextEditingController();
  String? _selectedCategoryId;
  bool _isTimeBased = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm sản phẩm mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<MenuProvider>(
                builder: (context, menuProvider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục *',
                      border: OutlineInputBorder(),
                    ),
                    items: menuProvider.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên sản phẩm *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.trim().isEmpty ?? true ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Giá (đ) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) return 'Vui lòng nhập giá';
                  if (double.tryParse(value!) == null) return 'Giá không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Đơn vị (ly, lon, phần...)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Tính theo thời gian'),
                value: _isTimeBased,
                onChanged: (value) {
                  setState(() {
                    _isTimeBased = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Lưu'),
        ),
      ],
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final menuProvider = context.read<MenuProvider>();
        await menuProvider.addMenuItem(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text),
          categoryId: _selectedCategoryId!,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          isTimeBased: _isTimeBased,
          unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm sản phẩm thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
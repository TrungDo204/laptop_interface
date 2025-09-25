import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/menu_provider.dart';
import '../models/menu_item.dart';
import '../widgets/product_card.dart';
import '../utils/currency_formatter.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Quản lý sản phẩm'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
                    context.read<MenuProvider>().searchItems('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => context.read<MenuProvider>().searchItems(value),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        return Container(
          color: Colors.white,
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(
                label: 'Tất cả',
                isSelected: menuProvider.selectedCategoryId == null,
                onTap: () => menuProvider.selectCategory(null),
              ),
              ...menuProvider.categories.map((category) {
                return _buildCategoryChip(
                  label: category.name,
                  isSelected: menuProvider.selectedCategoryId == category.id,
                  onTap: () => menuProvider.selectCategory(category.id),
                  color: category.color,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: color?.withOpacity(0.3) ?? Colors.orange.withOpacity(0.3),
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: color ?? Colors.orange,
      ),
    );
  }

  Widget _buildProductsList() {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, child) {
        if (menuProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = menuProvider.filteredItems.toList()
          ..addAll(menuProvider.menuItems.where((item) => !item.isActive));

        if (items.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: item.isActive ? Colors.green : Colors.red,
                  child: Icon(
                    item.isActive ? Icons.check : Icons.close,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: item.isActive ? Colors.black : Colors.grey,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(CurrencyFormatter.formatPrice(item.price)),
                    if (item.description != null)
                      Text(
                        item.description!,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    Text(
                      'Danh mục: ${menuProvider.getCategoryById(item.categoryId)?.name ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, item),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Sửa'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(item.isActive ? Icons.visibility_off : Icons.visibility),
                        title: Text(item.isActive ? 'Ẩn' : 'Hiện'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Xóa', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
          ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm sản phẩm đầu tiên'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, MenuItem item) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(item);
        break;
      case 'toggle':
        _toggleProductStatus(item);
        break;
      case 'delete':
        _showDeleteConfirmation(item);
        break;
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const ProductDialog(),
    );
  }

  void _showEditProductDialog(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => ProductDialog(item: item),
    );
  }

  Future<void> _toggleProductStatus(MenuItem item) async {
    try {
      await context.read<MenuProvider>().toggleItemStatus(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.isActive
                  ? 'Đã ẩn sản phẩm ${item.name}'
                  : 'Đã hiện sản phẩm ${item.name}',
            ),
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

  void _showDeleteConfirmation(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteProduct(item);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(MenuItem item) async {
    try {
      await context.read<MenuProvider>().deleteMenuItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa sản phẩm ${item.name}'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProductDialog extends StatefulWidget {
  final MenuItem? item;

  const ProductDialog({Key? key, this.item}) : super(key: key);

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _unitController;
  String? _selectedCategoryId;
  bool _isTimeBased = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _unitController = TextEditingController(text: widget.item?.unit ?? '');
    _selectedCategoryId = widget.item?.categoryId;
    _isTimeBased = widget.item?.isTimeBased ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'),
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: Text(isEditing ? 'Cập nhật' : 'Lưu'),
        ),
      ],
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final menuProvider = context.read<MenuProvider>();

        if (widget.item != null) {
          final updatedItem = widget.item!.copyWith(
            name: _nameController.text.trim(),
            price: double.parse(_priceController.text),
            categoryId: _selectedCategoryId!,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            isTimeBased: _isTimeBased,
            unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
          );
          await menuProvider.updateMenuItem(updatedItem);
        } else {
          await menuProvider.addMenuItem(
            name: _nameController.text.trim(),
            price: double.parse(_priceController.text),
            categoryId: _selectedCategoryId!,
            description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
            isTimeBased: _isTimeBased,
            unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
          );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.item != null ? 'Đã cập nhật sản phẩm thành công' : 'Đã thêm sản phẩm thành công'),
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
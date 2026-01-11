import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kpostal/kpostal.dart';
import '../providers/auth_provider.dart';
import '../providers/address_provider.dart';
import '../models/address.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await addressProvider.fetchAddresses(authProvider.userId!);
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddressFormDialog(
        onSave: (addressData) async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final addressProvider = Provider.of<AddressProvider>(context, listen: false);

          if (authProvider.userId != null) {
            final success = await addressProvider.createAddress(
              authProvider.userId!,
              addressData,
            );

            if (success && mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('주소가 추가되었습니다')),
              );
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(addressProvider.error ?? '주소 추가에 실패했습니다'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  void _showEditAddressDialog(Address address) {
    showDialog(
      context: context,
      builder: (context) => _AddressFormDialog(
        address: address,
        onSave: (addressData) async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final addressProvider = Provider.of<AddressProvider>(context, listen: false);

          if (authProvider.userId != null) {
            final success = await addressProvider.updateAddress(
              authProvider.userId!,
              address.id,
              addressData,
            );

            if (success && mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('주소가 수정되었습니다')),
              );
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(addressProvider.error ?? '주소 수정에 실패했습니다'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  void _deleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주소 삭제'),
        content: const Text('이 주소를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final addressProvider = Provider.of<AddressProvider>(context, listen: false);

              if (authProvider.userId != null) {
                final success = await addressProvider.deleteAddress(
                  authProvider.userId!,
                  address.id,
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('주소가 삭제되었습니다')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(addressProvider.error ?? '주소 삭제에 실패했습니다'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('배송지 관리'),
      ),
      body: Consumer2<AuthProvider, AddressProvider>(
        builder: (context, auth, addressProvider, child) {
          if (!auth.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('로그인이 필요합니다'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    child: const Text('로그인'),
                  ),
                ],
              ),
            );
          }

          if (addressProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (addressProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    addressProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAddresses,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (addressProvider.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '등록된 배송지가 없습니다',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddAddressDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('배송지 추가'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addressProvider.addresses.length,
              itemBuilder: (context, index) {
                final address = addressProvider.addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      address.isDefault ? Icons.home : Icons.location_on,
                      color: address.isDefault ? Theme.of(context).primaryColor : Colors.grey,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.recipientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (address.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '기본',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(address.phone),
                        const SizedBox(height: 4),
                        Text('${address.address} ${address.addressDetail ?? ""}'),
                        if (address.zipCode.isNotEmpty)
                          Text('우편번호: ${address.zipCode}'),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('수정'),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _showEditAddressDialog(address);
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('삭제', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _deleteAddress(address);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (!auth.isAuthenticated) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: _showAddAddressDialog,
            icon: const Icon(Icons.add),
            label: const Text('배송지 추가'),
          );
        },
      ),
    );
  }
}

class _AddressFormDialog extends StatefulWidget {
  final Address? address;
  final Function(Map<String, dynamic>) onSave;

  const _AddressFormDialog({
    this.address,
    required this.onSave,
  });

  @override
  State<_AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<_AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailAddressController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.recipientName;
      _phoneController.text = widget.address!.phone;
      _zipcodeController.text = widget.address!.zipCode;
      _addressController.text = widget.address!.address;
      _detailAddressController.text = widget.address!.addressDetail ?? '';
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _zipcodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return KpostalView(
              callback: (Kpostal result) {
                if (mounted) {
                  setState(() {
                    _zipcodeController.text = result.postCode;
                    _addressController.text = result.address;
                  });
                }
                Navigator.pop(context);
              },
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('주소 검색 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSave({
      'recipientName': _nameController.text,
      'phone': _phoneController.text,
      'zipCode': _zipcodeController.text,
      'address': _addressController.text,
      'addressDetail': _detailAddressController.text,
      'isDefault': _isDefault,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.address == null ? '배송지 추가' : '배송지 수정',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '받는 사람',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '받는 사람을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '연락처',
                      border: OutlineInputBorder(),
                      hintText: '010-1234-5678',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '연락처를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _zipcodeController,
                          decoration: const InputDecoration(
                            labelText: '우편번호',
                            border: OutlineInputBorder(),
                            hintText: '직접 입력 또는 검색',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '우편번호를 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchAddress,
                        child: const Text('주소 검색'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: '주소',
                      border: OutlineInputBorder(),
                      hintText: '직접 입력 또는 검색',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '주소를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _detailAddressController,
                    decoration: const InputDecoration(
                      labelText: '상세 주소',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '상세 주소를 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('기본 배송지로 설정'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(widget.address == null ? '추가' : '수정'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


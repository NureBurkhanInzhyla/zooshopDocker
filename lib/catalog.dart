import 'package:flutter/material.dart';
import 'package:zooshop/product.dart';
import 'package:zooshop/main.dart';
import 'header.dart';
import 'footer.dart';
import 'models/Product.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/cartProvider.dart';

class CatalogPage extends StatefulWidget {
  final String? searchQuery;
  final String? animalType;

  const CatalogPage({Key? key, this.searchQuery, this.animalType}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  int _currentPage = 0;
  final int _productsPerPage = 12;
  List<ProductDTO> products = [];
  bool isLoading = true;
  List<String> petCategories = [];
  Map<String, bool> productTypes = {};

  final TextEditingController _startPriceController = TextEditingController();
  final TextEditingController _endPriceController = TextEditingController();

  int? startPrice;
  int? endPrice;

  String? searchQuery;

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery;
    _loadCategoriesAndProducts();
  }

  Future<void> _loadCategoriesAndProducts() async {
    try {
      final categories = await fetchCategories();

      setState(() {
        productTypes = {
          for (var cat in categories["productCategories"]!) cat: false,
        };
        petCategories = categories["petCategories"]!;
      });

      await _loadProducts();
    } catch (e) {
      print("Помилка завантаження категорій: $e");
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<String> selectedTypes = productTypes.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedTypes.isNotEmpty) {
        final noProducts = await fetchProductsByFiltration(
          name: searchQuery,
          startPrice: startPrice,
          endPrice: endPrice,
          petCategory: widget.animalType,
          productCategory: selectedTypes.join(","),
        );

        setState(() {
          products = noProducts;
          isLoading = false;
          _currentPage = 0;
        });

        return;
      }

      List<ProductDTO> fetchedProducts = await fetchProductsByFiltration(
        name: searchQuery,
        startPrice: startPrice,
        endPrice: endPrice,
        petCategory: widget.animalType,
        productCategory: null,
      );

      setState(() {
        products = fetchedProducts;
        isLoading = false;
        _currentPage = 0;
      });
    } catch (e) {
      print('Помилка завантаження товарів: $e');
      setState(() {
        isLoading = false;
        products = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalPages = (products.length / _productsPerPage).ceil();
    final startIndex = _currentPage * _productsPerPage;
    final endIndex = (_currentPage + 1) * _productsPerPage;
    final currentProducts = products.sublist(
      startIndex,
      endIndex > products.length ? products.length : endIndex,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  HeaderBlock(),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _buildCatalogTitle(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 69, 48, 40),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSettingsBlock(),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ProductsBlock(products: currentProducts),
                  ),
                  SizedBox(height: 20),
                  _buildPagination(totalPages),
                  SizedBox(height: 20),
                  FooterBlock(),
                ],
              ),
            ),
    );
  }

  String _buildCatalogTitle() {
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      return 'Результати пошуку для "${widget.searchQuery}"';
    } else if (widget.animalType != null && widget.animalType!.isNotEmpty) {
      return 'Товари для категорії ${widget.animalType!.toLowerCase()}';
    } else {
      return 'Усі товари';
    }
  }

  Widget _buildSettingsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ціна", style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startPriceController,
                decoration: InputDecoration(
                  labelText: "Від",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _endPriceController,
                decoration: InputDecoration(
                  labelText: "До",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Color(0xFFC16AFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                setState(() {
                  startPrice = int.tryParse(_startPriceController.text);
                  endPrice = int.tryParse(_endPriceController.text);
                });
                _loadProducts();
              },
              child: Text(
                "Накласти фільтр",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Color.fromARGB(255, 221, 212, 228),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                setState(() {
                  startPrice = null;
                  endPrice = null;
                  _startPriceController.clear();
                  _endPriceController.clear();
                  productTypes.updateAll((key, value) => false);
                });
                _loadProducts();
              },
              child: Text(
                "Зняти фільтр",
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 71, 71, 71),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text("Тип", style: TextStyle(fontSize: 16)),
        SizedBox(height: 10),
        ...productTypes.keys.map((type) {
          return CheckboxListTile(
            title: Text(type, style: TextStyle(fontSize: 14)),
            value: productTypes[type],
            onChanged: (bool? val) {
              setState(() {
                productTypes[type] = val ?? false;
              });
              _loadProducts();
            },
            activeColor: Color(0xFFC16AFF),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, size: 24),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        ...List.generate(totalPages, (index) {
          final isActive = index == _currentPage;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentPage = index;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? Color(0xFFC16AFF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
        IconButton(
          icon: Icon(Icons.chevron_right, size: 24),
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
      ],
    );
  }
}

class PriceFromTag extends StatelessWidget {
  const PriceFromTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Від',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 6),
          Container(
            width: 50,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '300',
                hintStyle: TextStyle(
                  color: Colors.brown,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextStyle(
                color: Colors.brown,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PriceToTag extends StatelessWidget {
  const PriceToTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'До',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          SizedBox(width: 6),
          Container(
            width: 50,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '800',
                hintStyle: TextStyle(
                  color: Colors.brown,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextStyle(
                color: Colors.brown,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductsBlock extends StatelessWidget {
  final List<ProductDTO> products;

  const ProductsBlock({required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(child: Text('Не знайдено товарів', style: TextStyle(fontSize: 16)));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.5,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductDTO product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductPage(product: product)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (product.desc.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                product.desc,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Spacer(),
            Text(
              '${product.price} ₴',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.isLoggedIn) {
                    Provider.of<CartProvider>(context, listen: false).addOrUpdateCartItem(product, context);
                  } else {
                    showRegisterDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF95C74E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Купити',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            SizedBox(height: 8),
            OneClickOrderText(),
          ],
        ),
      ),
    );
  }
}
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
  final int _productsPerPage = 16;
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
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.82,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderBlock(),
                          SizedBox(height: 55),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              _buildCatalogTitle(),
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 69, 48, 40),
                              ),
                            ),
                          ),
                          SizedBox(height: 60),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                              padding: EdgeInsets.only(left: 20),
                              child:_buildSettingsBlock(),),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 70), 
                                  child: ProductsBlock(products: currentProducts),
                                ),
                              ),


                            ],
                          ),
                          SizedBox(height: 24),
                          _buildPagination(totalPages),
                          SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
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
    return SizedBox(
      width: 244,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Ціна", style: TextStyle(fontSize: 25)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startPriceController,
                  decoration: InputDecoration(labelText: "Від"),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _endPriceController,
                  decoration: InputDecoration(labelText: "До"),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Center(child:ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 60),
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
            child: Text("Накласти фільтр", style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),),
          ),
          ),
          SizedBox(height: 7), 
          Center(child:ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 72),
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
            child: Text("Зняти фільтр", style: TextStyle(
                fontSize: 14,
                color: const Color.fromARGB(255, 71, 71, 71),
                fontWeight: FontWeight.w600,
              ),),
            ),),
          SizedBox(height: 30),
          Text("Тип", style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          ...productTypes.keys.map((type) {
            return CheckboxListTile(
              title: Text(type, style: TextStyle(fontSize: 15),),
              value: productTypes[type],
              onChanged: (bool? val) {
                setState(() {
                  productTypes[type] = val ?? false;
                });
                _loadProducts();
              },
              activeColor: Color(0xFFC16AFF),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ],
      ),
    );
  }
  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
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
              margin: EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Color(0xFFC16AFF) : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        IconButton(
          icon: Icon(Icons.chevron_right),
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
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ), // Цвет рамки
        borderRadius: BorderRadius.circular(
          8,
        ), // Закругленные углы
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize
                .min, // Ограничивает ширину контейнера до размера содержимого
        children: [
          Text(
            'Від',
            style: TextStyle(
              color: Colors.grey, // Цвет текста
              fontSize: 14, // Размер шрифта
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 30, // Ширина поля ввода
            child: TextField(
              keyboardType:
                  TextInputType
                      .number, // Ограничение для ввода чисел
              decoration: InputDecoration(
                border:
                    InputBorder
                        .none, // Без рамки внутри поля
                hintText: '300', // Подсказка по умолчанию
                hintStyle: TextStyle(
                  color:
                      Colors.brown, // Цвет текста подсказки
                  fontSize: 16, // Размер шрифта
                  fontWeight:
                      FontWeight.bold, // Жирный текст
                ),
              ),
              style: TextStyle(
                color:
                    Colors
                        .brown, // Цвет текста, который вводится
                fontSize: 16, // Размер шрифта
                fontWeight: FontWeight.bold, // Жирный текст
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
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ), // Цвет рамки
        borderRadius: BorderRadius.circular(
          8,
        ), // Закругленные углы
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize
                .min, // Ограничивает ширину контейнера до размера содержимого
        children: [
          Text(
            'До',
            style: TextStyle(
              color: Colors.grey, // Цвет текста
              fontSize: 14, // Размер шрифта
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 30, // Ширина поля ввода
            child: TextField(
              keyboardType:
                  TextInputType
                      .number, // Ограничение для ввода чисел
              decoration: InputDecoration(
                border:
                    InputBorder
                        .none, // Без рамки внутри поля
                hintText: '800', // Подсказка по умолчанию
                hintStyle: TextStyle(
                  color:
                      Colors.brown, // Цвет текста подсказки
                  fontSize: 16, // Размер шрифта
                  fontWeight:
                      FontWeight.bold, // Жирный текст
                ),
              ),
              style: TextStyle(
                color:
                    Colors
                        .brown, // Цвет текста, который вводится
                fontSize: 16, // Размер шрифта
                fontWeight: FontWeight.bold, // Жирный текст
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
      return Center(child: Text('Не знайдено товарів'));
    }

    return Wrap(
      spacing: 10,  
      runSpacing: 25,    
      children: products.map((product) {
        return SizedBox(
          width: 220, 
          child: ProductCard(product: product),
        );
      }).toList(),
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
        constraints: BoxConstraints(
          maxWidth: 220,
          maxHeight: 480,
        ),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Изображение товара
            Container(
              width: 190,
              height: 190,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                ),
              ),
            ),
            SizedBox(height: 10),
      
            Text(
              product.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (product.desc.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                product.desc,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '${product.price} ₴',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                // if (product.oldPrice != null) ...[
                //   SizedBox(width: 8),
                //   Text(
                //     '${product.oldPrice} ₴',
                //     style: TextStyle(
                //       decoration: TextDecoration.lineThrough,
                //       color: Colors.grey,
                //       fontSize: 16,
                //     ),
                //   ),
                // ]
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if(authProvider.isLoggedIn){
                      final userId = authProvider.user!.id!;
                      Provider.of<CartProvider>(context, listen: false).addOrUpdateCartItem(product, context);
                  }
                  else{
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
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 15),
            OneClickOrderText(),
          ],
        ),
      ),
    );
  }
}


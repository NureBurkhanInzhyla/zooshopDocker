import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'package:zooshop/main.dart';
import 'models/Product.dart';
import 'main.dart' as mainPage;
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'package:zooshop/cartProvider.dart';

class ProductPage extends StatelessWidget {
    final ProductDTO product;

  const ProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: screenWidth * (1 - 0.18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderBlock(),
                    SizedBox(height: 15),
                    Divider(),
                    SizedBox(height: 50),
                    ProductBlock(product: product),
                    SizedBox(height: 100),
                    DetailBlock(product: product),
                    SizedBox(height: 125),
                    RecomendationBlock(product: product),
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
}

class ProductBlock extends StatelessWidget {
  final ProductDTO product;

  const ProductBlock({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                product.image,
                width: 370,
                height: 370,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image),
              ),
              SizedBox(width: 27),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: Color.fromARGB(255, 69, 50, 43),
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("Код товару: ${product.id}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Тип: ", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(product.productCategory, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Row(
                      children: [
                        Text("Категорія: ", style: TextStyle(fontSize: 16)),
                        SizedBox(width: 5),
                        Text(product.petCategory, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        PriceCard(
          newPrice: product.price.toString(),
          oldPrice: product.discountPercent != null
              ? (product.price / (1 - product.discountPercent! / 100)).round().toString()
              : product.price.toString(),
          product: product,
        ),
      ],
    );

  }
}


class PriceCard extends StatelessWidget {
  final String oldPrice;
  final String newPrice;
  final ProductDTO product;

  const PriceCard({
    super.key,
    required this.oldPrice,
    required this.newPrice,
    required this.product
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 264,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 40),
                child: Text(
                  "$newPrice ₴",
                  style: TextStyle(
                    color: Color(0xFFF54949),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(right: 40),
                child: Text(
                  "$oldPrice ₴",
                  style: TextStyle(
                    color: Color(0xFF848992),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 27),
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.isLoggedIn) {
                      Provider.of<CartProvider>(context, listen: false)
                          .addOrUpdateCartItem(product, context);
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
                "Купити",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          SizedBox(height: 11),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => OneClickOrderDialog(),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF95C74E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                foregroundColor: Color(0xFF95C74E),
              ),
              child: Text("Купити в один клік", style: TextStyle(fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}


class DetailBlock extends StatefulWidget {
  final ProductDTO product;

  const DetailBlock({super.key, required this.product});

  @override
  State<DetailBlock> createState() => _DetailBlockState();
}

class _DetailBlockState extends State<DetailBlock> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final descriptionText = widget.product.desc;
    final characteristicsText = "• Категорія: ${widget.product.petCategory}\n• Тип: ${widget.product.productCategory}";

    return Center(
      child: SizedBox(
        width: screenWidth * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTab("Опис", 0),
                _buildTab("Характеристики", 1),
              ],
            ),
            Divider(height: 1, color: Colors.grey),
            SizedBox(height: 30),
            SizedBox(
              width: screenWidth * 0.82,
              child: Text(
                selectedIndex == 0 ? descriptionText : characteristicsText,
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTab(String text, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.purpleAccent : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.purpleAccent : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 23,
          ),
        ),
      ),
    );
  }
}


class RecomendationBlock extends StatefulWidget {
  final ProductDTO product;

  const RecomendationBlock({super.key, required this.product});

  @override
  State<RecomendationBlock> createState() => _RecomendationBlockState();
}

class _RecomendationBlockState extends State<RecomendationBlock> {
  List<ProductDTO> similarProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimilar();
  }

  Future<void> _loadSimilar() async {
    final products = await fetchSimilarProducts(widget.product);
    setState(() {
      similarProducts = products;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Схожі товари",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 30),
        SizedBox(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: _scrollLeft,
              ),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  itemCount: similarProducts.length,
                  separatorBuilder: (_, __) => SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final product = similarProducts[index];
                    return SizedBox(
                      width: 220,
                      child: mainPage.ProductCard(product: product),
                    );
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios),
                onPressed: _scrollRight,
              ),
            ],
          ),
        ),
      ],
    );
  }

}

final ScrollController _scrollController = ScrollController();

void _scrollLeft() {
  _scrollController.animateTo(
    _scrollController.offset - 240, 
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}

void _scrollRight() {
  _scrollController.animateTo(
    _scrollController.offset + 240,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}


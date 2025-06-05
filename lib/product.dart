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
      bottomNavigationBar:  FooterBlock(),
      body: SingleChildScrollView(
        child: SizedBox(
          width: screenWidth * 0.95,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderBlock(),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 20),
              ProductBlock(product: product),
              SizedBox(height: 40),
              DetailBlock(product: product),
              SizedBox(height: 60),
              RecomendationBlock(product: product),
              SizedBox(height: 40)
            ],
          ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              product.image,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image),
            ),
          ),
          SizedBox(height: 16),
          Text(
            product.name,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text("Код товару: ${product.id}", style: TextStyle(fontSize: 15)),
          SizedBox(height: 12),
          Row(
            children: [
              Text("Тип: ", style: TextStyle(fontSize: 15)),
              SizedBox(width: 4),
              Text(product.productCategory, style: TextStyle(fontSize: 15)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text("Категорія: ", style: TextStyle(fontSize: 15)),
              SizedBox(width: 4),
              Text(product.petCategory, style: TextStyle(fontSize: 15)),
            ],
          ),
          SizedBox(height: 16),
          PriceCard(
            newPrice: product.price.toString(),
            oldPrice: product.discountPercent != null
                ? (product.price / (1 - product.discountPercent! / 100)).round().toString()
                : product.price.toString(),
            product: product,
          ),
        ],
      ),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: 
                  Text(
                    "$newPrice ₴",
                    style: TextStyle(
                      color: Color(0xFFF54949),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "$oldPrice ₴",
                  style: TextStyle(
                    color: Color(0xFF848992),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
                minimumSize: Size(double.infinity, 36),
              ),
              child: Text(
                "Купити",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 15),
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
                minimumSize: Size(double.infinity, 36),
              ),
              child: Text("Купити в один клік", style: TextStyle(fontSize: 18, color: Color(0xFF95C74E))),
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
    final descriptionText = widget.product.desc;
    final characteristicsText = "• Категорія: ${widget.product.petCategory}\n• Тип: ${widget.product.productCategory}";

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
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
          SizedBox(height: 16),
          Text(
            selectedIndex == 0 ? descriptionText : characteristicsText,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.purpleAccent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.purpleAccent : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 19,
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
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 160,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 160,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductDTO>>(
      future: fetchSimilarProducts(widget.product),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15), 
                child: 
                  Text(
                    "Схожі товари",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 360,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: _scrollLeft,
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return SizedBox(
                            width: 180,
                            child: mainPage.ProductCard(product: product),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 20),
                      onPressed: _scrollRight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
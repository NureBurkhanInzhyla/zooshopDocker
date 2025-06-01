import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/subscription_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'auth_service.dart';
import 'package:zooshop/models/Product.dart';
import 'package:zooshop/product.dart';
import 'package:zooshop/cartProvider.dart';
import 'catalog.dart';

void main() async{
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>( 
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, authProvider, cartProvider) {
            if (authProvider.isLoggedIn && authProvider.user?.id != null) {
              cartProvider!.setUser(authProvider.user!.id!);
            }

            return cartProvider!;
          },
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zooshop',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<ProductDTO> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final fetchedProducts = await fetchProducts();
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Помилка завантаження продуктів: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Помилка: $error')),
      );
    }

    final salesProducts = products.where((p) => p.discountPercent != null).toList();
    final newProducts = products
      .toList()
      ..sort((a, b) => b.id.compareTo(a.id));

    final latestFive = newProducts.take(10).toList();


    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: screenWidth * 0.82,
            child: Column(
              children: [
                HeaderBlock(),
                SizedBox(height: 50),
                PromoVetCard(),
                SizedBox(height: 50),
                SalesBlock(products: salesProducts),
                SizedBox(height: 130),
                PromoConsultCard(),
                SizedBox(height: 100),
                NewsBlock(products: latestFive),
                SizedBox(height: 50),
                BrandsBlock(),
                SizedBox(height: 70),
                FooterBlock(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class PromoVetCard extends StatelessWidget {
  const PromoVetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      height: 400,
      decoration: BoxDecoration(
        color: Color(0xFF95C74E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
           
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Кошлатість сильно\nпідвищиться!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Знижка 20% на всі шампуні\nдля кошенят.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 65),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CatalogPage(searchQuery: "Шампунь"),
                        ),
                      );
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC16AFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Дивитися шампуні',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 450), 
            ],
          ),
         
          Positioned(
            right: -50, 
            top: -100,
            child: SizedBox(
              width: 450,
              height: 450,
              child: Image.asset(
                'assets/images/cat.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PromoConsultCard extends StatelessWidget {
  const PromoConsultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(50),
      height: 400,
      decoration: BoxDecoration(
        color: Color(0xFFFF9955),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ми готові оказати вам\nпідтримку в виборі',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Безкоштовні консультації',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 75),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF95C74E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Зв'язок з консультантом",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 150), 
            ],
          ),
          Positioned(
            right: -50,
            top: -100,
            width: 450,
            height: 450,
            child: Image.asset(
              'assets/images/consultant.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class SalesBlock extends StatefulWidget {
  final List<ProductDTO> products;

  const SalesBlock({super.key, required this.products});

  @override
  State<SalesBlock> createState() => _SalesBlockState();
}

class _SalesBlockState extends State<SalesBlock> {
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

  @override
  Widget build(BuildContext context) {
    final products = widget.products;
    final showArrows = products.length > 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Акції",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          
          ],
        ),
        SizedBox(height: 30),
        SizedBox(
          height: 350,
          child: Row(
            children: [
              if (showArrows)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _scrollLeft,
                ),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return SizedBox(
                      width: 220,
                      child: ProductCard(product: product),
                    );
                  },
                ),
              ),
              if (showArrows)
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


class NewsBlock extends StatefulWidget {
  final List<ProductDTO> products;

  const NewsBlock({super.key, required this.products});

  @override
  State<NewsBlock> createState() => _NewsBlockState();
}

class _NewsBlockState extends State<NewsBlock> {
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

  @override
  Widget build(BuildContext context) {
    final products = widget.products;
    final showArrows = products.length > 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Новинки",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
           
          ],
        ),
        SizedBox(height: 30),
        SizedBox(
          height: 350,
          child: Row(
            children: [
              if (showArrows)
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: _scrollLeft,
                ),
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => SizedBox(width: 20),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return SizedBox(
                      width: 220,
                      child: ProductCard(product: product),
                    );
                  },
                ),
              ),
              if (showArrows)
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



class ProductCard extends StatelessWidget {
  final ProductDTO product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductPage(product: product),
            ),
          );
        },
      child: Container(
        width: 200,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                SizedBox(height: 18),
                Image.asset(
                  product.image,
                  height: 190,
                  width: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image),
                ),
                SizedBox(height: 10),
                Text(
                  product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 15),
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
                          color: product.discountPercent != null
                              ? Color(0xFFF54949)
                              : Colors.black,
                        ),
                      ),
                    ),
                    if (product.discountPercent != null) ...[
                      SizedBox(width: 10),
                      Text(
                        '${(product.price / (1 - product.discountPercent! / 100)).round()} ₴',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 35,
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
                      backgroundColor: Color(0xFFC16AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Купити',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OneClickOrderText(),
                ),
              ],
            ),
            if (product.discountPercent != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFF54949),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-${product.discountPercent}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}



class BrandsBlock extends StatelessWidget {
  const BrandsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'Популярні бренди',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 50),
        Container(
          padding: EdgeInsets.only(left: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo('assets/images/royalcanin.png', true),
              _buildLogo('assets/images/whiskas.png', true),
              _buildLogo('assets/images/royalcanin.png', true),
              _buildLogo('assets/images/whiskas.png', true),
              _buildLogo('assets/images/royalcanin.png', true),
              _buildLogo('assets/images/whiskas.png', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(String imagePath, bool line) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (line)
          Padding(
            padding: const EdgeInsets.only(left: 22.0), 
            child: Container(
              width: 2,
              height: 150,
              color: Color(0xFFE0E0E0),
            ),
          ),
      ],
    );
  }

}

class OneClickOrderText extends StatelessWidget {
  const OneClickOrderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '',
        children: [
          TextSpan(
            text: 'Купити за 1 клік',
            style: TextStyle(
              color: Color(0xFF95C74E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                showDialog(
                  context: context,
                  builder: (context) => OneClickOrderDialog(),
                );
              },
          ),
        ],
      ),
    );
  }
}
class OneClickOrderDialog extends StatefulWidget {
  @override
  _OneClickOrderDialogState createState() => _OneClickOrderDialogState();
}

class _OneClickOrderDialogState extends State<OneClickOrderDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

 @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 35),
              Center(
                child: Text(
                  "Для замовлення в 1 клік\nвкажіть своє ім’я та номер\nтелефону",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Ім’я',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text;
                    final phone = _phoneController.text;
                    print('Надіслано: $name, $phone');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF95C74E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                    'Надіслати',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

}

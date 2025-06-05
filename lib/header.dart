import 'package:flutter/material.dart';
import 'package:zooshop/account_page.dart';
import 'catalog.dart';
import 'auth_service.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'package:zooshop/models/User.dart';
import 'cart_page.dart';

class HeaderBlock extends StatelessWidget {
  const HeaderBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SearchBar(
                onSearch: (query) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CatalogPage(searchQuery: query),
                    ),
                  );
                },
              ),
            ),

            const MenuBottomNavigation(),

            
          ],
        );
      },
    );
  }
}


class MenuBottomNavigation extends StatelessWidget {
  const MenuBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'label': 'Усі товари', 'type': null},
      {'label': 'Кішки', 'type': 'Кішки'},
      {'label': 'Собаки', 'type': 'Собаки'},
      {'label': 'Гризуни', 'type': 'Гризуни'},
      {'label': 'Птахи', 'type': 'Птахи'},
      {'label': 'Риби', 'type': 'Риби'},
      {'label': 'Рептилії', 'type': 'Рептилії'},
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CatalogPage(isPromotional: true),
                  ),
                );
              },
              child: Row(
                children: const [
                  Text("Акції", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.percent, color: Color(0xFF95C74E)),
                ],
              ),
            );
          }

          final item = categories[index];
          return TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CatalogPage(animalType: item['type']),
                ),
              );
            },
            child: Text(item['label'], style: TextStyle(color: Colors.black)),
          );
        },
      ),
    );
  }
}



class SearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  void _onSearchPressed() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Пошук товарів',
        suffixIcon: IconButton(
          icon: Icon(Icons.search, color: Color(0xFF95C74E)),
          onPressed: _onSearchPressed,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      onSubmitted: (_) => _onSearchPressed(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}





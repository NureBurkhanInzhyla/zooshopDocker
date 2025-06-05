import 'package:flutter/material.dart';

class FooterBlock extends StatelessWidget {
  const FooterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Divider(height: 1.0, color: Color.fromARGB(255, 182, 169, 159)),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 50,
            horizontal: screenWidth * 0.1,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Дізнавайтеся про знижки та\nнові пропозиції найпершими",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(width: 30),
              SizedBox(
                width: 400,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Введіть вашу електронну пошту",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 167, 151, 138),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                            topLeft: Radius.circular(0),
                            bottomLeft: Radius.circular(0),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                      ),
                      child: Text(
                        "Підписатися",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("© 2025 Інтернет магазин зоотоварів \n“Пухнастик”"),
            Text("Вартість товарів на сайті не є \nпублічною офертою"),
            Text("zooshopPuchanstik@gmail.com"),
            Row(
              spacing: 10,
              children: [
                Icon(Icons.call, color: Colors.green),
                Text("+380991992827"),
              ],
            ),
          ],
        ),
        SizedBox(height: 50),
      ],
    );
  }
}

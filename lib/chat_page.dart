import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tawkto/flutter_tawk.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    return Scaffold(
 
      body: Tawk(
        directChatLink: 'https://tawk.to/chat/683da51140108d190d448922/1isocpjkb',
        visitor: TawkVisitor(
          name: user?.name ?? "Гість",
          email: user?.email ?? "",
        ),
      ),
    );
  }
}

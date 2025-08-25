import 'package:flutter/material.dart';

class FirebaseSetupDialog extends StatelessWidget {
  const FirebaseSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 8),
          Text('Configuração do Firebase'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para usar o Habitracker com autenticação e sincronização na nuvem, você precisa conectar um projeto Firebase.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Passos para configurar:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Abra o módulo Firebase na interface'),
            Text('2. Clique em "Connect to Firebase"'),
            Text('3. Siga as instruções para conectar seu projeto'),
            Text('4. Reinicie o app após a configuração'),
            SizedBox(height: 16),
            Text(
              'Enquanto isso, você pode usar o app offline com dados locais.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // In a real app, this would navigate to Firebase setup
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Abra o módulo Firebase na interface para configurar'),
                duration: Duration(seconds: 3),
              ),
            );
          },
          child: const Text('Configurar Firebase'),
        ),
      ],
    );
  }
}
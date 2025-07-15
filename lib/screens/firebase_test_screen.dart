// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class FirebaseTestScreen extends StatefulWidget {
//   const FirebaseTestScreen({super.key});

//   @override
//   State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
// }

// class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
//   final CollectionReference _gastos = FirebaseFirestore.instance.collection(
//     'gastos_prueba',
//   );

//   Future<void> _agregarGasto() async {
//     await _gastos.add({
//       'descripcion': 'Tacos',
//       'monto': 100,
//       'fecha': DateTime.now(),
//     });
//   }

//   Future<List<Map<String, dynamic>>> _leerGastos() async {
//     final querySnapshot = await _gastos.get();
//     return querySnapshot.docs
//         .map((doc) => doc.data() as Map<String, dynamic>)
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Test Firebase')),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _agregarGasto,
//             child: const Text('Agregar gasto'),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: FutureBuilder<List<Map<String, dynamic>>>(
//               future: _leerGastos(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 }

//                 final gastos = snapshot.data ?? [];

//                 return ListView.builder(
//                   itemCount: gastos.length,
//                   itemBuilder: (context, index) {
//                     final gasto = gastos[index];
//                     return ListTile(
//                       title: Text(gasto['descripcion'] ?? 'Sin nombre'),
//                       subtitle: Text('Monto: \$${gasto['monto']}'),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

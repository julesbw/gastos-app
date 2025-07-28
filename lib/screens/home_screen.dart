// lib/screens/home_screen.dart
// Pantalla principal que muestra los gastos del usuario

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/gasto.dart';
import 'add_gasto_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gastos')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay gastos registrados.'));
          }

          final gastos = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Gasto(
              id: doc.id,
              descripcion: data['descripcion'],
              monto: (data['monto'] as num).toDouble(),
              categoria: data['categoria'],
              fecha: DateTime.parse(data['fecha']),
            );
          }).toList();

          final totalGastado = gastos.fold(
            0.0,
            (suma, gasto) => suma + gasto.monto,
          );

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Total gastado: \$${totalGastado.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: gastos.length,
                  itemBuilder: (context, index) {
                    final gasto = gastos[index];
                    return _buildGastoTile(gasto);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final _ = await Navigator.push<Gasto>(
            context,
            MaterialPageRoute(
              builder: (context) => AddGastoScreen(
                onAdd: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('¡Gasto agregado!')),
                  );
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGastoTile(Gasto gasto) {
    return Slidable(
      key: ValueKey(gasto.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) async {
              final gastoEliminado = gasto;

              // Eliminar de Firestore
              await FirebaseFirestore.instance
                  .collection('gastos')
                  .doc(gasto.id)
                  .delete();

              if (!mounted) return;

              // Mostrar SnackBar con opción de deshacer
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gasto "${gasto.descripcion}" eliminado'),
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('gastos')
                          .doc(gastoEliminado.id)
                          .set({
                            'descripcion': gastoEliminado.descripcion,
                            'monto': gastoEliminado.monto,
                            'categoria': gastoEliminado.categoria,
                            'fecha': gastoEliminado.fecha.toIso8601String(),
                          });
                    },
                  ),
                ),
              );
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: ListTile(
        title: Text(gasto.descripcion),
        subtitle: Text(
          '${gasto.categoria} • ${DateFormat.Hm().format(gasto.fecha)}',
        ),
        trailing: Text('\$${gasto.monto.toStringAsFixed(2)}'),
        leading: const Icon(Icons.monetization_on),
      ),
    );
  }
}

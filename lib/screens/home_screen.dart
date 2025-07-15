import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../data/gastos_data.dart';
import 'add_gasto_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Gasto> _gastos = gastosDummy;

  double get _totalGastado {
    return _gastos.fold(0.0, (suma, gasto) => suma + gasto.monto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Gastos'), centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            child: Text(
              'Total gastado: \$${_totalGastado.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _gastos.length,
              itemBuilder: (context, index, animation) {
                final gasto = _gastos[index];
                return SizeTransition(
                  sizeFactor: animation,
                  child: _buildGastoTile(gasto, index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // ignore: unused_local_variable
          final nuevoGasto = await Navigator.push<Gasto>(
            context,
            MaterialPageRoute(
              builder: (context) => AddGastoScreen(
                onAdd: (gasto) {
                  setState(() {
                    _gastos.insert(0, gasto); // o al final si prefieres
                    _listKey.currentState!.insertItem(0);
                  });

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

  Widget _buildGastoTile(Gasto gasto, int index) {
    return Slidable(
      key: ValueKey(gasto.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              final gastoEliminado = gasto;
              final indexEliminado = index;

              _listKey.currentState!.removeItem(
                indexEliminado,
                (context, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: _buildGastoTile(gastoEliminado, indexEliminado),
                ),
                duration: const Duration(milliseconds: 300),
              );

              setState(() {
                _gastos.removeAt(indexEliminado);
              });

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Gasto "${gastoEliminado.descripcion}" eliminado',
                  ),
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () {
                      setState(() {
                        _gastos.insert(indexEliminado, gastoEliminado);
                        _listKey.currentState!.insertItem(indexEliminado);
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

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/gasto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGastoScreen extends StatefulWidget {
  final Function(Gasto) onAdd;

  const AddGastoScreen({super.key, required this.onAdd});

  @override
  State<AddGastoScreen> createState() => _AddGastoScreenState();
}

class _AddGastoScreenState extends State<AddGastoScreen> {
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  String _categoria = 'Comida';
  DateTime _fecha = DateTime.now();

  void _guardarGasto() async {
    final descripcion = _descripcionController.text;
    final monto = double.tryParse(_montoController.text);

    if (descripcion.trim().isEmpty || monto == null || monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final nuevoGasto = Gasto(
      id: const Uuid().v4(),
      descripcion: descripcion,
      monto: monto,
      categoria: _categoria,
      fecha: _fecha,
    );

    try {
      await FirebaseFirestore.instance
          .collection('gastos')
          .doc(nuevoGasto.id)
          .set({
            'descripcion': nuevoGasto.descripcion,
            'monto': nuevoGasto.monto,
            'categoria': nuevoGasto.categoria,
            'fecha': nuevoGasto.fecha.toIso8601String(),
          });

      widget.onAdd(nuevoGasto);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el gasto: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _fecha) {
      setState(() {
        _fecha = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _fecha.hour,
          _fecha.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _montoController,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _categoria,
              items: [
                'Comida',
                'Transporte',
                'Entretenimiento',
                'Otros',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _categoria = value);
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fecha: ${_fecha.toLocal().toString().split(' ')[0]}'),
                TextButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Cambiar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarGasto,
              child: const Text('Guardar Gasto'),
            ),
          ],
        ),
      ),
    );
  }
}

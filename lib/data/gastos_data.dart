import '../models/gasto.dart';

final List<Gasto> gastosDummy = [
  Gasto(
    id: 'g1',
    descripcion: 'Café en Starbucks',
    monto: 100.0,
    categoria: 'Comida',
    fecha: DateTime.now().subtract(Duration(hours: 2)),
  ),
  Gasto(
    id: 'g2',
    descripcion: 'Uber al Tec',
    monto: 120.0,
    categoria: 'Transporte',
    fecha: DateTime.now().subtract(Duration(days: 1)),
  ),
];

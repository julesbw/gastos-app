class Gasto {
  final String id;
  final String descripcion;
  final double monto;
  final String categoria;
  final DateTime fecha;

  Gasto({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });
}

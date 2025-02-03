class Article {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? codigoBarras;
  final bool estado;
  final bool iva;
  final bool manejoLotes;
  final String categoria;
  final String creadoEn;
  final int stockTotal;

  Article({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.codigoBarras,
    required this.estado,
    required this.iva,
    required this.manejoLotes,
    required this.categoria,
    required this.creadoEn,
    required this.stockTotal,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      codigoBarras: json['codigo_barras'],
      estado: json['estado'] == 1,
      iva: json['iva'] == 1,
      manejoLotes: json['manejo_lotes'] == 1,
      categoria: json['categoria'],
      creadoEn: json['creado_en'],
      stockTotal: json['stock_total'] ?? 0,
    );
  }
}

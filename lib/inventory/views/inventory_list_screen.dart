import 'package:flutter/material.dart';
import '../../colors.dart';
import 'inventory_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/articulo.dart';
import '../services/inventory_service.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<Article> _articles = [];
  late  InventoryService _inventoryService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      // Si no hay token, redirigir al login
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    _inventoryService = InventoryService(
      baseUrl: 'http://localhost:8000', // Ajusta esto a tu URL
      token: token,
    );

    _loadArticles();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    // Solo actualizamos el servicio si el token ha cambiado
    if (_inventoryService.token != token) {
      _inventoryService = InventoryService(
        baseUrl: 'http://localhost:8000',
        token: token,
      );
      _loadArticles(); // Recargamos los artículos con el nuevo token
    }
  }

  Future<void> _loadArticles() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final articles = await _inventoryService.getArticles();
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // Si el error es de autenticación, redirigir al login
      if (e.toString().contains('401') || e.toString().contains('403')) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _searchArticles(String query) async {
    setState(() => _isLoading = true);

    try {
      final articles = await _inventoryService.getArticles(search: query);
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inventario',

          style: TextStyle(
            color: kNeutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kNeutralDark),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar artículo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                _searchArticles(value);
              },
            ),
          ),

          // Mensaje de error
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: kErrorColor),
              ),
            ),

          // Lista de artículos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadArticles,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        return _buildArticleCard(_articles[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InventoryFormScreen(),
            ),
          );
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildArticleCard(Article article) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _showAddBatchDialog(),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            icon: Icons.add_box_outlined,
            label: 'Nuevo Lote',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
        color: Colors.white,
        child: InkWell(
          onTap: () => _showArticleDetails(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kNeutralDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Categoría: ${article.categoria}'),
                Text('Stock Total: ${article.stockTotal}'),
                if (article.codigoBarras != null)
                  Text('Código: ${article.codigoBarras}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddBatchDialog() {
    final formKey = GlobalKey<FormState>();
    DateTime? selectedDate; // Agregamos esta variable


    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Lote'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Costo unitario'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Precio de venta'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Depósito'),
                  items: const [], // Aquí irán los depósitos desde tu API
                  onChanged: (value) {},
                  validator: (value) =>
                      value == null ? 'Seleccione un depósito' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Fecha de vencimiento',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                     if (date != null) {
                      selectedDate = date; // Guardamos la fecha seleccionada
                      (context as Element).markNeedsBuild();
                    }
                  },
                  
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                // Guardar nuevo lote
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showArticleDetails() {
    // Implementar vista de detalles del artículo
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detalles del Artículo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNeutralDark,
                ),
              ),
              const SizedBox(height: 16),
              // Información detallada del artículo
              _buildDetailItem('Nombre', 'Nombre del Artículo'),
              _buildDetailItem('Categoría', 'Categoría'),
              _buildDetailItem('Código', 'ABC123'),
              _buildDetailItem('Stock Total', '100'),
              _buildDetailItem('Maneja IVA', 'Sí'),
              _buildDetailItem('Maneja Lotes', 'Sí'),

              const SizedBox(height: 24),
              const Text(
                'Lotes Activos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kNeutralDark,
                ),
              ),
              const SizedBox(height: 12),
              // Lista de lotes
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3, // Esto vendrá de tu API
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    title: Text('Lote #${index + 1}'),
                    subtitle: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: 50'),
                        Text('Depósito: Principal'),
                        Text('Vencimiento: 2024-12-31'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kNeutralDark,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

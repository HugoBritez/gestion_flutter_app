import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../colors.dart';
import '../services/inventory_service.dart';
import '../../auth/providers/auth_provider.dart';

class InventoryFormScreen extends StatefulWidget {
  const InventoryFormScreen({super.key});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _manejaLotes = false;
  bool _manejaIva = false;
  String? _selectedCategoria;
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _depositos = [];
  int? _selectedDeposito;
  DateTime? _fechaVencimiento;

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _costoController = TextEditingController();
  final _precioController = TextEditingController();
  final _ubicacionController = TextEditingController();

  late InventoryService _inventoryService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

Future<void> _initializeService() async {
    print('==========================================');
    print('🚀 INICIANDO SERVICIO DE INVENTARIO');
    print('==========================================');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        print('❌ TOKEN NULO - Redirigiendo a login');
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      print('✅ Token encontrado: ${token.substring(0, 10)}...');
      _inventoryService = InventoryService(
        baseUrl: 'http://localhost:8000',
        token: token,
      );

      print('🔄 Iniciando carga de datos...');

      // Cargar categorías
      print('📂 Intentando obtener categorías...');
      final categorias = await _inventoryService.getCategories();
      print('✅ Categorías obtenidas exitosamente');
      setState(() {
        _categorias = categorias;
      });

      // Cargar depósitos
      print('🏢 Intentando obtener depósitos...');
      final depositos = await _inventoryService.getDeposits();
      print('✅ Depósitos obtenidos exitosamente');
      if (mounted) {
        setState(() {
          _depositos = depositos;
        });
      }
    } catch (e) {
      print('❌ ERROR GENERAL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
    print('==========================================');
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Crear el artículo
      final articleData = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'codigo_barras': _codigoController.text,
        'categoria': _selectedCategoria,
        'manejo_lotes': _manejaLotes,
        'iva': _manejaIva,
      };

      await _inventoryService.createArticle(articleData);

      // Si maneja lotes y hay datos de lote, crear el primer lote
      if (_manejaLotes && _selectedDeposito != null) {
        final batchData = {
          'cantidad': int.parse(_cantidadController.text),
          'costo_unitario': double.parse(_costoController.text),
          'precio_venta': double.parse(_precioController.text),
          'deposito_id': _selectedDeposito,
          'ubicacion': _ubicacionController.text,
          'fecha_vencimiento': _fechaVencimiento?.toIso8601String(),
        };

        await _inventoryService.createBatch(0,
            batchData); // El ID del artículo debería venir de la respuesta de createArticle
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo creado exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nuevo Artículo',
          style: TextStyle(
            color: kNeutralDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kNeutralDark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration:
                          _buildInputDecoration('Nombre', Icons.inventory),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: _buildInputDecoration(
                          'Descripción', Icons.description),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codigoController,
                      decoration: _buildInputDecoration(
                          'Código de barras', Icons.qr_code),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration:
                          _buildInputDecoration('Categoría', Icons.category),
                      value: _selectedCategoria,
                      items: _categorias.map((categoria) {
                        return DropdownMenuItem(
                          value: categoria['id'].toString(),
                          child: Text(categoria['nombre']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategoria = value);
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione una categoría' : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Maneja IVA'),
                      value: _manejaIva,
                      onChanged: (value) {
                        setState(() => _manejaIva = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Maneja Lotes'),
                      value: _manejaLotes,
                      onChanged: (value) {
                        setState(() => _manejaLotes = value);
                      },
                    ),
                    if (_manejaLotes) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Primer Lote',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kNeutralDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cantidadController,
                        decoration:
                            _buildInputDecoration('Cantidad', Icons.numbers),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _costoController,
                        decoration: _buildInputDecoration(
                            'Costo unitario', Icons.attach_money),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _precioController,
                        decoration: _buildInputDecoration(
                            'Precio de venta', Icons.price_change),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                     DropdownButtonFormField<int>(
                        decoration:
                            _buildInputDecoration('Depósito', Icons.store),
                        value: _selectedDeposito,
                        hint: const Text(
                            'Seleccione un depósito'), // Agregar hint
                        items: _depositos.map((deposito) {
                          print(
                              'Creando item para depósito: $deposito'); // Debug print
                          return DropdownMenuItem<int>(
                            value: deposito['id'] as int,
                            child: Text(deposito['nombre'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          print('Depósito seleccionado: $value'); // Debug print
                          setState(() => _selectedDeposito = value);
                        },
                        validator: (value) =>
                            value == null ? 'Seleccione un depósito' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ubicacionController,
                        decoration:
                            _buildInputDecoration('Ubicación', Icons.place),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                          'Fecha de vencimiento',
                          Icons.calendar_today,
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              _fechaVencimiento?.toString().split(' ')[0] ?? '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setState(() => _fechaVencimiento = date);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveArticle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    _cantidadController.dispose();
    _costoController.dispose();
    _precioController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }
}

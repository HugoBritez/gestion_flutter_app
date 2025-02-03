import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../colors.dart';
import 'package:flutter/services.dart';

class RegisterEmpresaScreen extends StatefulWidget {
  const RegisterEmpresaScreen({super.key});

  @override
  State<RegisterEmpresaScreen> createState() => _RegisterEmpresaScreenState();
}

class _RegisterEmpresaScreenState extends State<RegisterEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Controladores para datos de la empresa
  final _nombreEmpresaController = TextEditingController();
  final _rutController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailEmpresaController = TextEditingController();

  // Controladores para datos del administrador
  final _nombreAdminController = TextEditingController();
  final _emailAdminController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nombreEmpresaController.dispose();
    _rutController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailEmpresaController.dispose();
    _nombreAdminController.dispose();
    _emailAdminController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: kPrimaryColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: kBackgroundLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      isCollapsed: false,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      labelStyle: TextStyle(
        color: kNeutralDark.withOpacity(0.7),
      ),

      hintStyle: TextStyle(
        color: kNeutralDark.withOpacity(0.5),
      ),
      prefixIconColor: kPrimaryColor,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kErrorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kErrorColor, width: 1),
      ),
    );
  }

  Future<void> _registerEmpresa() async {
    if (_formKey.currentState!.validate()) {
      try {
        final codigoInvitacion =
            await context.read<AuthProvider>().registerEmpresa(
                  nombreEmpresa: _nombreEmpresaController.text,
                  rut: _rutController.text,
                  direccion: _direccionController.text,
                  telefono: _telefonoController.text,
                  emailEmpresa: _emailEmpresaController.text,
                  nombreAdmin: _nombreAdminController.text,
                  emailAdmin: _emailAdminController.text,
                  username: _usernameController.text,
                  password: _passwordController.text,
                );

        if (!mounted) return;

        // Mostrar diálogo con el código de invitación
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: kBackgroundLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            title: const Text(
              'Registro Exitoso',
              style: TextStyle(
                color: kNeutralDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'La empresa ha sido registrada correctamente.',
                  style: TextStyle(color: kNeutralDark),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Código de invitación:',
                  style: TextStyle(
                    color: kNeutralDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kBackgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kNeutralDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SelectableText(
                          codigoInvitacion,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kNeutralDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: kNeutralDark),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: codigoInvitacion));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código copiado al portapapeles'),
                              backgroundColor: kNeutralDark,
                              duration:  Duration(seconds: 2),

                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Guarde este código. Lo necesitará para invitar a otros usuarios.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kNeutralDark,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(); // Volver a login
                },
                style: TextButton.styleFrom(
                  
                  foregroundColor: kPrimaryColor,
                ),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: kErrorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kNeutralDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sección datos de la empresa
                    const Text(
                      'Registro de Empresa',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kNeutralDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registra tu empresa y comienza a gestionarla de manera eficiente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Datos de la Empresa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kNeutralDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEmpresaFields(),
                    const SizedBox(height: 32),

                    // Sección datos del administrador
                    const Text(
                      'Datos del Administrador',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kNeutralDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAdminFields(),
                    const SizedBox(height: 32),

                    // Botón de registro
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return ElevatedButton(
                          onPressed: auth.isLoading ? null : _registerEmpresa,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: kPrimaryColor,
                            foregroundColor: kNeutralLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            shadowColor: kPrimaryColor.withOpacity(0.5),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      kNeutralLight,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Registrar Empresa',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpresaFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nombreEmpresaController,
          decoration: _buildInputDecoration(
            label: 'Nombre de la Empresa',
            hint: 'Ingrese el nombre de la empresa',
            icon: Icons.business,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese el nombre de la empresa';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _rutController,
          decoration: _buildInputDecoration(
            label: 'RUC',
            hint: 'Ingrese el RUC de la empresa',
            icon: Icons.numbers,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese el RUC';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _direccionController,
          decoration: _buildInputDecoration(
            label: 'Dirección',
            hint: 'Ingrese la dirección de la empresa',
            icon: Icons.location_on,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese la dirección';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _telefonoController,
          keyboardType: TextInputType.phone,
          decoration: _buildInputDecoration(
            label: 'Teléfono',
            hint: 'Ingrese el teléfono de la empresa',
            icon: Icons.phone,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese el teléfono';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailEmpresaController,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            label: 'Email de la Empresa',
            hint: 'Ingrese el email de la empresa',
            icon: Icons.email,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese el email';
            }
            if (!value.contains('@')) {
              return 'Por favor ingrese un email válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdminFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nombreAdminController,
          decoration: _buildInputDecoration(
            label: 'Nombre del Administrador',
            hint: 'Ingrese su nombre completo',
            icon: Icons.person,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese su nombre';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailAdminController,
          keyboardType: TextInputType.emailAddress,
          decoration: _buildInputDecoration(
            label: 'Email del Administrador',
            hint: 'Ingrese su email',
            icon: Icons.email,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese su email';
            }
            if (!value.contains('@')) {
              return 'Por favor ingrese un email válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _usernameController,
          decoration: _buildInputDecoration(
            label: 'Nombre de Usuario',
            hint: 'Ingrese un nombre de usuario',
            icon: Icons.account_circle,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese un nombre de usuario';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _buildInputDecoration(
            label: 'Contraseña',
            hint: 'Ingrese su contraseña',
            icon: Icons.lock,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: kPrimaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese una contraseña';
            }
            if (value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }
}

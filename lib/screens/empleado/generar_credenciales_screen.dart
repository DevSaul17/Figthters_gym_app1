import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';

class GenerarCredencialesScreen extends StatefulWidget {
  const GenerarCredencialesScreen({super.key});

  @override
  State<GenerarCredencialesScreen> createState() =>
      _GenerarCredencialesScreenState();
}

class _GenerarCredencialesScreenState extends State<GenerarCredencialesScreen> {
  late ScrollController _scrollController;
  String? _clienteIdSeleccionado;
  String _usuarioGenerado = '';
  String _contrasenaGenerada = '';
  bool _mostrarContrasena = false;
  bool _isGenerando = false;

  // Controladores para contraseña manual
  final TextEditingController _contrasenaManualController =
      TextEditingController();
  final TextEditingController _verificarContrasenaController =
      TextEditingController();
  bool _mostrarContrasenaManual = false;
  bool _mostrarVerificarContrasena = false;

  List<Map<String, dynamic>> _clientes = [];
  bool _cargandoClientes = true;
  String _dniClienteSeleccionado = '';

  List<Map<String, dynamic>> _credencialesCreadas = [];
  bool _cargandoCredenciales = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _cargarClientes();
    _cargarCredencialesCreadas();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _contrasenaManualController.dispose();
    _verificarContrasenaController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    try {
      // Primero obtener todas las membresías para saber qué clientes tienen
      final membresiaSnapshot = await FirebaseFirestore.instance
          .collection('membresias')
          .get();

      final clienteIds = <String>{};
      for (var doc in membresiaSnapshot.docs) {
        final data = doc.data();
        final clienteId = data['clienteId'];
        if (clienteId != null) {
          clienteIds.add(clienteId.toString());
        }
      }

      // Si no hay membresías, mostrar lista vacía
      if (clienteIds.isEmpty) {
        if (mounted) {
          setState(() {
            _clientes = [];
            _cargandoClientes = false;
          });
        }
        return;
      }

      // Obtener todas las credenciales ya generadas
      final credencialesSnapshot = await FirebaseFirestore.instance
          .collection('credenciales')
          .get();

      final clientesConCredenciales = <String>{};
      for (var doc in credencialesSnapshot.docs) {
        clientesConCredenciales.add(doc.id);
      }

      // Obtener solo los clientes que tienen membresías
      final snapshot = await FirebaseFirestore.instance
          .collection('clientes')
          .get();
      final clientes = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        // Solo incluir si el cliente tiene membresías Y NO tiene credenciales generadas
        if (clienteIds.contains(doc.id) &&
            !clientesConCredenciales.contains(doc.id)) {
          final data = doc.data();
          clientes.add({
            'id': doc.id,
            'nombre': data['nombre'] ?? '',
            'apellidos': data['apellidos'] ?? '',
            'dni': data['dni'] ?? '',
          });
        }
      }

      if (mounted) {
        setState(() {
          _clientes = clientes;
          _cargandoClientes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoClientes = false;
        });
        _mostrarError('Error al cargar clientes: $e');
      }
    }
  }

  Future<void> _cargarCredencialesCreadas() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('credenciales')
          .get();

      final credenciales = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        credenciales.add({
          'id': doc.id,
          'nombre': data['nombre'] ?? '',
          'apellidos': data['apellidos'] ?? '',
          'usuario': data['usuario'] ?? '',
          'creadoEn': data['creadoEn'],
        });
      }

      if (mounted) {
        setState(() {
          _credencialesCreadas = credenciales;
          _cargandoCredenciales = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cargandoCredenciales = false;
        });
        _mostrarError('Error al cargar credenciales: $e');
      }
    }
  }

  Future<void> _generarCredenciales() async {
    if (_clienteIdSeleccionado == null) {
      _mostrarError('Selecciona un cliente');
      return;
    }

    // Validar que las contraseñas se hayan ingresado
    if (_contrasenaManualController.text.isEmpty) {
      _mostrarError('Ingresa una contraseña');
      return;
    }

    if (_verificarContrasenaController.text.isEmpty) {
      _mostrarError('Verifica la contraseña');
      return;
    }

    // Validar que las contraseñas coincidan
    if (_contrasenaManualController.text !=
        _verificarContrasenaController.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    // Validar que la contraseña tenga al menos 6 caracteres
    if (_contrasenaManualController.text.length < 6) {
      _mostrarError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    final cliente = _clientes.firstWhere(
      (c) => c['id'] == _clienteIdSeleccionado,
    );
    final usuario = cliente['dni'] ?? '';
    final contrasena = _contrasenaManualController.text;
    final contrasenaHash = sha256.convert(contrasena.codeUnits).toString();

    setState(() {
      _isGenerando = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('credenciales')
          .doc(_clienteIdSeleccionado)
          .set({
            'clienteId': _clienteIdSeleccionado,
            'nombre': cliente['nombre'],
            'apellidos': cliente['apellidos'],
            'usuario': usuario,
            'contrasena': contrasenaHash,
            'creadoEn': FieldValue.serverTimestamp(),
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      setState(() {
        _usuarioGenerado = usuario;
        _contrasenaGenerada = contrasena;
        _contrasenaManualController.clear();
        _verificarContrasenaController.clear();
      });

      _mostrarMensaje('Credenciales generadas exitosamente', Colors.green);
    } catch (e) {
      _mostrarError('Error al guardar credenciales: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerando = false;
        });
      }
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    _mostrarMensaje(mensaje, Colors.red);
  }

  void _copiarAlPortapapeles(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
    _mostrarMensaje('Copiado al portapapeles', Colors.green);
  }

  void _mostrarModalCambiarContrasena(String clienteId, String nombreCliente) {
    final contraController = TextEditingController();
    final verificarController = TextEditingController();
    bool mostrarContra = false;
    bool mostrarVerificar = false;
    bool isChanging = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
            'Cambiar Contraseña',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    nombreCliente,
                    style: AppTextStyles.mainText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: contraController,
                  obscureText: !mostrarContra,
                  decoration: InputDecoration(
                    hintText: 'Nueva contraseña',
                    prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarContra ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setStateDialog(() {
                          mostrarContra = !mostrarContra;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: verificarController,
                  obscureText: !mostrarVerificar,
                  decoration: InputDecoration(
                    hintText: 'Verificar contraseña',
                    prefixIcon: Icon(Icons.verified, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        mostrarVerificar
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setStateDialog(() {
                          mostrarVerificar = !mostrarVerificar;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isChanging ? null : () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: isChanging
                  ? null
                  : () async {
                      if (contraController.text.isEmpty) {
                        _mostrarError('Ingresa la nueva contraseña');
                        return;
                      }
                      if (verificarController.text.isEmpty) {
                        _mostrarError('Verifica la contraseña');
                        return;
                      }
                      if (contraController.text != verificarController.text) {
                        _mostrarError('Las contraseñas no coinciden');
                        return;
                      }
                      if (contraController.text.length < 6) {
                        _mostrarError(
                          'La contraseña debe tener al menos 6 caracteres',
                        );
                        return;
                      }

                      setStateDialog(() {
                        isChanging = true;
                      });

                      try {
                        final nuevaContrasena = contraController.text;
                        final nuevaContrasenaHash = sha256
                            .convert(nuevaContrasena.codeUnits)
                            .toString();

                        await FirebaseFirestore.instance
                            .collection('credenciales')
                            .doc(clienteId)
                            .update({
                              'contrasena': nuevaContrasenaHash,
                              'ultimaActualizacion':
                                  FieldValue.serverTimestamp(),
                            });

                        if (mounted) {
                          _mostrarMensaje(
                            'Contraseña actualizada exitosamente',
                            Colors.green,
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // Recargar credenciales
                          _cargarCredencialesCreadas();
                        }
                      } catch (e) {
                        _mostrarError('Error al cambiar contraseña: $e');
                      } finally {
                        setStateDialog(() {
                          isChanging = false;
                        });
                      }
                    },
              icon: Icon(isChanging ? Icons.hourglass_bottom : Icons.check),
              label: Text(isChanging ? 'Guardando...' : 'Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: Text(
          'Generar Credenciales',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _cargandoClientes
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card informativo
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Selecciona un cliente y genera credenciales de acceso',
                              style: AppTextStyles.contactText.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    if (_clientes.isEmpty) ...[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay clientes con membresía',
                              style: AppTextStyles.mainText.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Para generar credenciales, los clientes deben tener una membresía activa.',
                              style: AppTextStyles.mainText.copyWith(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Selector de cliente
                      Text(
                        'Seleccionar Cliente',
                        style: AppTextStyles.mainText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: SizedBox(),
                          value: _clienteIdSeleccionado,
                          hint: Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text('Elige un cliente'),
                          ),
                          items: _clientes.map((cliente) {
                            return DropdownMenuItem<String>(
                              value: cliente['id'],
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  '${cliente['nombre']} ${cliente['apellidos']}',
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _clienteIdSeleccionado = newValue;
                              _usuarioGenerado = '';
                              _contrasenaGenerada = '';
                              _contrasenaManualController.clear();
                              _verificarContrasenaController.clear();

                              // Obtener DNI del cliente seleccionado
                              if (newValue != null) {
                                final clienteSeleccionado = _clientes
                                    .firstWhere(
                                      (cliente) => cliente['id'] == newValue,
                                      orElse: () => {},
                                    );
                                _dniClienteSeleccionado =
                                    clienteSeleccionado['dni'] ?? 'N/A';
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 24),

                      // Mostrar DNI del cliente seleccionado
                      if (_clienteIdSeleccionado != null) ...[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.badge, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DNI del Cliente',
                                      style: AppTextStyles.mainText.copyWith(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _dniClienteSeleccionado,
                                      style: AppTextStyles.mainText.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),

                        // Campos de contraseña manual
                        Text(
                          'Contraseña',
                          style: AppTextStyles.mainText.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 12),

                        // Campo de contraseña
                        TextField(
                          controller: _contrasenaManualController,
                          obscureText: !_mostrarContrasenaManual,
                          decoration: InputDecoration(
                            hintText: 'Ingresa la contraseña',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarContrasenaManual
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarContrasenaManual =
                                      !_mostrarContrasenaManual;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Campo de verificación de contraseña
                        TextField(
                          controller: _verificarContrasenaController,
                          obscureText: !_mostrarVerificarContrasena,
                          decoration: InputDecoration(
                            hintText: 'Verifica la contraseña',
                            prefixIcon: Icon(Icons.verified),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarVerificarContrasena
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarVerificarContrasena =
                                      !_mostrarVerificarContrasena;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                      ],

                      // Botón generar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerando ? null : _generarCredenciales,
                          icon: Icon(
                            _isGenerando
                                ? Icons.hourglass_bottom
                                : Icons.security,
                          ),
                          label: Text(
                            _isGenerando
                                ? 'Generando...'
                                : 'Generar Credenciales',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 32),

                    // Mostrar credenciales generadas
                    if (_usuarioGenerado.isNotEmpty &&
                        _contrasenaGenerada.isNotEmpty) ...[
                      Text(
                        'Credenciales Generadas',
                        style: AppTextStyles.mainText.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Card Usuario
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Usuario',
                                  style: AppTextStyles.contactText.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _usuarioGenerado,
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 18),
                                    onPressed: () {
                                      _copiarAlPortapapeles(_usuarioGenerado);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Card Contraseña
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lock, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Contraseña',
                                  style: AppTextStyles.contactText.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _mostrarContrasena
                                          ? _contrasenaGenerada
                                          : '•' * _contrasenaGenerada.length,
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _mostrarContrasena
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _mostrarContrasena =
                                            !_mostrarContrasena;
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy, size: 18),
                                    onPressed: () {
                                      _copiarAlPortapapeles(
                                        _contrasenaGenerada,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // Advertencia
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Guarda estas credenciales en lugar seguro',
                                style: AppTextStyles.contactText.copyWith(
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 48),

                    // Sección de credenciales creadas
                    Text(
                      'Credenciales Creadas',
                      style: AppTextStyles.mainText.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 16),

                    if (_cargandoCredenciales)
                      Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    else if (_credencialesCreadas.isEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Sin credenciales creadas',
                                style: AppTextStyles.mainText.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...(_credencialesCreadas.map((credencial) {
                        final fecha = credencial['creadoEn'] != null
                            ? DateFormat('dd/MM/yyyy HH:mm').format(
                                (credencial['creadoEn'] as Timestamp).toDate(),
                              )
                            : 'N/A';

                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${credencial['nombre']} ${credencial['apellidos']}',
                                              style: AppTextStyles.mainText
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'Usuario: ${credencial['usuario']}',
                                              style: AppTextStyles.contactText
                                                  .copyWith(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          _mostrarModalCambiarContrasena(
                                            credencial['id'],
                                            '${credencial['nombre']} ${credencial['apellidos']}',
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Creado: $fecha',
                                      style: AppTextStyles.contactText.copyWith(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList()),
                  ],
                ),
              ),
            ),
    );
  }
}

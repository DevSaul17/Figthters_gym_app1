import 'package:flutter/material.dart';
import '../services/sync_service.dart';

/// Widget que muestra las operaciones pendientes de sincronización
///
/// Características:
/// - Badge con contador de operaciones pendientes
/// - Panel expandible con lista detallada de operaciones
/// - Actualización en tiempo real usando ValueListenableBuilder
/// - Diseño compacto que no interfiere con la UI principal
class PendingOperationsWidget extends StatefulWidget {
  const PendingOperationsWidget({super.key});

  @override
  State<PendingOperationsWidget> createState() =>
      _PendingOperationsWidgetState();
}

class _PendingOperationsWidgetState extends State<PendingOperationsWidget> {
  final SyncService _syncService = SyncService();
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _syncService.pendingOperationsCount,
      builder: (context, count, child) {
        // No mostrar nada si no hay operaciones pendientes
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Badge con contador
            _buildBadge(count),

            // Panel expandible con lista de operaciones
            if (_isExpanded) _buildOperationsList(),
          ],
        );
      },
    );
  }

  /// Badge clickeable que muestra el contador de operaciones pendientes
  Widget _buildBadge(int count) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.shade700,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              '$count pendiente${count > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Panel con lista detallada de operaciones pendientes
  Widget _buildOperationsList() {
    return ValueListenableBuilder<List<PendingOperation>>(
      valueListenable: _syncService.pendingOperations,
      builder: (context, operations, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Operaciones pendientes',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      'Sincronizarán automáticamente',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de operaciones
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: operations.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final operation = operations[index];
                    return _buildOperationItem(operation);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Item individual de operación pendiente
  Widget _buildOperationItem(PendingOperation operation) {
    IconData icon;
    Color iconColor;
    String statusText;

    switch (operation.status) {
      case PendingOperationStatus.waiting:
        icon = Icons.wifi_off;
        iconColor = Colors.red;
        statusText = 'Esperando conexión';
        break;
      case PendingOperationStatus.pending:
        icon = Icons.schedule;
        iconColor = Colors.orange;
        statusText = 'En cola';
        break;
      case PendingOperationStatus.synced:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        statusText = 'Sincronizada';
        break;
    }

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(
        operation.name,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '$statusText • ${operation.timeAgo}',
        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
      ),
    );
  }
}

/// Widget Badge simple para mostrar solo el contador (versión minimalista)
///
/// Uso: Para mostrar en AppBar o lugares con espacio limitado
class PendingOperationsBadge extends StatelessWidget {
  const PendingOperationsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final syncService = SyncService();

    return ValueListenableBuilder<int>(
      valueListenable: syncService.pendingOperationsCount,
      builder: (context, count, child) {
        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sync, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

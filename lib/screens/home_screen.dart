import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import 'patient_form_screen.dart';
import 'patient_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _databaseService = DatabaseService();

  List<Patient> _patients = [];
  bool _isLoading = true;
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patients = await _databaseService.getPatients(onlyActive: _showOnlyActive);
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pacientes: $e')),
        );
      }
    }
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o paciente ${patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _databaseService.deletePatient(patient.id!);
      _loadPatients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paciente excluído com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir paciente: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InsuGuia Mobile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<bool>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _showOnlyActive = value;
              });
              _loadPatients();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: true,
                child: Text('Pacientes Ativos'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Todos os Pacientes'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showOnlyActive ? 'Nenhum paciente ativo' : 'Nenhum paciente cadastrado',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toque no botão + para adicionar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPatients,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _patients.length,
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      return _buildPatientCard(patient);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PatientFormScreen(),
            ),
          );
          if (result == true) {
            _loadPatients();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Paciente'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.isDischarged ? Colors.grey : Colors.blue,
          child: Text(
            patient.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                patient.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (patient.isDischarged)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Alta',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${patient.age} anos | ${patient.sex == 'M' ? 'Masculino' : 'Feminino'}'),
            Text(
              patient.admissionLocation,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('Ver Detalhes'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'view':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailScreen(patientId: patient.id!),
                  ),
                );
                break;
              case 'edit':
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientFormScreen(patient: patient),
                  ),
                );
                if (result == true) {
                  _loadPatients();
                }
                break;
              case 'delete':
                _deletePatient(patient);
                break;
            }
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(patientId: patient.id!),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/discharge_instruction.dart';
import '../models/prescription.dart';
import '../models/glycemic_reading.dart';
import '../services/database_service.dart';
import '../services/prescription_service.dart';

class DischargeScreen extends StatefulWidget {
  final Patient patient;

  const DischargeScreen({super.key, required this.patient});

  @override
  State<DischargeScreen> createState() => _DischargeScreenState();
}

class _DischargeScreenState extends State<DischargeScreen> {
  final _databaseService = DatabaseService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _alreadyDischarged = false;

  DischargeInstruction? _dischargeInstruction;
  Prescription? _prescription;
  List<GlycemicReading> _readings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final existingDischarge = await _databaseService.getDischargeInstruction(widget.patient.id!);

      if (existingDischarge != null) {
        setState(() {
          _dischargeInstruction = existingDischarge;
          _alreadyDischarged = true;
          _isLoading = false;
        });
        return;
      }

      final prescription = await _databaseService.getPrescription(widget.patient.id!);
      final readings = await _databaseService.getGlycemicReadings(widget.patient.id!);

      final instructions = PrescriptionService.generateDischargeInstructions(widget.patient);
      final summary = prescription != null
          ? PrescriptionService.generateTreatmentSummary(widget.patient, prescription, readings)
          : 'Prescrição não disponível';

      setState(() {
        _prescription = prescription;
        _readings = readings;
        _dischargeInstruction = DischargeInstruction(
          patientId: widget.patient.id!,
          instructions: instructions,
          treatmentSummary: summary,
          dischargeDate: DateTime.now(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _confirmDischarge() async {
    if (_dischargeInstruction == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Alta'),
        content: const Text(
          'Deseja confirmar a alta hospitalar deste paciente? Esta ação marcará o paciente como inativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar Alta'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_dischargeInstruction!.id == null) {
        await _databaseService.createDischargeInstruction(_dischargeInstruction!);
      }

      final updatedPatient = widget.patient.copyWith(isDischarged: true);
      await _databaseService.updatePatient(updatedPatient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alta hospitalar realizada com sucesso!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao processar alta: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alta Hospitalar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dischargeInstruction == null
              ? const Center(child: Text('Erro ao gerar orientações de alta'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patient.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Local: ${widget.patient.admissionLocation}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.summarize, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Resumo do Tratamento',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text(
                                _dischargeInstruction!.treatmentSummary,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.medical_information, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Orientações de Alta',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Text(
                                _dischargeInstruction!.instructions,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_alreadyDischarged) ...[
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _confirmDischarge,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: Text(_isSaving ? 'Processando...' : 'Confirmar Alta Hospitalar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ] else ...[
                        Card(
                          color: Colors.green[50],
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Alta hospitalar já realizada para este paciente.',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

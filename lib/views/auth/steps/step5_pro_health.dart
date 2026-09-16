// =============================================================
// ChefUnitPlus - Etape 5 : Pro / Sante / Camps / Contacts
// =============================================================

import 'package:flutter/material.dart';
import 'package:chefunitplus/core/constants/app_colors.dart';
import 'package:chefunitplus/models/scout_camp.dart';
import 'package:chefunitplus/models/emergency_contact.dart';
import '../register_wizard_screen.dart';

class Step5ProHealth extends StatefulWidget {
  final RegisterWizardScreenState state;

  const Step5ProHealth({super.key, required this.state});

  @override
  State<Step5ProHealth> createState() => _Step5ProHealthState();
}

class _Step5ProHealthState extends State<Step5ProHealth> {
  // Formulaire CAMP
  bool _showCampForm = false;
  final _campNom = TextEditingController();
  final _campLieu = TextEditingController();
  final _campRole = TextEditingController(text: 'Participant');
  DateTime _campDebut = DateTime.now();
  DateTime _campFin = DateTime.now().add(const Duration(days: 7));

  // Formulaire CONTACT
  bool _showContactForm = false;
  final _contactNom = TextEditingController();
  final _contactRel = TextEditingController();
  final _contactTel = TextEditingController();
  final _contactTel2 = TextEditingController();
  final _contactAdr = TextEditingController();

  @override
  void dispose() {
    _campNom.dispose();
    _campLieu.dispose();
    _campRole.dispose();
    _contactNom.dispose();
    _contactRel.dispose();
    _contactTel.dispose();
    _contactTel2.dispose();
    _contactAdr.dispose();
    super.dispose();
  }

  // ===========================================================
  // CAMPS
  // ===========================================================
  void _openCampForm() {
    _campNom.clear();
    _campLieu.clear();
    _campRole.text = 'Participant';
    _campDebut = DateTime.now();
    _campFin = DateTime.now().add(const Duration(days: 7));
    setState(() => _showCampForm = true);
  }

  Future<void> _pickCampDate({required bool isDebut}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? _campDebut : _campFin,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isDebut) {
          _campDebut = picked;
        } else {
          _campFin = picked;
        }
      });
    }
  }

  void _submitCamp() {
    if (_campNom.text.trim().isEmpty || _campLieu.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom et lieu du camp sont requis'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final camp = ScoutCamp(
      id: '',
      userId: '',
      nom: _campNom.text.trim(),
      lieu: _campLieu.text.trim(),
      dateDebut: _campDebut,
      dateFin: _campFin,
      role: _campRole.text.trim().isEmpty
          ? 'Participant'
          : _campRole.text.trim(),
    );

    widget.state.camps.add(camp);
    widget.state.refresh();
    setState(() => _showCampForm = false);
  }

  // ===========================================================
  // CONTACTS
  // ===========================================================
  void _openContactForm() {
    _contactNom.clear();
    _contactRel.clear();
    _contactTel.clear();
    _contactTel2.clear();
    _contactAdr.clear();
    setState(() => _showContactForm = true);
  }

  void _submitContact() {
    if (_contactNom.text.trim().isEmpty ||
        _contactTel.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom et telephone sont requis'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final contact = EmergencyContact(
      id: '',
      userId: '',
      nomComplet: _contactNom.text.trim(),
      relation: _contactRel.text.trim(),
      telephone: _contactTel.text.trim(),
      telephoneSecondaire: _contactTel2.text.trim().isEmpty
          ? null
          : _contactTel2.text.trim(),
      adresse: _contactAdr.text.trim().isEmpty
          ? null
          : _contactAdr.text.trim(),
    );

    widget.state.contactsUrgence.add(contact);
    widget.state.refresh();
    setState(() => _showContactForm = false);
  }

  // ===========================================================
  // BUILD
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- PROFESSION ----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.successSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.work_outline,
                    color: AppColors.successDark, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informations complementaires (optionnel)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: s.professionCtrl,
            decoration: const InputDecoration(
              labelText: 'Profession',
              hintText: 'Ex : Enseignant',
              prefixIcon: Icon(Icons.work_outline),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: s.antecedentsCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Antecedents medicaux',
              hintText: 'Allergies, maladies...',
              prefixIcon: Icon(Icons.medical_information_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // ---- CAMPS ----
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Camps scouts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_showCampForm)
                TextButton.icon(
                  onPressed: _openCampForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showCampForm) _buildCampForm(),
          if (s.camps.isEmpty && !_showCampForm)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucun camp ajoute',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            ...s.camps
                .asMap()
                .entries
                .map((e) => _buildCampCard(e.key, e.value)),

          const SizedBox(height: 24),

          // ---- CONTACTS ----
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Contacts d\'urgence',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_showContactForm)
                TextButton.icon(
                  onPressed: _openContactForm,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showContactForm) _buildContactForm(),
          if (s.contactsUrgence.isEmpty && !_showContactForm)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Aucun contact ajoute',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            ...s.contactsUrgence
                .asMap()
                .entries
                .map((e) => _buildContactCard(e.key, e.value)),
        ],
      ),
    );
  }

  // ===========================================================
  // FORM CAMP
  // ===========================================================
  Widget _buildCampForm() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.kaki, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nouveau camp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.kakiDark,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _campNom,
              decoration: const InputDecoration(
                labelText: 'Nom du camp *',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _campLieu,
              decoration: const InputDecoration(
                labelText: 'Lieu *',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _campRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _pickCampDate(isDebut: true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date debut',
                  isDense: true,
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(
                  '${_campDebut.day}/${_campDebut.month}/${_campDebut.year}',
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _pickCampDate(isDebut: false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date fin',
                  isDense: true,
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                ),
                child: Text(
                  '${_campFin.day}/${_campFin.month}/${_campFin.year}',
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showCampForm = false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitCamp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kaki,
                    ),
                    child: const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // FORM CONTACT
  // ===========================================================
  Widget _buildContactForm() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.mauve, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nouveau contact d\'urgence',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.mauveDark,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contactNom,
              decoration: const InputDecoration(
                labelText: 'Nom complet *',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactRel,
              decoration: const InputDecoration(
                labelText: 'Relation (Pere, Mere...)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactTel,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telephone *',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactTel2,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telephone 2 (optionnel)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactAdr,
              decoration: const InputDecoration(
                labelText: 'Adresse (optionnel)',
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _showContactForm = false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mauve,
                    ),
                    child: const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // CARTE CAMP
  // ===========================================================
  Widget _buildCampCard(int index, ScoutCamp camp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading:
            const Icon(Icons.flag_outlined, color: AppColors.kakiDark),
        title: Text(
          camp.nom,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${camp.lieu} - ${camp.periodeLabel}\nRole : ${camp.role}',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: AppColors.danger,
            size: 20,
          ),
          onPressed: () {
            widget.state.camps.removeAt(index);
            widget.state.refresh();
            setState(() {});
          },
        ),
      ),
    );
  }

  // ===========================================================
  // CARTE CONTACT
  // ===========================================================
  Widget _buildContactCard(int index, EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: const Icon(
          Icons.contact_phone_outlined,
          color: AppColors.mauve,
        ),
        title: Text(
          contact.nomComplet,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${contact.relation} - ${contact.telephone}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
            color: AppColors.danger,
            size: 20,
          ),
          onPressed: () {
            widget.state.contactsUrgence.removeAt(index);
            widget.state.refresh();
            setState(() {});
          },
        ),
      ),
    );
  }
}
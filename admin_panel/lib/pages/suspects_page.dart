import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../widgets/animated_entry.dart';
import '../models/suspect.dart';
import '../services/suspect_service.dart';

class SuspectsPage extends StatefulWidget {
  const SuspectsPage({super.key});

  @override
  State<SuspectsPage> createState() => _SuspectsPageState();
}

class _SuspectsPageState extends State<SuspectsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SideBar(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AnimatedEntry(
                delay: 0,
                child: TopBar(title: "Suspects"),
              ),

              const SizedBox(height: 20),

              AnimatedEntry(
                delay: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => openAddDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Suspect"),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: AnimatedEntry(
                  delay: 200,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: StreamBuilder<List<Suspect>>(
                      stream: SuspectService.streamSuspects(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final suspects = snapshot.data!;

                        return Theme(
                          data: Theme.of(context).copyWith(
                            cardColor: const Color(0xFF1A1A1A),
                            dividerColor: Colors.white12,
                            dataTableTheme: const DataTableThemeData(
                              headingTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              dataTextStyle: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          child: PaginatedDataTable(
                            header: const Text(
                              "Suspects List",
                              style: TextStyle(color: Colors.white),
                            ),
                            rowsPerPage: 8,
                            columns: const [
                              DataColumn(label: Text("Name")),
                              DataColumn(label: Text("Age")),
                              DataColumn(label: Text("Gender")),
                              DataColumn(label: Text("Address")),
                              DataColumn(label: Text("Case No")),
                              DataColumn(label: Text("Notes")),
                              DataColumn(label: Text("Actions")),
                            ],
                            source: _SuspectsTableSource(
                              suspects,
                              onEdit: (s) => openEditDialog(context, s),
                              onDelete: (s) =>
                                  SuspectService.deleteSuspect(s.id),
                            ),
                          ),
                        );
                      },
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

  // ========================= DIALOGS =========================

  void openAddDialog(BuildContext context) {
    final name = TextEditingController();
    final age = TextEditingController();
    String gender = 'Male';
    final address = TextEditingController();
    final caseNo = TextEditingController();
    final notes = TextEditingController();

    _showSuspectDialog(
      context,
      title: "Add Suspect",
      onSave: () {
        SuspectService.addSuspect(
          Suspect(
            id: "",
            name: name.text,
            age: int.tryParse(age.text) ?? 0,
            gender: gender,
            address: address.text,
            caseNumber: caseNo.text,
            notes: notes.text,
          ),
        );
      },
      fields: [
        _darkField(name, "Name"),
        _darkField(age, "Age", number: true),
        _genderDropdown((v) => gender = v!, selected: gender),
        _darkField(address, "Address"),
        _darkField(caseNo, "Case Number"),
        _darkField(notes, "Notes"),
      ],
    );
  }

  void openEditDialog(BuildContext context, Suspect s) {
    final name = TextEditingController(text: s.name);
    final age = TextEditingController(text: s.age.toString());
    String gender = s.gender;
    final address = TextEditingController(text: s.address);
    final caseNo = TextEditingController(text: s.caseNumber);
    final notes = TextEditingController(text: s.notes);

    _showSuspectDialog(
      context,
      title: "Edit Suspect",
      onSave: () {
        SuspectService.updateSuspect(
          Suspect(
            id: s.id,
            name: name.text,
            age: int.tryParse(age.text) ?? 0,
            gender: gender,
            address: address.text,
            caseNumber: caseNo.text,
            notes: notes.text,
          ),
        );
      },
      fields: [
        _darkField(name, "Name"),
        _darkField(age, "Age", number: true),
        _genderDropdown((v) => gender = v!, selected: gender),
        _darkField(address, "Address"),
        _darkField(caseNo, "Case Number"),
        _darkField(notes, "Notes"),
      ],
    );
  }

  // ========================= DIALOG UI =========================

  void _showSuspectDialog(
    BuildContext context, {
    required String title,
    required VoidCallback onSave,
    required List<Widget> fields,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(children: fields),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ========================= FIELDS =========================

  static Widget _darkField(
    TextEditingController c,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1F1F23),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }

  static Widget _genderDropdown(
    ValueChanged<String?> onChanged, {
    required String selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selected,
        dropdownColor: const Color(0xFF1F1F23),
        decoration: InputDecoration(
          labelText: "Gender",
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1F1F23),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: Colors.deepPurpleAccent),
          ),
        ),
        style: const TextStyle(color: Colors.white),
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
          DropdownMenuItem(value: "Other", child: Text("Other")),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

// ========================= TABLE SOURCE =========================

class _SuspectsTableSource extends DataTableSource {
  final List<Suspect> suspects;
  final Function(Suspect) onEdit;
  final Function(Suspect) onDelete;

  _SuspectsTableSource(
    this.suspects, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    final s = suspects[index];

    return DataRow(cells: [
      DataCell(Text(s.name)),
      DataCell(Text(s.age.toString())),
      DataCell(Text(s.gender)),
      DataCell(Text(s.address)),
      DataCell(Text(s.caseNumber)),
      DataCell(Text(s.notes)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(s),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(s),
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => suspects.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}

import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
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
      backgroundColor: const Color(0xFF111111),
      body: SideBar(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const TopBar(title: "Suspects"),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => openAddDialog(context),
                  child: const Text("Add Suspect"),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<Suspect>>(
                  stream: SuspectService.streamSuspects(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final suspects = snapshot.data!;

                    return PaginatedDataTable(
                      header: const Text("Suspects List"),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ADD DIALOG
  void openAddDialog(BuildContext context) {
    final name = TextEditingController();
    final age = TextEditingController();
    String gender = 'Male';
    final address = TextEditingController();
    final caseNo = TextEditingController();
    final notes = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Suspect"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                field(name, "Name"),
                field(age, "Age", number: true),
                genderDropdown((val) => gender = val!),
                field(address, "Address"),
                field(caseNo, "Case Number"),
                field(notes, "Notes"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),

          ElevatedButton(
            onPressed: () {
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
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // EDIT DIALOG
  void openEditDialog(BuildContext context, Suspect s) {
    final name = TextEditingController(text: s.name);
    final age = TextEditingController(text: s.age.toString());
    String gender = s.gender;
    final address = TextEditingController(text: s.address);
    final caseNo = TextEditingController(text: s.caseNumber);
    final notes = TextEditingController(text: s.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Suspect"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                field(name, "Name"),
                field(age, "Age", number: true),
                genderDropdown((val) => gender = val!, selected: gender),
                field(address, "Address"),
                field(caseNo, "Case Number"),
                field(notes, "Notes"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),

          ElevatedButton(
            onPressed: () {
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
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // INPUT FIELD
  Widget field(TextEditingController c, String hint, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // GENDER DROPDOWN
  Widget genderDropdown(ValueChanged<String?> onChanged, {String selected = 'Male'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selected,
        decoration: const InputDecoration(
          labelText: "Gender",
          border: OutlineInputBorder(),
        ),
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

// TABLE SOURCE
class _SuspectsTableSource extends DataTableSource {
  final List<Suspect> suspects;
  final Function(Suspect) onEdit;
  final Function(Suspect) onDelete;

  _SuspectsTableSource(this.suspects,
      {required this.onEdit, required this.onDelete});

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
              onPressed: () => onEdit(s)),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(s)),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => suspects.length;

  @override
  int get selectedRowCount => 0;
}

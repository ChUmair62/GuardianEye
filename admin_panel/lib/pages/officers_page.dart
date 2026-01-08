import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../widgets/animated_entry.dart';
import '../services/officer_service.dart';
import '../models/officer.dart';

class OfficersPage extends StatefulWidget {
  const OfficersPage({super.key});

  @override
  State<OfficersPage> createState() => _OfficersPageState();
}

class _OfficersPageState extends State<OfficersPage> {
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
                child: TopBar(title: "Officers"),
              ),

              const SizedBox(height: 20),

              AnimatedEntry(
                delay: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => openAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Officer"),
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
                    child: StreamBuilder<List<Officer>>(
                      stream: OfficerService.streamOfficers(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final officers = snapshot.data!;

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
                              "Officers List",
                              style: TextStyle(color: Colors.white),
                            ),
                            rowsPerPage: 8,
                            columns: const [
                              DataColumn(label: Text("Name")),
                              DataColumn(label: Text("Rank")),
                              DataColumn(label: Text("Department")),
                              DataColumn(label: Text("Badge No")),
                              DataColumn(label: Text("Email")),
                              DataColumn(label: Text("Phone")),
                              DataColumn(label: Text("Actions")),
                            ],
                            source: _OfficersTableSource(
                              officers,
                              onEdit: (o) => openEditDialog(context, o),
                              onDelete: (o) =>
                                  OfficerService.deleteOfficer(o.id),
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
    final rank = TextEditingController();
    final department = TextEditingController();
    final badge = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();

    _showOfficerDialog(
      context,
      title: "Add Officer",
      onSave: () {
        OfficerService.addOfficer(
          Officer(
            id: "",
            name: name.text,
            rank: rank.text,
            department: department.text,
            badgeNumber: badge.text,
            email: email.text,
            phone: phone.text,
          ),
        );
      },
      fields: [
        _darkField(name, "Name"),
        _darkField(rank, "Rank"),
        _darkField(department, "Department"),
        _darkField(badge, "Badge Number"),
        _darkField(email, "Email"),
        _darkField(phone, "Phone"),
      ],
    );
  }

  void openEditDialog(BuildContext context, Officer o) {
    final name = TextEditingController(text: o.name);
    final rank = TextEditingController(text: o.rank);
    final department = TextEditingController(text: o.department);
    final badge = TextEditingController(text: o.badgeNumber);
    final email = TextEditingController(text: o.email);
    final phone = TextEditingController(text: o.phone);

    _showOfficerDialog(
      context,
      title: "Edit Officer",
      onSave: () {
        OfficerService.updateOfficer(
          Officer(
            id: o.id,
            name: name.text,
            rank: rank.text,
            department: department.text,
            badgeNumber: badge.text,
            email: email.text,
            phone: phone.text,
          ),
        );
      },
      fields: [
        _darkField(name, "Name"),
        _darkField(rank, "Rank"),
        _darkField(department, "Department"),
        _darkField(badge, "Badge Number"),
        _darkField(email, "Email"),
        _darkField(phone, "Phone"),
      ],
    );
  }

  // ========================= DIALOG UI =========================

  void _showOfficerDialog(
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
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  static Widget _darkField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1F1F23),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.deepPurpleAccent),
          ),
        ),
      ),
    );
  }
}

// ========================= TABLE SOURCE =========================

class _OfficersTableSource extends DataTableSource {
  final List<Officer> officers;
  final Function(Officer) onEdit;
  final Function(Officer) onDelete;

  _OfficersTableSource(
    this.officers, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    final o = officers[index];

    return DataRow(cells: [
      DataCell(Text(o.name)),
      DataCell(Text(o.rank)),
      DataCell(Text(o.department)),
      DataCell(Text(o.badgeNumber)),
      DataCell(Text(o.email)),
      DataCell(Text(o.phone)),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(o),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(o),
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => officers.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}

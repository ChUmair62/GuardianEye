import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
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
      backgroundColor: const Color(0xFF111111),
      body: SideBar(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const TopBar(title: "Officers"),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => openAddDialog(context),
                  child: const Text("Add Officer"),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<Officer>>(
                  stream: OfficerService.streamOfficers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final officers = snapshot.data!;

                    return PaginatedDataTable(
                      header: const Text("Officers List"),
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

  // OPEN ADD DIALOG
  void openAddDialog(BuildContext context) {
    final name = TextEditingController();
    final rank = TextEditingController();
    final department = TextEditingController();
    final badge = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Officer"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                field(name, "Name"),
                field(rank, "Rank"),
                field(department, "Department"),
                field(badge, "Badge Number"),
                field(email, "Email"),
                field(phone, "Phone"),
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
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // OPEN EDIT DIALOG
  void openEditDialog(BuildContext context, Officer o) {
    final name = TextEditingController(text: o.name);
    final rank = TextEditingController(text: o.rank);
    final department = TextEditingController(text: o.department);
    final badge = TextEditingController(text: o.badgeNumber);
    final email = TextEditingController(text: o.email);
    final phone = TextEditingController(text: o.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Officer"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                field(name, "Name"),
                field(rank, "Rank"),
                field(department, "Department"),
                field(badge, "Badge Number"),
                field(email, "Email"),
                field(phone, "Phone"),
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
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget field(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
            labelText: hint, border: const OutlineInputBorder()),
      ),
    );
  }
}

// TABLE SOURCE
class _OfficersTableSource extends DataTableSource {
  final List<Officer> officers;
  final Function(Officer) onEdit;
  final Function(Officer) onDelete;

  _OfficersTableSource(this.officers, {required this.onEdit, required this.onDelete});

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
              onPressed: () => onEdit(o)),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(o)),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => officers.length;

  @override
  int get selectedRowCount => 0;
}

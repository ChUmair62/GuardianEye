import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';
import '../widgets/animated_entry.dart';
import '../models/interview.dart';
import '../models/officer.dart';
import '../models/suspect.dart';
import '../services/interview_service.dart';
import '../services/officer_service.dart';
import '../services/suspect_service.dart';
import 'package:url_launcher/url_launcher.dart';

class InterviewsPage extends StatefulWidget {
  const InterviewsPage({super.key});

  @override
  State<InterviewsPage> createState() => _InterviewsPageState();
}

class _InterviewsPageState extends State<InterviewsPage> {
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
              // Page Title
              const AnimatedEntry(
                delay: 0,
                child: TopBar(title: "Interviews"),
              ),

              const SizedBox(height: 20),

              // Add Button
              AnimatedEntry(
                delay: 100,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => openAddDialog(context),
                    icon: const Icon(Icons.video_call),
                    label: const Text("Add Interview"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Table
              Expanded(
                child: AnimatedEntry(
                  delay: 200,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: StreamBuilder<List<Interview>>(
                      stream: InterviewService.streamInterviews(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final interviews = snap.data!;

                        return FutureBuilder<Map<String, String>>(
                          future: _loadNames(),
                          builder: (context, mapSnap) {
                            if (!mapSnap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final names = mapSnap.data!;

                            return PaginatedDataTable(
                              header: const Text(
                                "Interviews List",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              rowsPerPage: 8,
                              columns: const [
                                DataColumn(label: Text("Officer")),
                                DataColumn(label: Text("Suspect")),
                                DataColumn(label: Text("Video Link")),
                                DataColumn(label: Text("Timestamp")),
                                DataColumn(label: Text("Actions")),
                              ],
                              source: _InterviewsTableSource(
                                interviews,
                                names,
                                onEdit: (i) =>
                                    openEditDialog(context, i, names),
                                onDelete: (i) =>
                                    InterviewService.deleteInterview(i.id),
                              ),
                            );
                          },
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

  // ================== DATA LOADING (UNCHANGED) ==================

  Future<Map<String, String>> _loadNames() async {
    final officers = await OfficerService.getAllOfficersOnce();
    final suspects = await SuspectService.getAllSuspectsOnce();

    return {
      for (var o in officers) o.id: o.name,
      for (var s in suspects) s.id: s.name,
    };
  }

  // ================== DIALOGS (UNCHANGED) ==================

  void openAddDialog(BuildContext context) {
    String? officerId;
    String? suspectId;
    final videoLink = TextEditingController();
    final transcript = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Interview"),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              officersDropdown((v) => officerId = v),
              suspectsDropdown((v) => suspectId = v),
              textField(videoLink, "Video URL"),
              textField(transcript, "Transcript", maxLines: 4),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (officerId != null &&
                  suspectId != null &&
                  videoLink.text.isNotEmpty) {
                InterviewService.addInterview(
                  Interview(
                    id: "",
                    officerId: officerId!,
                    suspectId: suspectId!,
                    videoUrl: videoLink.text,
                    transcript: transcript.text,
                    timestamp: DateTime.now(),
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void openEditDialog(
    BuildContext context,
    Interview i,
    Map<String, String> names,
  ) {
    String officerId = i.officerId;
    String suspectId = i.suspectId;

    final videoLink = TextEditingController(text: i.videoUrl);
    final transcript = TextEditingController(text: i.transcript);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Edit Interview"),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  officersDropdown(
                    (v) => setState(() => officerId = v!),
                    selected:
                        names.containsKey(officerId) ? officerId : null,
                  ),
                  suspectsDropdown(
                    (v) => setState(() => suspectId = v!),
                    selected:
                        names.containsKey(suspectId) ? suspectId : null,
                  ),
                  textField(videoLink, "Video URL"),
                  textField(transcript, "Transcript", maxLines: 4),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  InterviewService.updateInterview(
                    Interview(
                      id: i.id,
                      officerId: officerId,
                      suspectId: suspectId,
                      videoUrl: videoLink.text,
                      transcript: transcript.text,
                      timestamp: i.timestamp,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              )
            ],
          );
        },
      ),
    );
  }

  // ================== INPUT HELPERS (UNCHANGED) ==================

  Widget officersDropdown(
    ValueChanged<String?> onChanged, {
    String? selected,
  }) {
    return StreamBuilder<List<Officer>>(
      stream: OfficerService.streamOfficers(),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();

        return DropdownButtonFormField<String>(
          value: selected,
          decoration: const InputDecoration(
            labelText: "Officer",
            border: OutlineInputBorder(),
          ),
          items: snap.data!
              .map((o) =>
                  DropdownMenuItem(value: o.id, child: Text(o.name)))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  Widget suspectsDropdown(
    ValueChanged<String?> onChanged, {
    String? selected,
  }) {
    return StreamBuilder<List<Suspect>>(
      stream: SuspectService.streamSuspects(),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();

        return DropdownButtonFormField<String>(
          value: selected,
          decoration: const InputDecoration(
            labelText: "Suspect",
            border: OutlineInputBorder(),
          ),
          items: snap.data!
              .map((s) =>
                  DropdownMenuItem(value: s.id, child: Text(s.name)))
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }

  Widget textField(
    TextEditingController c,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// ================== TABLE SOURCE (UNCHANGED) ==================

class _InterviewsTableSource extends DataTableSource {
  final List<Interview> interviews;
  final Map<String, String> names;
  final Function(Interview) onEdit;
  final Function(Interview) onDelete;

  _InterviewsTableSource(
    this.interviews,
    this.names, {
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    final i = interviews[index];

    return DataRow(cells: [
      DataCell(Text(names[i.officerId] ?? "Unknown")),
      DataCell(Text(names[i.suspectId] ?? "Unknown")),
      DataCell(
        InkWell(
          onTap: () async {
            final url = Uri.parse(i.videoUrl);
            if (await canLaunchUrl(url)) {
              await launchUrl(
                url,
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: const Text(
            "Open Video",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
      DataCell(Text(i.timestamp.toString())),
      DataCell(Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(i),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(i),
          ),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => interviews.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

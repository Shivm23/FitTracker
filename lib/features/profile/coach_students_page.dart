import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'student_macros_page.dart';

class CoachStudentsPage extends StatefulWidget {
  const CoachStudentsPage({super.key});

  @override
  State<CoachStudentsPage> createState() => _CoachStudentsPageState();
}

class _CoachStudentsPageState extends State<CoachStudentsPage> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    final supabase = locator<SupabaseClient>();
    final coachId = supabase.auth.currentUser?.id;
    if (coachId == null) return [];

    final List<Map<String, dynamic>> response = await supabase
        .from('users')
        .select('id, display_name')
        .eq('coach_id', coachId);

    return response
        .map((e) => {
              'id': e['id'],
              'name': e['display_name'] ?? e['id'],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).myStudentsTitle),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              return Center(
                  child:
                      Text('${S.of(context).errorPrefix} ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!;
          if (students.isEmpty) {
            return Center(child: Text(S.of(context).noStudents));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final studentId = student['id'].toString();
              final studentName = student['name'].toString();

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.outline),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentMacrosPage(
                          studentId: studentId,
                          studentName: studentName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        studentName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

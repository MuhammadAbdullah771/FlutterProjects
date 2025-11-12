import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/task.dart';

class ExportService {
  Future<File> exportCsv(List<Task> tasks) async {
    final rows = <List<dynamic>>[
      [
        'Title',
        'Description',
        'Due Date',
        'Priority',
        'Completed',
        'Repeats',
        'Tags',
        'Subtasks',
      ],
    ];
    for (final task in tasks) {
      rows.add([
        task.title,
        task.description ?? '',
        task.dueDate?.toIso8601String() ?? '',
        task.priority.label,
        task.isCompleted ? 'Yes' : 'No',
        task.isRepeating ? task.repeatType.label : 'None',
        task.tags.map((t) => t.name).join(', '),
        task.subtasks
            .map((s) => '${s.title}(${s.isDone ? 'done' : 'pending'})')
            .join(' | '),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(dir.path, 'tasks_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv'),
    );
    await file.writeAsString(csvData, flush: true);
    return file;
  }

  Future<Uint8List> exportPdfBytes(List<Task> tasks) async {
    final pdf = pw.Document();
    final dateFmt = DateFormat('EEE, d MMM h:mm a');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Task Export',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.TableHelper.fromTextArray(
            cellPadding: const pw.EdgeInsets.all(4),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blueGrey50),
            headers: const [
              'Title',
              'Due',
              'Priority',
              'Completed',
              'Repeats',
              'Tags',
            ],
            data: tasks.map((task) {
              return [
                task.title,
                task.dueDate != null ? dateFmt.format(task.dueDate!) : 'None',
                task.priority.label,
                task.isCompleted ? 'Yes' : 'No',
                task.isRepeating ? task.repeatType.label : 'No',
                task.tags.map((t) => t.name).join(', '),
              ];
            }).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Generated ${DateFormat.yMMMMd().add_jm().format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
            textAlign: pw.TextAlign.right,
          ),
        ],
      ),
    );
    return pdf.save();
  }
}

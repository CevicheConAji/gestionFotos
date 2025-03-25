import 'dart:io';

class PhotoModel {
  final File file;
  final String fileName;
  final DateTime createdAt;
  bool isSelected;

  PhotoModel({
    required this.file,
    required this.fileName,
    required this.createdAt,
    this.isSelected = false,
  });

  /// Constructor desde archivo
  factory PhotoModel.fromFile(File file) {
    final stat = file.statSync();
    final name = file.path.split('/').last;
    return PhotoModel(
      file: file,
      fileName: name,
      createdAt:
          stat.modified, // También puedes usar stat.changed o created si aplica
    );
  }

  /// Para ordenar por fecha (ascendente)
  static int compareByDateAsc(PhotoModel a, PhotoModel b) {
    return a.createdAt.compareTo(b.createdAt);
  }

  /// Para ordenar por nombre (opcional)
  static int compareByName(PhotoModel a, PhotoModel b) {
    return a.fileName.compareTo(b.fileName);
  }
}

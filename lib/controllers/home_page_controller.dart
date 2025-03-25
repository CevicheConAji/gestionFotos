import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/photo_model.dart';
import '../services/upload_service.dart';

class HomePageController extends ChangeNotifier {
  List<PhotoModel> _photos = [];
  List<PhotoModel> get photos => _photos;

  final ImagePicker _picker = ImagePicker();

  /// Cargar imágenes desde galería y guardarlas localmente
  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles == null) return;

    final directory = await getApplicationDocumentsDirectory();
    int counter = _photos.length;

    for (final xfile in pickedFiles) {
      final File originalFile = File(xfile.path);
      final String fileName = _generateCorrelativeName(++counter);
      final String newPath = '${directory.path}/$fileName.jpg';
      final File copied = await originalFile.copy(newPath);

      final photo = PhotoModel.fromFile(copied);
      _photos.add(photo);
    }

    _sortPhotosByDate();
    notifyListeners();
  }

  String _generateCorrelativeName(int index) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';
    final indexStr = index.toString().padLeft(2, '0');
    return 'IMG_${timestamp}_$indexStr';
  }

  void _sortPhotosByDate() {
    _photos.sort(PhotoModel.compareByDateAsc);
  }

  void toggleSelection(PhotoModel photo) {
    photo.isSelected = !photo.isSelected;
    notifyListeners();
  }

  void clearSelection() {
    for (final photo in _photos) {
      photo.isSelected = false;
    }
    notifyListeners();
  }

  void deleteSelected() {
    _photos.removeWhere((photo) {
      if (photo.isSelected) {
        photo.file.deleteSync();
        return true;
      }
      return false;
    });
    notifyListeners();
  }

  Future<void> uploadSelected() async {
    final selectedPhotos = _photos.where((p) => p.isSelected).toList();
    selectedPhotos.sort(PhotoModel.compareByDateAsc);
    if (selectedPhotos.isEmpty) return;

    await UploadService.uploadPhotosInOrder(
      selectedPhotos,
      folderName: 'nombre_carpeta_personalizado',
    );
    clearSelection();
  }

  /// Utilidad para generar nombre único basado en fecha/hora
  String _generateTimestampName() {
    final now = DateTime.now();
    return '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

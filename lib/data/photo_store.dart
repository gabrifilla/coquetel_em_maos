import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Escolhe uma foto (câmera ou galeria) e guarda uma cópia na pasta do app.
class PhotoStore {
  PhotoStore({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Retorna o caminho da cópia salva, ou null se o usuário desistiu.
  Future<String?> pick({required bool fromCamera}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'fotos'));
    await dir.create(recursive: true);
    final ext = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final target = p.join(
      dir.path,
      '${DateTime.now().microsecondsSinceEpoch}$ext',
    );
    await File(picked.path).copy(target);
    return target;
  }

  Future<void> delete(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

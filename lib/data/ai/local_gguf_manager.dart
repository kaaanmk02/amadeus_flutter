import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Offline GGUF model yönetimi.
class LocalGgufManager {
  LocalGgufManager._();
  static final LocalGgufManager instance = LocalGgufManager._();

  bool _ready = false;
  bool get isReady => _ready;
  String? _modelPath;
  String? get modelPath => _modelPath;

  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final candidate = File('${dir.path}/model.gguf');
      _modelPath = candidate.existsSync() ? candidate.path : null;
      _ready = true;
    } on Exception catch (_) {
      _ready = false;
    }
  }

  Future<String?> pickModel() async {
    await init();
    if (modelPath == null) return null;
    return modelPath;
  }
}
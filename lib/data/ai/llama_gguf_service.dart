import 'dart:io';
import 'package:flutter/services.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/app_config.dart';

class LlamaGgufService {
  LlamaGgufService._();
  static final LlamaGgufService instance = LlamaGgufService._();

  LlamaController? _controller;
  LlamaController get controller => _controller!;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<String> localModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${AppConfig.localModelFileName}';
  }

  Future<bool> downloadModel() async {
    try {
      final path = await localModelPath();
      final file = File(path);
      if (file.existsSync()) return true;
      await file.create(recursive: true);
      final url =
          'https://huggingface.co/${AppConfig.localModelHfRepo}/resolve/main/${AppConfig.localModelHfFile}';
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(url));
      final resp = await req.close();
      if (resp.statusCode != 200) return false;
      final sink = file.openWrite();
      await resp.pipe(sink);
      await sink.flush();
      await sink.close();
      return file.existsSync();
    } on Exception catch (_) {
      return false;
    }
  }

  Future<bool> loadModel() async {
    try {
      if (_loaded) return true;
      final path = await localModelPath();
      final file = File(path);
      if (!file.existsSync()) return false;
      _controller = LlamaController();
      await _controller!.loadModel(
        modelPath: path,
        threads: AppConfig.localModelThreads,
        contextSize: AppConfig.localModelContextSize,
      );
      _loaded = true;
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Stream<String> generateStream(String prompt) {
    if (!_loaded || _controller == null) {
      return const Stream.empty();
    }
    return _controller!.generate(
      prompt: prompt,
      maxTokens: 256,
      temperature: 0.7,
    );
  }

  Future<void> dispose() async {
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
    _loaded = false;
  }
}
import 'dart:io';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/app_config.dart';

class LlamaGgufService {
  LlamaGgufService._();
  static final LlamaGgufService instance = LlamaGgufService._();
  LlamaController? _controller;
  bool _loaded = false;
  bool get isLoaded => _loaded;
  String? lastError;

  Future<String> localModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/${AppConfig.localModelFileName}';
  }

  Future<bool> downloadModel() async {
    final target = File(await localModelPath());
    final temp = File('${target.path}.part');
    HttpClient? client;
    try {
      if (await target.exists() && await target.length() > 100000000) return true;
      if (await target.exists()) await target.delete();
      if (await temp.exists()) await temp.delete();
      await target.parent.create(recursive: true);
      const url = 'https://huggingface.co/${AppConfig.localModelHfRepo}/resolve/main/${AppConfig.localModelHfFile}?download=true';
      client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 45));
      request.followRedirects = true;
      final response = await request.close().timeout(const Duration(seconds: 90));
      if (response.statusCode != HttpStatus.ok) {
        lastError = 'Model sunucusu HTTP ${response.statusCode} döndürdü.';
        return false;
      }
      await response.pipe(temp.openWrite()).timeout(const Duration(minutes: 90));
      final length = await temp.length();
      if (length < 100000000) {
        lastError = 'İndirilen GGUF dosyası beklenenden küçük; dosya reddedildi.';
        await temp.delete();
        return false;
      }
      await temp.rename(target.path);
      lastError = null;
      return true;
    } on Exception catch (e) {
      lastError = 'Model indirilemedi: $e';
      if (await temp.exists()) await temp.delete();
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  Future<bool> loadModel({String? modelPath}) async {
    if (_loaded && _controller != null) return true;
    LlamaController? candidate;
    try {
      final path = modelPath ?? await localModelPath();
      final file = File(path);
      if (!await file.exists() || await file.length() < 100000000) {
        lastError = 'GGUF dosyası bulunamadı veya eksik.';
        return false;
      }
      candidate = LlamaController();
      await candidate.loadModel(modelPath: path, threads: AppConfig.localModelThreads, contextSize: AppConfig.localModelContextSize);
      _controller = candidate;
      _loaded = true;
      lastError = null;
      return true;
    } on Exception catch (e) {
      lastError = 'Model yüklenemedi: $e';
      try { await candidate?.dispose(); } catch (_) {}
      _controller = null;
      _loaded = false;
      return false;
    }
  }

  Stream<String> generateStream(String prompt) {
    if (!_loaded || _controller == null) return Stream.error(StateError('GGUF modeli yüklenmemiş.'));
    return _controller!.generate(prompt: prompt, maxTokens: 256, temperature: 0.7);
  }

  Future<void> dispose() async {
    try { await _controller?.dispose(); } catch (_) {}
    _controller = null;
    _loaded = false;
  }
}

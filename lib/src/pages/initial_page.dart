import 'package:flutter/material.dart';
import 'package:speechtotext/src/services/deepseek.dart';
import 'package:speechtotext/src/services/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speechtotext/src/services/text_to_speech.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final STTService _speechService = STTService();
  final TTSService _ttsService = TTSService();
  final DeepSeekService _deepSeekService = DeepSeekService();
  String _lastWords = '';
  String _response = '';

  @override
  void initState() {
    super.initState();
    _speechService.initSpeech();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
    if (!_speechService.isListening) {
      print(_lastWords);
      sendMessage(_lastWords);
    }
  }

  void sendMessage(String text) async {
    final response = await _deepSeekService.getChatResponse(text);
    setState(() {
      _response = response;
    });
    print(_response);
    _ttsService.speak(_response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: const Text(
          'Chat de voz con IA',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 28),
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechService.isNotListening
            ? () {
                _speechService.startListening(_onSpeechResult);
                setState(() {
                  _lastWords = '';
                });
              }
            : _speechService.stopListening,
        child: Icon(_speechService.isNotListening ? Icons.mic_off : Icons.mic),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.all(10),
                child: const Text(
                  'Hola, pregunta lo que quieras...',
                  style: TextStyle(fontSize: 25),
                )),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Text(
                _lastWords.isNotEmpty
                    ? _lastWords
                    : _speechService.isNotListening
                        ? 'Activa el micrófono para hablar...'
                        : 'Habla ahora...',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            Expanded(
                child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              alignment: Alignment.bottomCenter,
              child: IconButton(
                  onPressed: () {
                    _ttsService.stop();
                  },
                  icon: const Icon(Icons.stop)),
            ))
          ],
        ),
      ),
    );
  }
}

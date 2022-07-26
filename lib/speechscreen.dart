import 'package:avatar_glow/avatar_glow.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_recognisation_app/command.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = true;
  String text = 'Press the button and start speaking';
  //getting 'confidence' value while talking is in range of 0 to 1.
  //set initial value to 1.0
  double confidence = 1.0;
  bool _copyButtonClicked = false;

  final Map<String, HighlightedWord> _highlights = {
    "go to": HighlightedWord(
      onTap: () {
        // print("Flutter");
      },
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    "open": HighlightedWord(
      onTap: () {
        // print("Flutter");
      },
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    "write email": HighlightedWord(
      onTap: () {
        // print("Flutter");
      },
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    "flutter": HighlightedWord(
      onTap: () {
        // print("Flutter");
      },
      textStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      ),
    ),
    "voice": HighlightedWord(
      onTap: () {
        // print("voice");
      },
      textStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    ),
    "subscribe": HighlightedWord(
      onTap: () {
        // print("subscribe");
      },
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    "like": HighlightedWord(
      onTap: () {
        // print("like");
      },
      textStyle: const TextStyle(
        color: Colors.blueGrey,
        fontWeight: FontWeight.bold,
      ),
    ),
    "GITHUB": HighlightedWord(
      onTap: () {
        // print("like");
      },
      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text('Confidence: ${(confidence * 100).toStringAsFixed(1)} %'),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              if (_copyButtonClicked)
                Positioned(
                  top: 15,
                  right: 40,
                  child: Container(
                    width: 50,
                    height: 20,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                        child: Text(
                      'Copied',
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
              IconButton(
                tooltip: 'copied',
                onPressed: () async {
                  await FlutterClipboard.copy(text);
                  setState(() {
                    _copyButtonClicked = true;
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() {
                    _copyButtonClicked = false;
                  });
                },
                icon: const Icon(Icons.content_copy),
              ),
            ],
          )

          // Builder(builder: (context) {
          //   return IconButton(
          //     tooltip: 'copied',
          //     onPressed: () async {
          //       ScaffoldMessenger.of(context)
          //           .showSnackBar(const SnackBar(content: Text('Copied to Clipboard')));

          //       await FlutterClipboard.copy(text);
          //       setState(() {
          //         _copyButtonClicked = true;
          //       });
          //     },
          //     icon: const Icon(Icons.content_copy),
          //   );
          // }),
        ],
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: TextHighlight(
            // if text is empty string (text : ''), then we get error
            text: text,
            words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: floatButtonWithAvatarGlow(context),
    );
  }

  Column floatButtonWithAvatarGlow(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AvatarGlow(
          animate: !isListening,
          endRadius: 75,
          repeat: true,
          glowColor: Theme.of(context).primaryColor,
          duration: const Duration(milliseconds: 2000),
          repeatPauseDuration: const Duration(milliseconds: 100),
          child: FloatingActionButton(
            onPressed: _listen,
            child: Icon(isListening ? Icons.mic_none : Icons.mic),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 40),
          child: Text(
            ' There is a time limit on listening imposed by both Android and iOS. The time  depends on the device, network, etc. Android is usually quite short,  especially if there is no active speech event detected',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  void _listen() async {
    if (isListening) {
      bool speechEnabled = await speech.initialize(
        onError: (errorNotification) => print('onError: $errorNotification'),
        onStatus: (status) => print("onStatus: $status"),
      );
      if (speechEnabled) {
        setState(() {
          isListening = false;
        });
        await speech.listen(
          listenFor: const Duration(minutes: 10),
          onResult: (result) {
            setState(() {
              text = result.recognizedWords;
              if (result.hasConfidenceRating && result.confidence > 0) {
                confidence = result.confidence;
              }
            });
          },
        );
      }
    } else {
      await speech.stop();
      setState(() {
        isListening = true;
      });
      await Future.delayed(const Duration(seconds: 1), () {
        Utils.scanText(text);
      });
    }
  }
}

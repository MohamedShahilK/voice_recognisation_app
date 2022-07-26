import 'package:url_launcher/url_launcher.dart';

class Command {
  static final all = [email, browser1, browser2];

  static const email = 'write email';
  static const browser1 = 'open';
  static const browser2 = 'go to';
}

class Utils {
  static Future<void> scanText(String rawText) async {
    final text = rawText.toLowerCase();

    if (text.contains(Command.email)) {
      final body = _getTextAfterCommand(text: text, command: Command.email);
      await openEmail(body: body);
    } else if (text.contains(Command.browser1)) {
      final body = _getTextAfterCommand(text: text, command: Command.browser1);
      await openLink(body: body);
    }else if (text.contains(Command.browser2)) {
      final body = _getTextAfterCommand(text: text, command: Command.browser2);
      await openLink(body: body);
    }
  }

  static String? _getTextAfterCommand({
    required String text,
    required String command,
  }) {
    //get "first index of the word"
    final indexCommand = text.indexOf(command);

    // get "last index of word plus 1" (means gets index after the command ends)
    final indexAfter = indexCommand + command.length;

    if (indexCommand == -1) {
      return null;
    } else {
      //trim removes spaces in right and left.Then takes the value at that index
      return text.substring(indexAfter).trim();
    }
  }

  static Future openEmail({String? body}) async {
    if (body == null) {
      return;
    }
    final Uri url = Uri.parse('mailto: ?body=${Uri.encodeFull(body)}');
    await _lauchUrl(url);
  }

  static Future _lauchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static Future openLink({String? body}) async {
    if (body == null) {
      return;
    } else if (body.trim().isEmpty) {
      await _lauchUrl(Uri.parse('https://google.com'));
    }else{
      await _lauchUrl(Uri.parse('https://$body'));
    }
  }
}

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendEmail(String subject, String body) async {
  //Configure the SMTP server
  final smtpServer = gmail('tanchuanhock0103@gmail.com', 'cxmn zmrf yrlc oofg');

  // Create the email message
  final message = Message()
  ..from = Address('tanchuanhock0103@gmail.com', 'eVandalism App')
  ..recipients.add('holykiller010@gmail.com')
  ..subject = subject
  ..text = body;

  try {
    // Send the email
    await send(message, smtpServer);
    print('Email sent Successfully');
  } catch (e) {
    print('Failed to send email: $e');
  }
}
final _tipPattern = new RegExp(r'^[ ]{0,3}>[ ]*?\*\*tip\*\*[ ]?(.*)$', multiLine: true);
final _alertPattern = new RegExp(r'^[ ]{0,3}>[ ]*\*\*alert\*\*[ ]?(.*)$', multiLine: true);

class MarkdownConverter {

  // intallinn_content uses a custom blockquote-ish syntax for tips and alerts.
  // Convert these back to standard blockquotes.
  // Ideally, should parse and filter
  String convert(String content) {
    return content.replaceAllMapped(_tipPattern, (Match m) => "> ${m.group(1)}")
                  .replaceAllMapped(_alertPattern, (Match m) => "> ${m.group(1)}");
  }
}
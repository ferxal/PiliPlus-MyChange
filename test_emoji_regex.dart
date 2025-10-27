// 测试表情符正则表达式
void main() {
  final emojiPattern = RegExp(r'\[.*?\]');
  final testCases = [
    '[honkai3_pure_3]',
    '你好[honkai3_pure_3]',
    '[honkai3_pure_3]世界',
    '测试[honkai3_pure_3]表情[honkai3_pure_4]包',
  ];
  
  for (var test in testCases) {
    print('\n测试: $test');
    final matches = emojiPattern.allMatches(test);
    print('匹配数量: ${matches.length}');
    for (var match in matches) {
      print('  匹配: ${match.group(0)}');
    }
    
    // 测试 splitMapJoin
    final buffer = StringBuffer();
    test.splitMapJoin(
      emojiPattern,
      onMatch: (match) {
        final emote = match.group(0)!;
        print('  ✓ 表情符不加密: $emote');
        buffer.write(emote);
        return '';
      },
      onNonMatch: (nonMatch) {
        if (nonMatch.isNotEmpty) {
          final encrypted = nonMatch.runes.map((rune) {
            int newRune = rune + 10;
            if (newRune > 0x10FFFF) newRune -= 0x110000;
            return String.fromCharCode(newRune);
          }).join();
          print('  🔒 文本加密: "$nonMatch" -> "$encrypted"');
          buffer.write(encrypted);
        }
        return '';
      },
    );
    print('结果: ${buffer.toString()}');
  }
}

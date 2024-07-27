import 'const.dart';
import 'enums.dart';
import 'models.dart';

class EpsonEPOSHelper {
  EpsonEPOSHelper();

   dynamic getPortType(EpsonEPOSPortType enumData, {bool returnInt = false}) {
    switch (enumData) {
      case EpsonEPOSPortType.TCP:
        return returnInt ? 1 : 'TCP';
      case EpsonEPOSPortType.BLUETOOTH:
        return returnInt ? 2 : 'BT';
      case EpsonEPOSPortType.USB:
        return returnInt ? 3 : 'USB';
      default:
        return returnInt ? 0 : 'ALL';
    }
  }

  EPSONSeries? getSeries(String modelName) {
    if (modelName.isEmpty) return null;
    return epsonSeries.firstWhere(
      (element) => element.models.contains(modelName),
      orElse: () => epsonSeries.first,
    );
  }
}

extension NovaStringEXT on String {
  List<String> wrapText(int maxLength) {
    List<String> words = [];
    List<String> lines = [];
    String currentLine = '';
    for (String l in split(' ')) {
      if (l.length > maxLength) {
        words.addAll(l.splitByLength(maxLength));
      } else {
        words.add(l);
      }
    }
    for (String word in words) {
      if (currentLine.length + word.length + (currentLine.isEmpty ? 0 : 1) <=
          maxLength) {
        if (currentLine.isNotEmpty) {
          currentLine += ' ';
        }
        currentLine += word;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  List<String> splitByLength(int maxLength) {
    List<String> list = [];
    final splitSize = (length + maxLength - 1) ~/ maxLength;
    for (int i = 0; i < splitSize; i++) {
      var tempString = '';
      if (i == 0) {
        tempString = substring(i, i + maxLength);
      } else if (i == splitSize - 1) {
        tempString = substring(i * maxLength + 1, length);
      } else {
        tempString = substring(i * maxLength + 1, i * maxLength + maxLength);
      }
      list.add(tempString);
    }
    return list;
  }
}

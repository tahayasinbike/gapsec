import 'package:isar/isar.dart';

part 'newgame_model.g.dart';

@collection
class NewGame {
  Id id = Isar.autoIncrement;

  String? murderTexts;
  String? gravehurstTexts;
  String? webOfDeceitTexts;
  String? zetaTexts;
  String? unknownTexts;
  String? smileTexts;
  String? behindTexts;
  String? luckyTexts;
}

enum TextType {
  murderType,
  gravehurstType,
  webOfDeceitType,
  zetaType,
  unknownType,
  smileType,
  behindType,
  luckyType,
}

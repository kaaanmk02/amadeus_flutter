/// `PersonalityType.java` karşılığı.
enum PersonalityType {
  tsundere,
  yandere,
  dandere,
  kuudere,
  deredere,
  kamidera,
  gothic;

  static PersonalityType fromName(String name) {
    for (final t in PersonalityType.values) {
      if (t.name.toLowerCase() == name.toLowerCase()) return t;
    }
    return PersonalityType.tsundere;
  }
}

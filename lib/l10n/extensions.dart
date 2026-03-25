import 'package:dietando/models/models.dart';
import 'package:dietando/l10n/app_localizations.dart';

extension MealTypeL10n on MealType {
  String l10nName(AppLocalizations l10n) {
    switch (this) {
      case MealType.colazione:
        return l10n.mealTypeBreakfast;
      case MealType.spuntinoMattutino:
        return l10n.mealTypeMorningSnack;
      case MealType.pranzo:
        return l10n.mealTypeLunch;
      case MealType.spuntinoPomeridiano:
        return l10n.mealTypeAfternoonSnack;
      case MealType.cena:
        return l10n.mealTypeDinner;
    }
  }
}

extension DayOfWeekL10n on DayOfWeek {
  String l10nName(AppLocalizations l10n) {
    switch (this) {
      case DayOfWeek.lunedi:
        return l10n.dayMonday;
      case DayOfWeek.martedi:
        return l10n.dayTuesday;
      case DayOfWeek.mercoledi:
        return l10n.dayWednesday;
      case DayOfWeek.giovedi:
        return l10n.dayThursday;
      case DayOfWeek.venerdi:
        return l10n.dayFriday;
      case DayOfWeek.sabato:
        return l10n.daySaturday;
      case DayOfWeek.domenica:
        return l10n.daySunday;
    }
  }
}

extension UnitL10n on Unit {
  String l10nName(AppLocalizations l10n) {
    switch (this) {
      case Unit.Grammi:
        return l10n.unitGrams;
      case Unit.Pezzi:
        return l10n.unitPieces;
      case Unit.Litri:
        return l10n.unitLiters;
    }
  }
}

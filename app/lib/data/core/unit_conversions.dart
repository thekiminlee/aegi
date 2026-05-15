import 'package:aegi/core/enums/units.dart';

class UnitConversions {
  static const double mlPerOz = 29.5735;
  static const double kgPerLb = 0.453592;
  static const double cmPerInch = 2.54;

  static double volumeToCanonicalMl(double value, VolumeUnit unit) {
    return unit == VolumeUnit.oz ? value * mlPerOz : value;
  }

  static double volumeFromCanonicalMl(double ml, VolumeUnit unit) {
    return unit == VolumeUnit.oz ? ml / mlPerOz : ml;
  }

  static double weightToCanonicalKg(double value, WeightUnit unit) {
    return unit == WeightUnit.lb ? value * kgPerLb : value;
  }

  static double weightFromCanonicalKg(double kg, WeightUnit unit) {
    return unit == WeightUnit.lb ? kg / kgPerLb : kg;
  }

  static double temperatureToCanonicalCelsius(
    double value,
    TemperatureUnit unit,
  ) {
    return unit == TemperatureUnit.fahrenheit ? (value - 32) * 5 / 9 : value;
  }

  static double temperatureFromCanonicalCelsius(
    double celsius,
    TemperatureUnit unit,
  ) {
    return unit == TemperatureUnit.fahrenheit
        ? (celsius * 9 / 5) + 32
        : celsius;
  }

  static double lengthToCanonicalCm(double value, LengthUnit unit) {
    return unit == LengthUnit.inch ? value * cmPerInch : value;
  }

  static double lengthFromCanonicalCm(double cm, LengthUnit unit) {
    return unit == LengthUnit.inch ? cm / cmPerInch : cm;
  }
}

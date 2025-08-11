build:
  flutter pub run build_runner build --delete-conflicting-outputs

format:
  dart format ./lib ./test

run_intl: 
  dart run intl_translation:generate_from_arb --output-dir ./lib/generated/intl/ lib/**/*.dart ./lib/l10n/*.arb

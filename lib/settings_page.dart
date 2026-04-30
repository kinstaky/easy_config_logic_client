import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:easy_config_logic_client/settings.dart';


enum ColorSeed {
	pink("Pink", Color(0xFFFCD6D8), 0xFFFCD6D8),
	red("Red", Color(0xFFF73A4B), 0xFFF73A4B),
	orange("Orange", Color(0xFFF79A4B), 0xFFF79A4B),
	yellow("Yellow", Color(0xFFF5D971), 0xFFF5D971),
	green("Green", Color(0xFF76D297), 0xFF76D297),
	teal("Teal", Color(0xff56CCC0), 0xff56CCC0),
	blue("Blue", Color(0xFF648CEF), 0xFF648CEF),
	violet("Violet", Color(0xFFB37FE8), 0xFFB37FE8),
	brown("Brown", Color(0xFFB39787), 0xFFB39787);
  // purpleM3('Purple', Color(0xff6750a4)),
  // indigoM3('Indigo', Colors.indigo),
  // blueM3('Blue', Colors.blue),
  // tealM3('Teal', Colors.teal),
  // greenM3('Green', Colors.green),
  // yellowM3('Yellow', Colors.yellow),
  // orangeM3('Orange', Colors.orange),
  // deepOrangeM3('Deep Orange', Colors.deepOrange),
  // brightBlueM3('Bright Blue', Color(0xFF0000FF)),
  // brightGreenM3('Bright Green', Color(0xFF00FF00)),
  // brightRedM3('Bright Red', Color(0xFFFF0000));

  const ColorSeed(this.label, this.color, this.value);
  final String label;
  final Color color;
	final int value;
}

enum LanguageLabel {
  english("English", Locale("en"), "Roboto"),
  chinese("简体中文", Locale("zh"), "NotoSansSC");

  const LanguageLabel(this.label, this.locale, this.font);
  final String label;
  final Locale locale;
  final String font;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController languageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var settings = context.watch<SettingsModel>();
    var selectedLanguage = LanguageLabel.values[0];
		final List<DropdownMenuEntry<LanguageLabel>> languageEntries =
      <DropdownMenuEntry<LanguageLabel>>[];
    for (final language in LanguageLabel.values) {
      languageEntries.add(
        DropdownMenuEntry<LanguageLabel>(
          value: language,
          label: language.label,
          labelWidget: Text(
            language.label,
            style: TextStyle(fontFamily: language.font),
          )
        )
      );
			if (language.locale == settings.locale) {
				selectedLanguage = language;
			}
    }

    return ListView(
      padding: EdgeInsets.all(20.0),
      children: <Widget> [
        Padding(
					padding: const EdgeInsets.symmetric(vertical: 8.0),
					child: Wrap(
						crossAxisAlignment: WrapCrossAlignment.center,
						children: [
							Padding(
								padding: const EdgeInsets.all(8.0),
								child: Icon(Icons.color_lens),
							),
							Text(AppLocalizations.of(context)!.themeColorSettings),
							...List<Widget>.generate(
								ColorSeed.values.length,
								(int index) {
									final Color itemColor = ColorSeed.values[index].color;
									return IconButton(
										icon: settings.color == ColorSeed.values[index].color
											? Icon(Icons.circle, color: itemColor)
											: Icon(Icons.circle_outlined, color: itemColor),
										onPressed: () => settings.updateThemeColor(
											ColorSeed.values[index].value
										),
									);
								}
							),
						],
					),
				),
        Padding(
					padding: const EdgeInsets.symmetric(vertical: 8.0),
					child: Row(
						children: [
							Padding(
								padding: const EdgeInsets.all(8.0),
								child: Icon(Icons.brightness_4),
							),
							Text(AppLocalizations.of(context)!.brightnessSettings),
							Switch(
								value: settings.brightness == Brightness.dark,
								onChanged: (bool value) {
									settings.updateBrightness(
										value ? Brightness.dark : Brightness.light
									);
								},
							)
						],
					),
				),
        Padding(
					padding: const EdgeInsets.symmetric(vertical: 8.0),
					child: Row(
						children: [
							Padding(
								padding: const EdgeInsets.all(8.0),
								child: Icon(Icons.language),
							),
							Text(AppLocalizations.of(context)!.languageSettings),
							DropdownMenu<LanguageLabel>(
												initialSelection: selectedLanguage,
								controller: languageController,
								dropdownMenuEntries: languageEntries,
								inputDecorationTheme: const InputDecorationTheme(filled: true),
								onSelected: (language) {
									if (language != null) {
										settings.updateLocale(language.locale);
									}
								},
							),
						],
					),
				)
      ],
    );
  }
}
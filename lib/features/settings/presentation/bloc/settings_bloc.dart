import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences _prefs;
  static const _themeKey = 'is_dark_mode';

  SettingsBloc(this._prefs) : super(const SettingsState()) {
    on<LoadSettings>(_onLoad);
    on<ToggleTheme>(_onToggle);
    add(LoadSettings());
  }

  void _onLoad(LoadSettings e, Emitter<SettingsState> emit) {
    final isDark = _prefs.getBool(_themeKey) ?? true; // default dark
    emit(state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> _onToggle(ToggleTheme e, Emitter<SettingsState> emit) async {
    final newDark = !state.isDark;
    await _prefs.setBool(_themeKey, newDark);
    emit(state.copyWith(themeMode: newDark ? ThemeMode.dark : ThemeMode.light));
  }
}

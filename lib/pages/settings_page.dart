import 'package:FinTrack/services/settings_provider.dart';
import 'package:FinTrack/services/shared_pref.dart';
import 'package:FinTrack/util/constants.dart';
import 'package:FinTrack/util/value_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingsProvider settingPrvdr = Get.find();
  bool notificationAllowed = SharedPref().notificationAllowed;
  final TextEditingController _notificationTimeController =
      TextEditingController();
  final ValueHelper valueHelper = ValueHelper();
  bool cFAllowed = false;
  String dropdownCurrency = "₹";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationTimeController.text =
        valueHelper.getFormattedTimeIn12Hr(SharedPref().notificationTime);
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, SettingsProvider settingsProvider, child) {
      cFAllowed = settingsProvider.isCFAllowed ?? false;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          elevation: 0.0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context); // Back button functionality
            },
            child: Icon(
              Icons.arrow_back, // Back arrow icon
              size: 20,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                settingsProvider.isDarkMode
                    ? settingsProvider.isDark = false
                    : settingsProvider.isDark = true;
              },
              child: Icon(
                settingsProvider.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            ListTile(
              title: const Text('Allow Notifications'),
              trailing: Switch(
                value: notificationAllowed,
                onChanged: (value) {
                  setState(() {
                    notificationAllowed = value;
                  });
                  if (notificationAllowed) {
                    SharedPref().turnOnNotifications(
                        true, TimeOfDay(hour: 20, minute: 0));
                  } else {
                    _notificationTimeController.text = valueHelper
                        .getFormattedTimeIn12Hr(TimeOfDay(hour: 20, minute: 0));
                    SharedPref().turnOffNotifications(false);
                  }
                },
              ),
            ),
            Visibility(
              visible: notificationAllowed,
              child: ListTile(
                title: const Text('Notification Time'),
                trailing: TextButton(
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: SharedPref().notificationTime,
                    );
                    if (pickedTime != null) {
                      if (SharedPref().notificationAllowed) {
                        SharedPref().turnOnNotifications(true, pickedTime);
                      }
                      setState(() {
                        _notificationTimeController.text =
                            pickedTime.format(context);
                      });
                    }
                  },
                  child: Text(_notificationTimeController.text),
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: const Text('Allow Carry Forward'),
              trailing: Switch(
                value: settingsProvider.isCFAllowed,
                onChanged: (value) {
                  setState(() {
                    cFAllowed = value;
                  });
                  settingsProvider.isCFAllowed = cFAllowed;
                },
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: const Text('Currency'),
              trailing: GestureDetector(
                onTap: () {
                  _showDialog(
                    CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (int index) {
                        setState(() {
                          dropdownCurrency = Constants.currenciesSymbol[index];
                        });
                        settingsProvider.currencySymbol = dropdownCurrency;
                      },
                      useMagnifier: true,
                      children: Constants.currenciesSymbol
                          .map((e) =>
                              Text("$e  ${Constants.currencySymbolMap[e]!}"))
                          .toList(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$dropdownCurrency ${Constants.currencySymbolMap[dropdownCurrency]!}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

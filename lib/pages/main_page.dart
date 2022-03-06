import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/window_buttons.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _deviceAddress;
  String _deviceAddressValue = "";

  bool isSwitched = false;

  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);

  double _currentSliderValue = 0;

  List<Color> colors = [
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();

    _deviceAddress = _prefs.then((SharedPreferences prefs) {
      var value = prefs.getString('deviceAddress') ?? "";
      setState(() {
        _deviceAddressValue = value;

        http.get(Uri.parse(value)).then((value) {
          var data = json.decode(value.body);

          setState(() {
            var bri = data['bri'] as int;
            isSwitched = data['on'];
            _currentSliderValue = bri.toDouble();
            pickerColor = Color.fromARGB(
              255,
              data['seg'][0]['col'][0][0],
              data['seg'][0]['col'][0][1],
              data['seg'][0]['col'][0][2],
            );
          });
        });
      });
      return value;
    });
  }

  void ledToggle(bool value) {
    _deviceAddress.then((addr) {
      if (addr.isNotEmpty) {
        http.post(
          Uri.parse(_deviceAddressValue),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'on': value, 'v': true}),
        );
      }
    });
  }

  void changeLedColor(Color color) {
    _deviceAddress.then((value) {
      if (value.isNotEmpty) {
        http.post(
          Uri.parse(_deviceAddressValue),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'seg': [
              {
                'col': [
                  [color.red, color.green, color.blue]
                ]
              }
            ]
          }),
        );
      }
    });
  }

  void changeBrightness(int brightness) {
    _deviceAddress.then((value) {
      if (value.isNotEmpty) {
        http.post(
          Uri.parse(_deviceAddressValue),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'bri': brightness}),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 42, 42),
      body: Column(
        children: [
          Column(
            children: [
              SizedBox(
                width: 300,
                height: 50,
                child: SizedBox(
                  width: 300,
                  height: 50,
                  child: WindowTitleBarBox(
                    child: MoveWindow(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                          ),
                          Switch(
                            value: isSwitched,
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.red,
                            onChanged: (value) {
                              setState(() {
                                isSwitched = value;
                              });
                              ledToggle(value);
                            },
                          ),
                          const WindowButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 400,
                child: ColorPicker(
                  enableAlpha: false,
                  paletteType: PaletteType.hueWheel,
                  labelTypes: const [],
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    setState(() => pickerColor = color);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: SizedBox(
                  width: 400,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        primary: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        changeLedColor(pickerColor);
                      },
                      child: const Text('Change LED Color'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: SizedBox(
                  width: 400,
                  height: 75,
                  child: BlockPicker(
                    pickerColor: pickerColor,
                    availableColors: colors,
                    onColorChanged: (Color color) {
                      setState(() => pickerColor = color);
                      changeLedColor(pickerColor);
                    },
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    "Brightness",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Slider(
                    value: _currentSliderValue,
                    min: 0,
                    max: 255,
                    divisions: 100,
                    label: _currentSliderValue.round().toString(),
                    activeColor: Colors.green,
                    inactiveColor: Colors.red,
                    thumbColor: Colors.white,
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                      });
                    },
                    onChangeEnd: (double value) {
                      setState(() {
                        isSwitched = true;
                      });
                      changeBrightness(value.round());
                    },
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

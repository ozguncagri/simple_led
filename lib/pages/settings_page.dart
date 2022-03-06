import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/window_buttons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _deviceAddressValue = "";
  String _deviceStatus = "";

  final TextEditingController _deviceAddressController =
      TextEditingController();

  Future<void> _setDeviceAddress(String address) async {
    final SharedPreferences prefs = await _prefs;
    String endpointAddress = "http://$address/json/state";
    setState(() {
      prefs.setString('deviceAddress', endpointAddress);
      _deviceAddressValue = endpointAddress;
    });
  }

  @override
  void initState() {
    super.initState();

    _prefs.then((SharedPreferences prefs) {
      var value = prefs.getString('deviceAddress') ?? '';

      setState(() {
        _deviceAddressValue = value;
        _deviceAddressController.text =
            value.replaceAllMapped(RegExp(r'http://(.*)/json/state'), (match) {
          return match.group(1).toString();
        });
      });

      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 42, 42, 42),
      body: Column(
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
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const WindowButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _deviceAddressController,
              onChanged: (value) {
                _setDeviceAddress(value);
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              decoration: const InputDecoration(
                hintText: "Device IP or network name",
                hintStyle: TextStyle(
                  color: Colors.white30,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          ElevatedButton(
            child: const Text(
              "Get Device Status",
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                _deviceStatus = "Fetching device status...";
              });
              http.get(Uri.parse(_deviceAddressValue)).then(
                (value) {
                  var data = json.decode(value.body);
                  setState(() {
                    _deviceStatus =
                        "Is LEDs On : ${data['on'].toString()}\n\nBrightness Value : ${data['bri'].toString()}\n\nCurrent Color Values :\nR : ${data['seg'][0]['col'][0][0].toString()}\nG : ${data['seg'][0]['col'][0][1].toString()}\nB : ${data['seg'][0]['col'][0][2].toString()}";
                  });
                },
              ).catchError((error) {
                _deviceStatus = error.toString();
              });
            },
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Column(
                  children: [
                    const Text(
                      "Device JSON Endpoint",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Text(
                      _deviceAddressValue,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "Device status",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                _deviceStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

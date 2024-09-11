import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_config_logic_client/device.dart';
import 'package:easy_config_logic_client/home_page.dart';
import 'package:easy_config_logic_client/device_page.dart';

final lineColors = [];
final deviceMap = DeviceMapModel();

void main() async {
  var fullColors = Colors.accents.toList();
  for (var i = 0; i < scalerNum; ++i) {
    lineColors.add(fullColors[Random().nextInt(fullColors.length)]);
  }
  await deviceMap.init();
  runApp(const Client());
}


class Client extends StatelessWidget {
  const Client({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => deviceMap,
      child: MaterialApp(
        title: "easy config logic client",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        restorationScopeId: "app",
        home: const ClientPage(),
      ),
    );
  }
}


class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}


class _ClientPageState extends State<ClientPage> {
  var selectedPageIndex = 0;

  void changePage(value) {
    setState(() {
      selectedPageIndex = value;
    });
  }


  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedPageIndex) {
      case 0:
        page = HomePage(
          changePage: changePage,
        );
        break;
      case 1:
        page = DevicePage(
          changePage: changePage,
          lineColors: lineColors,
        );
        break;
      default:
        throw UnimplementedError('no widget for $selectedPageIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    size: 48,
                  ),
                  selectedIcon: Icon(
                    Icons.home,
                    size: 48,
                  ),
                  label: Text('Home')
                ),
                NavigationRailDestination(
                  icon: Icon(
                    Icons.dns_outlined,
                    size: 48,
                  ),
                  selectedIcon: Icon(
                    Icons.dns,
                    size: 48,
                  ),
                  label: Text('Device'),
                )
              ],
              selectedIndex: selectedPageIndex,
              onDestinationSelected: changePage,
            )
          ),
          Expanded(
            child: page,
          ),
        ],
      ),
    );
  }
}

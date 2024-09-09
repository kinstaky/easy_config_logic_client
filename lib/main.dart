import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:easy_config_logic_client/device.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

final lineColors = [];
final deviceGroupModel = DeviceGroupModel();

void main() async {
  var fullColors = Colors.accents.toList();
  for (var i = 0; i < scalerNum; ++i) {
    lineColors.add(fullColors[Random().nextInt(fullColors.length)]);
  }
  await deviceGroupModel.init();
  runApp(const Client());
}


class Client extends StatelessWidget {
  const Client({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => deviceGroupModel,
      child: MaterialApp(
        title: "easy config logic client",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          // brightness: Brightness.dark,
        ),
        home: const HomePage(),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  void changePage(value) {
    setState(() {
      selectedIndex = value;
    });
  }

  Future<void> navigateEditDevicePage(
    BuildContext context,
    DeviceGroupModel deviceGroup
  ) async {
    final device = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditDevicePage()),
    );

    // copy from example
    if (!context.mounted) return;

    // no change
    if (device == null) return;

    deviceGroup.addDevice(device);
  }

  @override
  Widget build(BuildContext context) {
    var deviceGroup = context.watch<DeviceGroupModel>();

    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Stack(
          alignment: Alignment.bottomRight,
          children: [
            ListView(
              children: <Widget> [
                for (var dev in deviceGroup.devices.values)
                  DeviceEntry(
                    changePage: changePage,
                    device: dev
                  )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: () {
                  navigateEditDevicePage(context, deviceGroup);
                  // deviceGroup.addDevice(DeviceModel(
                  //   name: "test",
                  //   address: "localhost",
                  //   port: "2233",
                  // ));
                },
                tooltip: "Add new device",
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
        break;
      case 1:
        page = DevicePage(changePage: changePage);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
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
              selectedIndex: selectedIndex,
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

class DevicePage extends StatelessWidget {

  const DevicePage({super.key, required this.changePage});

  final Function changePage;
  final String selectedDevice = "test";

  @override
  Widget build(BuildContext context) {
    var deviceGroup = context.watch<DeviceGroupModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => changePage(0),
            icon: const Icon(Icons.expand_more)
          ),
          title: Row(
            children: [
              Container(
                margin: const EdgeInsetsDirectional.symmetric(
                  horizontal: 10,
                ),
                child: Text(selectedDevice)
              ),
              Text(
                "${deviceGroup.devices[selectedDevice]!.address}"
                ":${deviceGroup.devices[selectedDevice]!.port}"
              ),
            ],
          ),
          bottom: const TabBar(
            tabs:  [
              Tab(text: "scaler"),
              Tab(text: "config"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ScalerTab(
              device: deviceGroup.devices[selectedDevice]!,
            ),
            const Text("config"),
          ],
        )
      ),
    );
  }
}

class ScalerTab extends StatelessWidget {
  const ScalerTab({super.key, required this.device});

  // device
  final DeviceModel device;

  List<LineChartBarData> scalerLineData(List<List<int>> scalers, List<bool> show) {
    List<LineChartBarData> result = [];
    for (var i = 0; i < scalerNum; ++i) {
      if (!show[i]) continue;
      result.add(LineChartBarData(
        isCurved: false,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        color: lineColors[i],
        spots: scalers[i].mapIndexed(
          (index, value) => FlSpot(index.toDouble(), value.toDouble())
        ).toList(),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF50E4FF).withOpacity((0.2)),
                      width: 4
                    ),
                    left: BorderSide(
                      color: const Color(0xFF50E4FF).withOpacity((0.2)),
                      width: 4
                    ),
                    top: const BorderSide(color: Colors.transparent),
                    right: const BorderSide(color: Colors.transparent),
                  ),
                ),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // bottomTitles: AxisTitles(
                  //   sideTitles: SideTitles(showTitles: false),
                  // ),
                  // leftTitles: AxisTitles(
                  //   // axisNameWidget: Placeholder(),
                  //   sideTitles: SideTitles(showTitles: false),
                  // )
                ),
                lineBarsData: scalerLineData(
                  device.visualScaler,
                  device.visual
                ),
                minX: 0,
                minY: 0,
              )
            ),
          ),
        ),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: device.scaler.mapIndexed(
            (index, value) {
              return SizedBox(
                width: 120,
                child: TextButton(
                  onPressed: () {
                    device.visual[index] = !device.visual[index];
                    device.refreshVisualScaler();
                  },
                  iconAlignment: IconAlignment.start,
                  style: TextButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    "$index: $value",
                    style: device.visual[index]
                      ? Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: lineColors[index]
                      )
                      : Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              );
            }
          ).toList(),
        ),
      ],
    );
  }
}

class DeviceEntry extends StatelessWidget {
  final Function changePage;
  final DeviceModel device;

  const DeviceEntry({
    super.key,
    required this.changePage,
    required this.device
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const statusColor = [
      Colors.grey,
      Colors.red,
      Colors.orange,
      Colors.green,
    ];

    return ListTile(
      leading: Icon(
        Icons.circle,
        color: statusColor[device.state],
      ),
      title: Text(
        device.name,
        style: theme.textTheme.headlineSmall,
      ),
      subtitle: Text(
        "${device.address}:${device.port}",
        style: theme.textTheme.titleLarge,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            iconSize: 36,
            tooltip: "Refresh",
            onPressed: () => device.refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 36,
            tooltip: "Edit",
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            iconSize: 36,
            tooltip: "Delete",
            onPressed: () {
              deviceGroupModel.deleteDevice(device.name);
            },
          ),
        ],
      ),
      onTap: () => changePage(1),
    );
  }
}

class EditDevicePage extends StatefulWidget {
  const EditDevicePage({super.key});

  @override
  State<EditDevicePage> createState() => _EditDevicePageState();
}

class _EditDevicePageState extends State<EditDevicePage> {

  _EditDevicePageState() {
    for (var name in textFieldName) {
      textController[name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in textController.values) {
      controller.dispose();
    }
    super.dispose();
  }

  static const textFieldName = ["name", "address", "port"];
  final Map<String, TextEditingController> textController = {};


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New device"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var name in textFieldName)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    width: 100,
                    child: Text(name),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: textController[name],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Enter device $name",
                      ),
                    )
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 30,
            ),
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context, DeviceModel(
                  name: textController["name"]!.text,
                  address: textController["address"]!.text,
                  port: textController["port"]!.text,
                ));
              },
              child: const Text("Save"),
            ),
          )
        ],
      )
    );
  }
}
import 'package:collection/collection.dart';
import 'package:easy_config_logic_client/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_config_logic_client/device.dart';


class DevicePage extends StatelessWidget {

  const DevicePage({
    super.key,
    required this.changePage,
    required this.lineColors,
  });

  final Function changePage;
  final List lineColors;

  @override
  Widget build(BuildContext context) {
    var deviceMap = context.watch<DeviceMapModel>();
    var device = deviceMap.devices[deviceMap.selectedDevice];

    if (device != null) {
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
                  child: Text(device.name)
                ),
                Text("${device.address}:${device.port}"),
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
              SingleChildScrollView(
                child: ScalerTab(
                  restorationId: "scaler_tab",
                  device: device,
                  lineColors: lineColors,
                ),
              ),
              ConfigTab(device: device),
            ],
          )
        ),
      );
    } else {
      return const Scaffold();
    }
  }
}

class ConfigTab extends StatefulWidget {
  const ConfigTab({
    super.key,
    required this.device,
  });

  final DeviceModel device;

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {

  _ConfigTabState();

  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: widget.device.expressions.join("\n"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: OutlinedButton(
                    onPressed: () async {
                      await widget.device.getConfig();
                      textController.text =
                        widget.device.expressions.join("\n");
                    },
                    style: buttonStyle,
                    child: const Text("load"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 0,
                  ),
                  child: OutlinedButton(
                    onPressed: (){
                      textController.text = "";
                    },
                    style: buttonStyle,
                    child: const Text("clear"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 20,
                  ),
                  child: FilledButton(
                    onPressed: () async {
                      widget.device.expressions = textController.text.split("\n");
                      var result = await widget.device.setConfig();
                      print("Set result $result");
                    },
                    style: buttonStyle,
                    child: const Text("save"),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 5.0),
              child: Text(
                "Last config: ${widget.device.configTime.toString().substring(0, 19)}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 20.0,
              ),
              child: TextField(
                controller: textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ScalerTab extends StatefulWidget {
  const ScalerTab({
    super.key,
    this.restorationId,
    required this.device,
    required this.lineColors,
  });

  // device
  final DeviceModel device;
  final List lineColors;

  // restoration id
  final String? restorationId;

  @override
  State<ScalerTab> createState() => _ScalerTabState();
}

class _ScalerTabState extends State<ScalerTab> with RestorationMixin {
  ScalerMode scalerMode = ScalerMode.modeLive;
  final RestorableDateTime selectedDate = RestorableDateTime(DateTime.now());

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(selectedDate, 'selected_date');
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30, 0, 0, 0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: SizedBox(
                  width: 250,
                  child: SegmentedButton<ScalerMode>(
                    segments: const <ButtonSegment<ScalerMode>>[
                      ButtonSegment<ScalerMode>(
                        value: ScalerMode.modeLive,
                        label: Text("Real time"),
                      ),
                      ButtonSegment<ScalerMode>(
                        value: ScalerMode.modeHistory,
                        label: Text("History"),
                      ),
                    ],
                    selected: <ScalerMode>{scalerMode},
                    onSelectionChanged: (Set<ScalerMode> newSelection) {
                      setState(() {
                        scalerMode = newSelection.first;
                      });
                      if (scalerMode == ScalerMode.modeLive) {
                        final deviceMap = context.read<DeviceMapModel>();
                        final device = deviceMap.devices[deviceMap.selectedDevice]!;
                        device.scalerMode = 0;
                        device.getLiveScaler();
                      } else if (scalerMode == ScalerMode.modeHistory) {
                        final deviceMap = context.read<DeviceMapModel>();
                        final device = deviceMap.devices[deviceMap.selectedDevice]!;
                        device.scalerMode = 1;
                        device.getHistoryScaler(selectedDate.value);
                      }
                    },
                  ),
                ),
              ),
              scalerMode == ScalerMode.modeLive
                ? LiveModeSelector(selectedMode: widget.device.scalerLiveMode)
                : HistoryDateSelector(
                  restorationId: "history",
                  selectedDate: selectedDate,
                ),
            ],
          ),
          ScalerChart(
            lineColors: lineColors,
            device: widget.device,
          ),
          ScalerLiveText(
            lineColors: lineColors,
            device: widget.device,
          ),
        ],
      ),
    );
  }
}


class LiveModeSelector extends StatefulWidget {
  const LiveModeSelector({
    super.key,
    required this.selectedMode,
  });

  final int selectedMode;

  @override
  State<LiveModeSelector> createState() => _LiveModeSelectorState();
}

class _LiveModeSelectorState extends State<LiveModeSelector> {
  int selectedMode = 0;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.selectedMode;
  }

  @override
  Widget build(BuildContext context) {
    // var deviceMap = context.watch<DeviceMapModel>();
    // var device = deviceMap.devices[deviceMap.selectedDevice]!;
    // var selectedMode = device.scalerLiveMode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: MenuAnchor(
        builder: (BuildContext context, MenuController controller, Widget? child) {
          return FilledButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            style: FilledButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            child: Text(scalerLiveModeName[selectedMode]),
          );
        },
        menuChildren: List<MenuItemButton>.generate(
          scalerLiveModeName.length,
          (int index) => MenuItemButton(
            onPressed: () {
              final deviceMap = context.read<DeviceMapModel>();
              final dev = deviceMap.devices[deviceMap.selectedDevice];
              if (dev != null) {
                dev.scalerLiveMode = index;
                dev.getLiveScaler();
              }
              setState(() => selectedMode = index);
            },
            child: Text(scalerLiveModeName[index]),
          )
        )
      ),
    );
  }
}

class HistoryDateSelector extends StatefulWidget {
  const HistoryDateSelector({
    super.key,
    this.restorationId,
    required this.selectedDate,
  });

  final String? restorationId;
  final RestorableDateTime selectedDate;

  @override
  State<HistoryDateSelector> createState() => _HistoryDateSelectorState();
}

class _HistoryDateSelectorState
  extends State<HistoryDateSelector>
  with RestorationMixin {

  @override
  String? get restorationId => widget.restorationId;


  late final RestorableRouteFuture<DateTime?> _restorableRouteFuture =
    RestorableRouteFuture<DateTime?>(
      onComplete: _selectDate,
      onPresent: (NavigatorState navigator, Object? arguments) {
        return navigator.restorablePush(
          _datePickerRoute,
          arguments: widget.selectedDate.value.millisecondsSinceEpoch,
        );
      }
    );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments
  ) {
    return DialogRoute(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: "history_date_picker_dialog",
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2024, 9, 1),
          lastDate: DateTime.now(),
        );
      }
    );
  }


  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        widget.selectedDate.value = newSelectedDate;
        final deviceMap = context.read<DeviceMapModel>();
        final device = deviceMap.devices[deviceMap.selectedDevice]!;
        device.getHistoryScaler(newSelectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: FilledButton(
        onPressed: () {
          _restorableRouteFuture.present();
        },
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        child: Text(
          "${widget.selectedDate.value.year}"
          "-${widget.selectedDate.value.month}"
          "-${widget.selectedDate.value.day}"
        ),
      ),
    );
  }
}


class ScalerChart extends StatelessWidget {
  const ScalerChart({
    super.key,
    required this.lineColors,
    required this.device,
  });

  final List lineColors;
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
    return SizedBox(
      height: 380,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 30, 30),
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
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  interval: 12,
                  maxIncluded: true,
                  getTitlesWidget: (value, meta) {
                    late final String text;
                    if (ScalerMode.values[device.scalerMode] == ScalerMode.modeLive) {
                      final time = DateTime.now().add(Duration(
                        seconds: (value.toInt() - 120) * scalerLiveModeAvg[device.scalerLiveMode]
                      ));
                      if (ScalerLiveMode.values[device.scalerLiveMode] == ScalerLiveMode.mode2m) {
                        text = "${time.hour}"
                          ":${time.minute.toString().padLeft(2, '0')}"
                          ":${time.second.toString().padLeft(2, '0')}";
                      } else {
                        text = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                      }
                    } else {
                      final minute = value.toInt() * 12;
                      final hour = value.toInt() / 5;
                      text = "$hour:$minute";
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(text),
                    );
                  },
                )
              )
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
    );
  }
}


class ScalerLiveText extends StatelessWidget {
  const ScalerLiveText({
    super.key,
    required this.lineColors,
    required this.device,
  });

  final List lineColors;
  final DeviceModel device;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: device.scaler.mapIndexed(
        (index, value) {
          return SizedBox(
            width: 120,
            child: TextButton(
              onPressed: () {
                device.visual[index] = !device.visual[index];
                device.getLiveScaler();
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
    );
  }
}


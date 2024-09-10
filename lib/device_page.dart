import 'package:collection/collection.dart';
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
              ScalerTab(
                device: device,
                lineColors: lineColors,
              ),
              const Text("config"),
            ],
          )
        ),
      );
    } else {
      return const Scaffold();
    }
  }
}

class ScalerTab extends StatelessWidget {
  const ScalerTab({
    super.key,
    required this.device,
    required this.lineColors,
  });

  // device
  final DeviceModel device;
  final List lineColors;

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

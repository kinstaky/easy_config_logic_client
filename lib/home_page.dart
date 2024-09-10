import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_config_logic_client/device.dart';
import 'package:easy_config_logic_client/edit_device_page.dart';


Future<void> navigateEditDevicePage(
  BuildContext context,
  {DeviceModel? device}
) async {
  final newDevice = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditDevicePage(device: device),
    ),
  );

  // copy from example
  if (!context.mounted) return;

  // no change
  if (newDevice == null) return;

  // read device map
  var deviceMap = context.read<DeviceMapModel>();

  // add device
  if (device == null) {
    deviceMap.addDevice(newDevice);
  } else {
    deviceMap.editDevice(newDevice);
  }
}


class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.changePage,
  });

  final Function changePage;

  @override
  Widget build(BuildContext context) {
    var deviceMap = context.watch<DeviceMapModel>();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ListView(
          children: <Widget> [
            for (var dev in deviceMap.devices.values)
              DeviceEntry(
                changePage: changePage,
                device: dev
              )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: FloatingActionButton(
            onPressed: () => navigateEditDevicePage(context),
            tooltip: "Add new device",
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}


class DeviceEntry extends StatelessWidget {
  const DeviceEntry({
    super.key,
    required this.changePage,
    required this.device
  });

  final Function changePage;
  final DeviceModel device;

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
            onPressed: () {
              device.errorConnect = 0;
              device.refreshState();
            }
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 36,
            tooltip: "Edit",
            onPressed: () => navigateEditDevicePage(
              context,
              device: device,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            iconSize: 36,
            tooltip: "Delete",
            onPressed: () {
              var deviceMap = context.read<DeviceMapModel>();
              deviceMap.deleteDevice(device.name);
            },
          ),
        ],
      ),
      onTap: () {
        var deviceMap = context.read<DeviceMapModel>();
        deviceMap.selectedDevice = device.name;
        changePage(1);
      }
    );
  }
}

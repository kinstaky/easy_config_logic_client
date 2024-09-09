import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:easy_config_logic_client/generated/ecl.pbgrpc.dart';

const int scalerNum = 32;

class DeviceModel {
  DeviceModel({
    required this.name,
    required this.address,
    required this.port,
  }) {
    for (var i = 0; i < scalerNum; ++i) {
      scaler.add(0);
      visual.add(false);
      visualScaler.add([]);
      for (var j = 0; j < 120; ++j) {
        visualScaler[i].add(0);
      }
    }
  }

  int state = 0;
  List<int> scaler = [];
  List<bool> visual = [];
  List<List<int>> visualScaler = [];
  String name = "";
  String address = "";
  String port = "";

  final stub = EasyConfigLogicClient(
    ClientChannel(
      'localhost',
      port: 2233,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure()
      ),
    )
  );

  Future<void> refresh() async {
    try {
      final Request request = Request(type: 0);
      final response = await stub.getState(request);
      state = response.value == 1 ? 3 : 1;
    } catch (e) {
      print("Caught error: $e");
      state = 0;
    }
  }

  Future<void> refreshScaler() async {
    try {
      final Request request = Request(type: 0, index: 0);
      scaler = [];
      await for (var response in stub.getScaler(request)) {
        scaler.add(response.value);
      }
      for (var i = 0; i < scalerNum; ++i) {
        visualScaler[i].removeAt(0);
        visualScaler[i].add(scaler[i]);
      }
      state = 3;
    } catch (e) {
      print("Caught error: $e");
      state = 0;
    }
  }

  Future<void> refreshVisualScaler() async {
    for (var i = 0; i < visual.length; ++i) {
      if (!visual[i]) continue;
      final Request request = Request(type: 1, index: i);
      try {
        var rangeIndex = 0;
        await for (var response in stub.getScaler(request)) {
          visualScaler[i][rangeIndex] = response.value;
          ++rangeIndex;
        }
        state = 3;
      } catch (e) {
        print("Caught error: $e");
        state = 0;
      }
    }
  }

}


class DeviceAdapter extends TypeAdapter<DeviceModel> {
  @override
  final typeId = 0;

  @override
  DeviceModel read(BinaryReader reader) {
    var name = reader.read();
    var address = reader.read();
    var port = reader.read();
    return DeviceModel(
      name: name,
      address: address,
      port: port
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer.write(obj.name);
    writer.write(obj.address);
    writer.write(obj.port);
  }
}


class DeviceGroupModel extends ChangeNotifier {

  DeviceGroupModel() {
    Timer.periodic(
      const Duration(seconds: 1),
      (_) => refresh(),
    );
  }

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DeviceAdapter());
    var box = await Hive.openBox("device");
    var deviceCount = box.get("deviceCount") ?? 0;
    // box.put("deviceCount", 0);
    for (var i = 0; i < deviceCount; ++i) {
      DeviceModel device = box.get("device$i");
      devices[device.name] = device;
    }
  }

  Future<void> saveDevice() async {
    await Hive.initFlutter();
    var box = await Hive.openBox("device");
    box.put("deviceCount", devices.length);
    var count = 0;
    for (var device in devices.values) {
      box.put("device$count", device);
      count++;
    }
  }

  final Map<String, DeviceModel> devices = {};
  // String selectedDevice = "test";

  Future<void> refresh() async {
    for (final dev in devices.values) {
      await dev.refreshScaler();
    }
    notifyListeners();
  }

  void addDevice(DeviceModel device) {
    if (devices.containsKey(device.name)) {
      throw "Device name existed: ${device.name}";
    }
    devices[device.name] = device;
    saveDevice();
  }

  void deleteDevice(String name) {
    if (!devices.containsKey(name)) {
      throw "Device name not existed: $name";
    }
    devices.remove(name);
    saveDevice();
  }

  void editDevice(DeviceModel device) {
    if (!devices.containsKey(device.name)) {
      throw "Device name not existed: ${device.name}";
    }
    devices[device.name] = device;
    saveDevice();
  }
}
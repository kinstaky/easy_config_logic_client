import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:easy_config_logic_client/generated/ecl.pbgrpc.dart';

const int scalerNum = 32;
const int maxConnectTry = 5;

enum ScalerMode {
  modeLive, modeHistory
}
enum ScalerLiveMode {
  mode2m, mode20m, mode2h, mode24h,
}
const scalerLiveModeName = [
  "2 minutes", "20 minutes", "2 hours", "24 hours",
];
const scalerLiveModeAvg = [
  1, 10, 60, 720,
];

class DeviceModel {
  DeviceModel({
    required this.name,
    required this.address,
    required this.port,
  }) {
    errorConnect = 0;
    scalerMode = 0;
    scalerLiveMode = 0;
    for (var i = 0; i < scalerNum; ++i) {
      scaler.add(0);
      visual.add(false);
      visualScaler.add([]);
      for (var j = 0; j < 120; ++j) {
        visualScaler[i].add(0);
      }
    }
    initStub();
  }

  DeviceModel.from(DeviceModel other) {
    state = other.state;
    errorConnect = other.errorConnect;
    scaler = List.from(other.scaler);
    visual = List.from(other.visual);
    visualScaler = List.from(other.visualScaler);
    name = other.name;
    address = other.address;
    port = other.port;
  }

  // gRPC
  String name = "";
  String address = "";
  String port = "";
  late EasyConfigLogicClient stub;
  // device state
  int state = 0;
  // connection error times
  int errorConnect = 0;
  // scaler mode
  int scalerMode = 0;
  // scaler live mode
  int scalerLiveMode = 0;
  // current scaler value
  List<int> scaler = [];
  // visual scaler
  List<bool> visual = [];
  // visual scaler data
  List<List<int>> visualScaler = [];
  // calculated scaler value
  int avgNumber = 0;

  void initStub() {
    stub = EasyConfigLogicClient(
      ClientChannel(
        address,
        port: int.parse(port),
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      ),
    );
  }

  Future<void> refreshState() async {
    if (errorConnect >= maxConnectTry) return;
    try {
      final Request request = Request(type: 0);
      final response = await stub.getState(request);
      state = response.value == 1 ? 3 : 1;
      errorConnect = 0;
    } catch (e) {
      print("Caught error: $e");
      ++errorConnect;
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
      if (ScalerMode.values[scalerMode] == ScalerMode.modeLive) {
        ++avgNumber;
        if (avgNumber >= scalerLiveModeAvg[scalerLiveMode]) {
          avgNumber = 0;
          for (var i = 0; i < scalerNum; ++i) {
            visualScaler[i].removeAt(0);
            visualScaler[i].add(scaler[i]);
          }
        } else {
          for (var i = 0; i < scalerNum; ++i) {
            var lastScaler = visualScaler[i].last;
            var sum = lastScaler * avgNumber + scaler[i];
            visualScaler[i].last = (sum / (avgNumber + 1.0)).round();
          }
        }
      }
      state = 3;
    } catch (e) {
      print("Caught error: $e");
      state = 0;
    }
  }


  Future<void> getVisualScaler({DateTime? date}) async {
    if (scalerMode == 0) {
      await getLiveScaler();
    } else {
      await getHistoryScaler(date!);
    }
  }

  Future<void> getLiveScaler() async {
    for (var i = 0; i < visual.length; ++i) {
      if (!visual[i]) continue;
      final Request request = Request(type: scalerLiveMode+1, index: i);
      try {
        var rangeIndex = 0;
        await for (var response in stub.getScaler(request)) {
          visualScaler[i][rangeIndex] = response.value;
          ++rangeIndex;
        }
        avgNumber = 0;
        state = 3;
      } catch (e) {
        print("Caught error: $e");
        state = 0;
      }
    }
  }

  Future<void> getHistoryScaler(DateTime date) async {
    var flag = 0;
    var visualIndex = [];
    for (var i = 0; i < visual.length; ++i) {
      if (!visual[i]) continue;
      flag |= 1 << i;
      visualIndex.add(i);
    }
    if (flag == 0) return;
    final DateRequest request = DateRequest(
      year: date.year,
      month: date.month,
      day: date.day,
      flag: flag
    );
    try {
      var index = 0;
      var rangeIndex = 0;
      await for (var response in stub.getScalerDate(request)) {
        visualScaler[visualIndex[index]][rangeIndex] = response.value;
        ++rangeIndex;
        if (rangeIndex == visualScaler[visualIndex[index]].length) {
          index++;
          rangeIndex = 0;
        }
      }
    } on GrpcError catch (e) {
      print ("Caught error: $e");
    } catch (e) {
      print("Caught error: $e");
      state = 0;
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


class DeviceMapModel extends ChangeNotifier {

  DeviceMapModel();

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
    Timer.periodic(
      const Duration(seconds: 1),
      (_) => refresh(),
    );
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
  String selectedDevice = "";

  Future<void> refresh() async {
    for (final dev in devices.values) {
      if (dev.name == selectedDevice) {
        await dev.refreshScaler();
      } else {
        await dev.refreshState();
      }
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
    device.initStub();
    saveDevice();
  }
}
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

class ParseResult {
  ParseResult({
    required this.index,
    required this.status,
    required this.position,
    required this.length,
  });

  String message() {
    switch (status) {
      case 1:
        return "Invalid character.\n";
      case 2:
        return "Variable starts with digits.\n";
      case 3:
        return "Vriable starts with underscore '_'.\n";
      case 101:
        return "Invalid token.\n";
      case 102:
        return "Token can't be shifted.\n";
      case 103:
        return "Invalid token type.\n";
      case 104:
        return "Invalid action type.\n";
      case 201:
        return "Tokens less than 3.\n";
      case 202:
        return "Invalid token type.\n";
      case 203:
        return "Multiple source of port.\n";
      case 204:
        return "Input and output in the same port.\n";
      case 205:
        return "Invalid scaler input.\n";
      case 206:
        return "LEMO and LVDS in the same port.\n";
      case 207:
        return "Undefined variable.\n";
      case 208:
        return "Nested downscale expression.\n";
      case 209:
        return "Invalid external clock source.\n";
      case 300:
        return "Generate error.\n";
      case 400:
        return "Connect server failed.\n";
      default:
        return "Undefined error.\n";
    }
  }

  int index = -1;
  int status = 0;
  int position = 0;
  int length = 0;
}


class DeviceModel {
  DeviceModel({
    required this.name,
    required this.address,
    required this.port,
    this.scalerNames
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
    if (scalerNames == null) {
      scalerNames = [];
      for (var i = 0; i < scalerNum; ++i) {
        scalerNames!.add("$i");
      }
    }
    initStub();
  }

  DeviceModel.from(DeviceModel other) {
    name = other.name;
    address = other.address;
    port = other.port;
    state = other.state;
    errorConnect = other.errorConnect;
    scalerMode = other.scalerMode;
    scalerLiveMode = other.scalerLiveMode;
    scaler = List.from(other.scaler);
    scalerNames = List.from(other.scalerNames!);
    visual = List.from(other.visual);
    visualScaler = List.from(other.visualScaler);
    avgNumber = other.avgNumber;
    configTime = other.configTime;
    expressions = other.expressions;
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
  // scaler names
  List<String>? scalerNames = [];
  // visual scaler
  List<bool> visual = [];
  // visual scaler data
  List<List<int>> visualScaler = [];
  // calculated scaler value
  int avgNumber = 0;
  // config file name
  DateTime configTime = DateTime.now();
  // config expressions
  List<String> expressions = [];

  void initStub() {
    stub = EasyConfigLogicClient(
      ClientChannel(
        address,
        port: int.parse(port),
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
          connectTimeout: Duration(seconds: 3),
        ),
      ),
    );
  }

  Future<void> saveScalerNames() async {
    await Hive.initFlutter();
    var box = await Hive.openBox("device");
    box.put("device_${name}_${address}_${port}_scaler_names", scalerNames);
    await box.close();

    final current = DateTime.now();
    String timeStr =
      "${current.year}-${current.month}-${current.day}_"
      "${current.hour}:${current.minute}:${current.second}";
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File(
      "$path/.easy-config-logic/scaler_names/"
      "device_${name}_$address:${port}_$timeStr.txt"
    );
    await file.create(recursive: true);
    String content = "";
    if (scalerNames != null) {
      for (var i = 0; i < scalerNames!.length; ++i) {
        content += "$i: ${scalerNames![i]}\n";
      }
    }
    await file.writeAsString(content);
  }

  Future<void> loadScalerNames() async {
    await Hive.initFlutter();
    var box = await Hive.openBox("device");
    scalerNames = box.get("device_${name}_${address}_${port}_scaler_names");
    if (scalerNames == null) {
      scalerNames = [];
      for (var i = 0; i < scalerNum; ++i) {
        scalerNames!.add("$i");
      }
    }
    await box.close();
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
      final Request request = Request(type: 0);
      var index = 0;
      await for (var response in stub.getScaler(request)) {
        if (index < scalerNum) scaler[index] = response.value;
        ++index;
        // if (index > scalerNum) {
        //   print("Index: $index, scaler: ${response.value}");
        // }
      }
// if (index > scalerNum) {
//   print("Warning $index");
//   print(scaler);
// }
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
    var flag = 0;
    for (var i = 0; i < visual.length; ++i) {
      if (!visual[i]) continue;
      flag |= 1 << i;
    }
    final RecentRequest request = RecentRequest(
      type: scalerLiveMode,
      flag: flag
    );
    var rangeIndex = 0;
    var index = 0;
    while (index < scalerNum && !visual[index]) {
      ++index;
    }
    try {
      await for (var response in stub.getScalerRecent(request)) {
        if (rangeIndex >= 120) {
          ++index;
          while (index < scalerNum && !visual[index]) {
            ++index;
          }
          rangeIndex = 0;
        }
        if (index < scalerNum && rangeIndex < 120) {
          visualScaler[index][rangeIndex] = response.value;
          ++rangeIndex;
        }
      }
      avgNumber = 0;
    } catch (e) {
      print("Caught error: $e");
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
    }
  }

  Future<void> getConfig() async {
    try {
      final Request request = Request(type: 0);
      final response = await stub.getState(request);
      if (response.value != 3) return;
    } catch (e) {
      print("Caught error: $e");
      return;
    }

    final Request request = Request(type: 0);
    List<String> newExpressions = [];
    try {
      await for (var expr in stub.getConfig(request)) {
        newExpressions.add(expr.value);
      }
      configTime = DateTime.parse(newExpressions.first);
      expressions = newExpressions.sublist(1);
    } catch (e) {
      print("Caught error: $e");
    }
  }



  Future<ParseResult> setConfig() async {
    Stream<Expression> convertExpression() async* {
      for (var expr in expressions) {
        yield Expression(value: expr);
      }
    }
    try {
      final result = await stub.setConfig(convertExpression());
      if (
        result.value == 104
        && expressions[result.index].length == result.position
      ) {
        return ParseResult(
          index: result.index,
          status: result.value,
          position: result.position,
          length: 0,
        );
      }
      return ParseResult(
        index: result.index,
        status: result.value,
        position: result.position,
        length: result.length,
      );
    } catch (e) {
      print("Caught error: $e");
      return ParseResult(
        index: -1,
        status: 400,
        position: 0,
        length: 0,
      );
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
    // var scalerNames = reader.read();
    return DeviceModel(
      name: name,
      address: address,
      port: port,
      // scalerNames: scalerNames,
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer.write(obj.name);
    writer.write(obj.address);
    writer.write(obj.port);
    // writer.write(obj.scalerNames);
  }
}


class DeviceMapModel extends ChangeNotifier {

  DeviceMapModel();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DeviceAdapter());
    var box = await Hive.openBox("device");
    // box.deleteFromDisk();
    var deviceCount = box.get("deviceCount") ?? 0;
    // box.put("deviceCount", 0);
    for (var i = 0; i < deviceCount; ++i) {
      DeviceModel device = box.get("device$i");
      devices[device.name] = device;
    }
    for (var dev in devices.values) {
      await dev.getConfig();
    }
    await box.close();
    for (var dev in devices.values) {
      await dev.loadScalerNames();
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
    await box.close();
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
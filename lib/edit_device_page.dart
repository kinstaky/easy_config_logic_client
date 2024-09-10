import 'package:flutter/material.dart';
import 'package:easy_config_logic_client/device.dart';

class EditDevicePage extends StatefulWidget {
  const EditDevicePage({
    super.key,
    this.device,
  });

  final DeviceModel? device;

  @override
  State<EditDevicePage> createState() => _EditDevicePageState();
}

class _EditDevicePageState extends State<EditDevicePage> {

  _EditDevicePageState();

  @override
  void initState() {
    super.initState();
    textController["name"] = TextEditingController(
      text: widget.device?.name,
    );
    textController["address"] = TextEditingController(
      text: widget.device?.address,
    );
    textController["port"] = TextEditingController(
      text: widget.device?.port,
    );
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
        title: Text("${widget.device == null ? "New" : "Edit"} device"),
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
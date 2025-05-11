import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  var loading = true;
  late List<CameraDescription> _cameras;
  late CameraController controller;
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  init() async {
    _cameras = await availableCameras();

    controller = CameraController(
      _cameras.firstWhere((e) => e.lensDirection == CameraLensDirection.back),
      ResolutionPreset.max,
      enableAudio: false,
    );
    await controller.initialize();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Column(children: [Expanded(child: CameraPreview(controller))]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile image = await controller.takePicture();

          close(image);
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void close(XFile image) {
    if (!mounted) return;
    Navigator.pop(context, image);
  }
}

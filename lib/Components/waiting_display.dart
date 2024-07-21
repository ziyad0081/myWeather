import 'dart:async';

import 'package:flutter/material.dart';

class ProgressWaitDisplay extends StatefulWidget {
  const ProgressWaitDisplay({super.key});

  @override
  State<ProgressWaitDisplay> createState() => _ProgressWaitDisplayState();
}

class _ProgressWaitDisplayState extends State<ProgressWaitDisplay> {
  String dots = '';
  Timer? timer;
  int dotCount = 0;

  @override
  void initState() {

    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t){
      setState(() {
        dotCount = (dotCount+1)%4;
        dots = '.' * dotCount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children:[
          const CircularProgressIndicator(color: Colors.white,),
          const SizedBox(height: 30,),
          Text("Fetching data $dots",
            style: const TextStyle(
              color: Colors.white,
                fontWeight: FontWeight.bold),
          )
        ]
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

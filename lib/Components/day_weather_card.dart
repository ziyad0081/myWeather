import 'package:flutter/material.dart';
import 'package:weather_ui/Components/icon_map.dart';

class DayWeatherData{
  final String dayName;
  final int weatherCode;
  final double tempC;

  const DayWeatherData({
    required this.dayName,
    required this.weatherCode,
    required this.tempC
  });
}

class DayWeatherCard extends StatefulWidget {
  final DayWeatherData dayWeatherData;

  const DayWeatherCard({super.key,
  required this.dayWeatherData
  });

  @override
  State<DayWeatherCard> createState() => _DayWeatherCardState();
}

class _DayWeatherCardState extends State<DayWeatherCard> {
  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        Text(widget.dayWeatherData.dayName, style: TextStyle(fontWeight: FontWeight.bold),),
        Spacer(),
        Align(
            child: Icon(
              codeIconMap[widget.dayWeatherData.weatherCode],
              color: Colors.white,
            )
        ),
        SizedBox(width: 115,),
        Text("${widget.dayWeatherData.tempC.round()}°", style: TextStyle(fontWeight: FontWeight.bold),)
      ],
    );
  }
}

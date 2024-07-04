import 'package:flutter/material.dart';
import 'package:weather_ui/Components/icon_map.dart';

import 'package:weather_ui/Pages/weather_home.dart';

class HourWeatherCard extends StatefulWidget {
  final HourWeatherData hourWeatherData;
  const HourWeatherCard({super.key,
    required this.hourWeatherData
  });

  @override
  State<HourWeatherCard> createState() => _HourWeatherCardState();
}
 
class _HourWeatherCardState extends State<HourWeatherCard> {
  String intTo24HFormat(int hour){
    return (hour > 9 ? "$hour:00" : "0$hour:00");
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${intTo24HFormat(widget.hourWeatherData.hour)}",
          style: TextStyle(
            fontSize: (15+1)
          )
        ),
        Icon(codeIconMap[widget.hourWeatherData.weatherCode], color: Colors.white,),
        Text("${widget.hourWeatherData.hourTempC.round()}°",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}

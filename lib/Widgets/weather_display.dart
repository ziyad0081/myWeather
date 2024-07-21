import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_ui/Components/day_weather_card.dart';
import 'package:weather_ui/Components/hour_weather_card.dart';
import 'package:weather_ui/Pages/weather_home.dart';
import 'package:intl/intl.dart';

String _formattedTimeFromTimeStamp(int timestamp){
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp*1000);
  final dayFormatter = DateFormat('d MMM');
  final timeFormatter = DateFormat('HH:mm');
  final formattedDate = dayFormatter.format(dateTime);
  final formattedTime = timeFormatter.format(dateTime);
  return '$formattedDate, $formattedTime';
}

class WeatherDisplay extends StatefulWidget {
  final WeatherData? weatherData;

  const WeatherDisplay({
    super.key,
    required this.weatherData,

  });


  @override
  State<WeatherDisplay> createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay> {

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 100,),
        Text("${widget.weatherData?.region}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 35,

          ),
        ),
        Text(
          "${widget.weatherData?.tempC.round()}°",
          style: const TextStyle(
            fontSize: 80,
          ),
        ),
        Text("${widget.weatherData?.desc}",
          style: const TextStyle(
            fontSize: 25,
          ),
        ),
        Text("H:${widget.weatherData?.maxTempC.round()}° L:${widget.weatherData?.minTempC.round()}°"),

        Text("Last update: ${_formattedTimeFromTimeStamp(widget.weatherData!.lastUpdateEpoch)}" ,
          style: TextStyle(
            fontSize: 14
          ),
        ),
        SizedBox(height: 20,),
        Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Shadow color
                        spreadRadius: 5, // Spread radius
                        blurRadius: 10, // Blur radius
                        offset: Offset(0, 3), // Offset in x and y directions
                      ),
                    ]
                ),
                child: ClipRRect(

                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1)
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40,sigmaY: 40),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          children: [
                            Text("12-hours forecast",
                                style:TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(
                                color: Colors.grey.withOpacity(0.4),
                                thickness: 2,
                              ),
                            ),
                            Padding(

                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                //  Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children:
                                //     widget.weatherData!.nextHours.map((hour) {
                                //       return HourWeatherCard(hourWeatherData: hour);
                                //     }).toList()
                                // ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    Expanded(
                                      child: Container(
                                        height: 200,
                                        child: ListView.separated(

                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context, int index) {
                                            var hour = widget.weatherData!.nextHours[index];
                                            return HourWeatherCard(hourWeatherData: hour);
                                          },
                                          separatorBuilder: (BuildContext context, int index) => VerticalDivider(
                                            color: Colors.grey.withOpacity(0.4),
                                            thickness: 2,

                                          ),
                                          itemCount: widget.weatherData!.nextHours.length,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Shadow color
                        spreadRadius: 5, // Spread radius
                        blurRadius: 10, // Blur radius
                        offset: Offset(0, 3), // Offset in x and y directions
                      ),
                    ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1)
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40,sigmaY: 40),
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Text("Week forecast",
                                style:TextStyle(
                                    fontWeight: FontWeight.bold
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Divider(
                                color: Colors.grey.withOpacity(0.4),
                                thickness: 2,
                              ),
                            ),

                            Padding(

                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                //  Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   crossAxisAlignment: CrossAxisAlignment.center,
                                //   children:
                                //     widget.weatherData!.nextHours.map((hour) {
                                //       return HourWeatherCard(hourWeatherData: hour);
                                //     }).toList()
                                // ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(

                                        height: 200,

                                        child: ListView.separated(
                                          padding: EdgeInsets.only(top: 0, bottom: 10),
                                          scrollDirection: Axis.vertical,
                                          itemBuilder: (BuildContext context, int index) {
                                            return DayWeatherCard(dayWeatherData: widget.weatherData!.nextDays[index]);
                                          },
                                          separatorBuilder: (BuildContext context, int index) => Divider(
                                            color: Colors.grey.withOpacity(0.4),
                                            thickness: 2,
                                          ),
                                          itemCount: widget.weatherData!.nextDays.length,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50,)
            ],
          )
      ],
    );
  }
}

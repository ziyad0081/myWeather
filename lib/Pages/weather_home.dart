import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_ui/Components/waiting_display.dart';
import 'package:weather_ui/Widgets/weather_display.dart';
import 'package:weather_ui/Components/day_weather_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
int remainingHoursInDay(int hour){
  return 23-hour+1;
}
class WeatherData {
  final int lastUpdateEpoch;
  final String region;
  final double tempC;
  final double maxTempC;
  final double minTempC;
  final String desc;
  final List<DayWeatherData> nextDays;
  final List<HourWeatherData> nextHours;
  const WeatherData({
    required this.region,
    required this.tempC,
    required this.maxTempC,
    required this.minTempC,
    required this.desc,
    required this.nextHours,
    required this.nextDays,
    required this.lastUpdateEpoch
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final List<HourWeatherData> nextHours = [];
    final List<DayWeatherData> nextDays = [];
    final curr_t = DateTime.now().hour;
    final remHrs = min(12, remainingHoursInDay(curr_t)) ;
    for (var h = 0; h < remHrs; h++ ) {
      final curr_adj = h+curr_t;
      var code = json["forecast"]["forecastday"][0]["hour"][curr_adj]["condition"]["code"];
      var is_day = json["forecast"]["forecastday"][0]["hour"][curr_adj]["is_day"];
      nextHours.add(HourWeatherData(
          desc: json["forecast"]["forecastday"][0]["hour"][curr_adj]["condition"]["text"],
          hourTempC: json["forecast"]["forecastday"][0]["hour"][curr_adj]["temp_c"],
          hour: curr_adj,
          weatherCode: (code <= 1003 && is_day == 0  ? code+1  : code )
      ));
    }
    for (var h = 0; h < 12-remainingHoursInDay(curr_t) ; h++){
      final code = json["forecast"]["forecastday"][1]["hour"][h]["condition"]["code"];
      final is_day = json["forecast"]["forecastday"][0]["hour"][h]["is_day"];
      nextHours.add(HourWeatherData(
          desc: json["forecast"]["forecastday"][1]["hour"][h]["condition"]["text"],
          hourTempC: json["forecast"]["forecastday"][1]["hour"][h]["temp_c"],
          hour: h,
          weatherCode: (code <= 1003 && is_day == 0  ? code+1  : code )
      ));
    }
    nextDays.add(
        DayWeatherData(
            dayName: "Today",
            tempC: json["forecast"]["forecastday"][0]["day"]["avgtemp_c"],
            weatherCode:json["forecast"]["forecastday"][0]["day"]["condition"]["code"]
        )
    );
    
    nextDays.add(
        DayWeatherData(
            dayName: "Tomorrow",
            tempC: json["forecast"]["forecastday"][1]["day"]["avgtemp_c"],
            weatherCode: json["forecast"]["forecastday"][1]["day"]["condition"]["code"]
        )
    );

    for(var d = 2; d < 7; d++){
      nextDays.add(
            DayWeatherData(
          dayName: DateFormat('EEEE').format(DateTime.parse(json["forecast"]["forecastday"][d]["date"])) ,
          tempC: json["forecast"]["forecastday"][d]["day"]["avgtemp_c"],
          weatherCode: json["forecast"]["forecastday"][d]["day"]["condition"]["code"]
        )
      );
    }
    final weatherDataObj = WeatherData(
        region: json["location"]["region"],
        tempC: json["current"]["temp_c"],
        maxTempC: json["forecast"]["forecastday"][0]["day"]["maxtemp_c"],
        minTempC: json["forecast"]["forecastday"][0]["day"]["mintemp_c"],
        desc: json["current"]["condition"]["text"],
        nextHours: nextHours,
        nextDays: nextDays,
        lastUpdateEpoch: json["current"]["last_updated_epoch"]
    );

    return weatherDataObj ;
  }
}

class HourWeatherData {
  final String desc;
  final double hourTempC;
  final int hour;
  final int weatherCode;
  const HourWeatherData(
      {required this.desc, required this.hourTempC, required this.hour, required this.weatherCode});
}

class _HomePageState extends State<HomePage> {
  late Future<WeatherData> futData;
  final sharedPrefsWeatherDataKey = "last_ret_data";
  @override
  void initState() {
    super.initState();
    futData = _loadWeatherData();
  }
  Future<void> _saveWeatherDataToDisk(String jsonSourceData) async{
    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString(sharedPrefsWeatherDataKey, jsonSourceData);

  }
  Future<WeatherData> _loadWeatherData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    try {
      final result = await InternetAddress.lookup('example.com');
      if (!(result.isNotEmpty && result[0].rawAddress.isNotEmpty)) {
        throw Exception("no network connection");
      }
      final resp = await get(Uri.parse(
          "http://api.weatherapi.com/v1/forecast.json?key=b982eb0a3eca4f03934100251242806&q=Guelma&days=8"));
      if (resp.statusCode == 200) {
        final data = WeatherData.fromJson(
            jsonDecode(resp.body) as Map<String, dynamic>);
        _saveWeatherDataToDisk(resp.body);
        return data;
      } else {
        throw Exception("Error during data fetching.");
      }
    } catch (e) {
      await Future.delayed(Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No internet connection!")
        )
      );
      final savedWeatherData = sharedPrefs.getString(sharedPrefsWeatherDataKey);
      if(savedWeatherData != null){
        final oldWeatherData = WeatherData.fromJson(jsonDecode(savedWeatherData) as Map<String,dynamic>);
        return oldWeatherData;
      }
      throw Exception("No data!");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          //TODO : implement changing backgrounds
                            image: AssetImage("images/rainy.jpeg"),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken)
                        )
                      ),
                    )
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
            
                        child: Center(
                          child: FutureBuilder(
                            future: futData,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return WeatherDisplay(weatherData: snapshot.data);
                              }
                              if(snapshot.hasError){
                                return Text("Error!");
                              }
                              return const ProgressWaitDisplay();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

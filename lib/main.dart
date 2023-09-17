import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:weatherapp/const/const.dart';
import 'package:weatherapp/models/forecast_response.dart';
import 'package:weatherapp/models/weather_response.dart';
import 'package:weatherapp/network/open_weather_map_client.dart';
import 'package:weatherapp/state/state.dart';
import 'package:weatherapp/utils/utils.dart';
import 'package:weatherapp/widgets/forecast_tile_widget.dart';
import 'package:weatherapp/widgets/info_widget.dart';
import 'package:weatherapp/widgets/weather_tile_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Color(colorBg1)));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Application name
      title: 'Flutter Hello World',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'hi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = Get.put(StateController());
  var location = Location();
  late StreamSubscription listener;
  late PermissionStatus permissionStatus;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((timeStamp) async {
      await enableLocationListener();
    });
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Obx(
        () => Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  tileMode: TileMode.clamp,
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [Color(colorBg1), Color(colorBg2)])),
          child: controller.locationData.value.latitude != null
              ? FutureBuilder(
                  future: OpenWeatherMapClient()
                      .getWeather(controller.locationData.value),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString(),
                            style: const TextStyle(color: Colors.white)),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                          child: Text('No data',
                              style: TextStyle(color: Colors.white)));
                    } else {
                      var data = snapshot.data as WeatherResponse;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          WeatherTileWidget(
                              context: context,
                              title:
                                  (data.name != null && data.name!.isNotEmpty)
                                      ? data.name
                                      : '${data.coord!.lat}/${data.coord!.lon}',
                              titleFontSize: 30.0,
                              subTitle: DateFormat('dd-MM-yyyy').format(
                                  DateTime.fromMicrosecondsSinceEpoch(
                                      (data.dt ?? 0) * 1000))),
                          Center(
                            child: CachedNetworkImage(
                              imageUrl:
                                  buildIcon(data.weather![0].icon ?? '', true),
                              height: 200,
                              width: 200,
                              fit: BoxFit.fill,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      const CircularProgressIndicator(),
                              errorWidget: (context, url, err) => const Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          WeatherTileWidget(
                              context: context,
                              title: '${data.main!.temp}°C',
                              titleFontSize: 60.0,
                              subTitle: '${data.weather![0].description}'),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InfoWidget(
                                  icon: FontAwesomeIcons.wind,
                                  text: data.wind!.speed.toString()),
                              InfoWidget(
                                  icon: FontAwesomeIcons.cloud,
                                  text: data.clouds!.all.toString()),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Expanded(
                              child: FutureBuilder(
                            future: OpenWeatherMapClient()
                                .getForecast(controller.locationData.value),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(snapshot.error.toString(),
                                      style:
                                          const TextStyle(color: Colors.white)),
                                );
                              } else if (!snapshot.hasData) {
                                return const Center(
                                    child: Text('No data',
                                        style: TextStyle(color: Colors.white)));
                              } else {
                                var data = snapshot.data as ForecastResponse;

                                return ListView.builder(
                                  itemCount: data.list!.length ?? 0,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    var item = data.list![index];
                                    return ForecastTileWidget(
                                        temp: '${item.main!.temp}°C',
                                        imageUrl: buildIcon(
                                            item.weather![0].icon ?? '', false),
                                        time: DateFormat('HH:mm').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                (item.dt ?? 0) * 1000)));
                                  },
                                );
                              }
                            },
                          ))
                        ],
                      );
                    }
                  })
              : const Center(
                  child: Text(
                  'Waiting...',
                  style: TextStyle(color: Colors.white),
                )),
        ),
      )),
    );
  }

  Future<void> enableLocationListener() async {
    controller.isEnableLocation.value = await location.serviceEnabled();
    if (!controller.isEnableLocation.value) {
      controller.isEnableLocation.value = await location.requestService();
      if (!controller.isEnableLocation.value) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    controller.locationData.value = await location.getLocation();
    listener = location.onLocationChanged.listen((event) {});
  }
}

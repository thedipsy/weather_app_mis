import 'package:weatherapp/models/weather_response.dart';

class ForecastResponse {
  List<ListResponse>? list;

  ForecastResponse({this.list});

  ForecastResponse.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <ListResponse>[];
      json['list'].forEach((v) {
        list!.add(ListResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};

    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListResponse {
  int? dt;
  Main? main;
  List<Weather>? weather;

  ListResponse({this.dt, this.main});

  ListResponse.fromJson(Map<String, dynamic> json) {
    dt = json['dt'];
    main = json['main'] != null ? Main.fromJson(json['main']) : null;
    if (json['weather'] != null) {
      weather = <Weather>[];
      json['weather'].forEach((v) {
        weather!.add(Weather.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};

    if (main != null) {
      data['main'] = main!.toJson();
    }

    if (weather != null) {
      data['weather'] = weather!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

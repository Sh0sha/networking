//   afff53e81810070f873cd36b1c755d21
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(NetworkingApp());
}

class NetworkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Networking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,color: Colors.blueAccent),
          subtitle1: TextStyle(fontSize: 19, fontStyle: FontStyle.italic,color: Colors.blueGrey),
          bodyText1: TextStyle(fontSize: 25,color: Colors.red),
          bodyText2: TextStyle(fontSize: 17)

        ),
      ),
      home: WeatherScreen(),   // установка домашшнего экрана
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late String apiKey = 'afff53e81810070f873cd36b1c755d21';
  late String city = 'Paris';
  late String pogodaStatus = '';
  late double temperature = 0.0;
  late double speedVeter = 0.0;
  late int vlaga = 0;
  late List<WeatherForecast> prognozData = [];    // список для храненния прогноза погоды

  @override
  void initState() {
    super.initState();
    fetchWeatherData(); // Вызов функции для загрузки данных о текущей погоде
    fetchForecastData();// Вызов функции для загрузки прогноза погоды на ближайшие дни
  }

  Future<void> fetchWeatherData() async {
    // Формируем URL для запроса к API с указанием города и ключа API.
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    // Выполняем GET-запрос к API для получения данных о погоде.
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {     // Проверяем, успешно ли выполнен запрос (код ответа 200).
      final data = jsonDecode(response.body);  // Декодируем в формат джисон
      setState(() {     // Обновляем состояние виджета с полученными данными о погоде.
        pogodaStatus = data['weather'][0]['description'];
        temperature = data['main']['temp'];
        speedVeter = data['wind']['speed'];
        vlaga = data['main']['humidity'];
      });
    } else {
      throw Exception('Ошибка загрузки данныхч');   // искл
    }
  }

  Future<void> fetchForecastData() async {
    final url ='https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];  // Извлекаем список прогнозов погоды из полученных данных
      setState(() {   // Обновляем состояние виджета с новым прогнозом погоды
        prognozData = list
        // Преобразуем данные из формата JSON в объекты WeatherForecast
            .map((e) => WeatherForecast(
          time: DateTime.fromMillisecondsSinceEpoch(e['dt'] * 1000),
          temperature: e['main']['temp'].toDouble(),
          pogodaStatus: e['weather'][0]['description'],
        ))
            .toList();
      });
    } else {
      throw Exception('Ошибка загрузки');
    }
  }




  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
        appBar: AppBar(
        title: Text('Прогноз погоды в $city'),
    bottom: TabBar(
    tabs: [
    Tab(text: 'Сейчас'),
      Tab(text: 'Позже')

    ],
    ),
    ),
    body: TabBarView(
    children: [
    CurrentWeather(
    pogodaStatus: pogodaStatus,

      temperature: temperature,
      speedVeter: speedVeter,
      vlaga: vlaga,
    ),
      ForecastWeather(pogodaData: prognozData),

    ],
    ),
        ),
    );
  }
}

class CurrentWeather extends StatelessWidget {
  final String pogodaStatus;
  final double temperature;
  final double speedVeter;
  final int vlaga;

  CurrentWeather({
    required this.pogodaStatus,
    required this.temperature,
    required this.speedVeter,
    required this.vlaga,
  });

  @override
  Widget build(BuildContext context) {// Переопределение метода build для построения интерфейса
    return Center( // Выравнивание по центру

      child: Column(  // Столбец для вертикального размещения элементов
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          Text(
            'Состояние: $pogodaStatus',
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 30),
          Text(
            'Температура: $temperature °C',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 30),
          Text(
            'Скорость ветра: $speedVeter м/с',
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 30),
          Text(
            'Влажность: $vlaga %',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}

class ForecastWeather extends StatelessWidget {
  final List<WeatherForecast> pogodaData;

  ForecastWeather({required this.pogodaData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pogodaData.length,
      itemBuilder: (context, index) {
        if (index == 0 || pogodaData[index].time.day != pogodaData[index - 1].time.day) {
          // Добавляем разделительную линию перед новой датой
          return Column(
            children: [
              ListTile(
                title: Text(
                  '${pogodaData[index].time.day}/${pogodaData[index].time.month}/${pogodaData[index].time.year}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

              ),
              Divider(thickness: 3,color: Colors.black,), // sазделительная линия
            ],
          );
        } else {
          return ListTile(
            title: Row(
              children: [
                Text(
                  '${pogodaData[index].time.hour}:00 -',
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold ),

                ),
                SizedBox(width: 20),
                Text(
                  '${pogodaData[index].temperature} °C',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            subtitle: Text(pogodaData[index].pogodaStatus),
          );
        }
      },
    );
  }
}



class WeatherForecast {
  late DateTime time;
  late double temperature;  // переменные которые действуют когда будут использованы
  late String pogodaStatus;

  WeatherForecast({
    required this.time,
    required this.temperature,    // req необходимо обязательная передача при созд экземпл объекта
    required this.pogodaStatus,
  });
}

<?php
include './apiKeys.php';
error_reporting(0);
class WeatherForecastAggregator {

    public function getWeather(string $city): float {
        $temps = [
            $this->getFromOpenWeather($city),
            $this->getFromWeatherApi($city),
            $this->getFromVisualCrossing($city),
            $this->getFromVisualCrossing($city),
        ];

        // Убираем все значения, которые не являются числами
        $validTemps = array_filter($temps, 'is_numeric');

        if (empty($validTemps)) {
            return 0.0; // или выбросить исключение
        }

        $average = array_sum($validTemps) / count($validTemps);
        return round($average, 1);
    }


    private function getFromOpenWeather(string $city): float | false
    {
        $apiKey = $_ENV['API_KEY_OPEN_WEATHER'];
        $encodedCity = urlencode($city);
        $requestUrl = "https://api.openweathermap.org/data/2.5/forecast?q=$encodedCity&units=metric&lang=ru&appid=$apiKey";
        $weatherResponse = file_get_contents($requestUrl);
        $data = json_decode($weatherResponse, true);

        $tomorrow = date('Y-m-d', strtotime('+1 day'));
        $temps = [];

        foreach ($data['list'] as $entry) {
            if (str_starts_with($entry['dt_txt'], $tomorrow)) {
                $temps[] = $entry['main']['temp'];
            }
        }

        if (count($temps) === 0) {
            return false;
        }

        $average = array_sum($temps) / count($temps);
        return round($average, 1);
    }

    private function getFromWeatherApi($city): float | false{
        $apiKey = $_ENV['API_KEY_WEATHER_API'];
        $encodedCity = urlencode($city);
        $requestUrl = "http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$encodedCity&aqi=no&days=2";

        $weatherResponse = file_get_contents($requestUrl);
        $data = json_decode($weatherResponse, true);

        if (!isset($data['forecast']['forecastday'][1])) {
            return false;
        }
        $tomorrow = $data['forecast']['forecastday'][1];

        return $tomorrow['day']['avgtemp_c'];
    }

    private function getFromTomorrowApi($city): float | false
    {
        $apiKey = $_ENV['API_KEY_TOMORROW_API'];
        $encodedCity = urlencode($city);
        $requestUrl = "https://api.tomorrow.io/v4/weather/forecast?accept=application/json&location=$encodedCity&apikey=$apiKey";

        $weatherResponse = file_get_contents($requestUrl);
        $data = json_decode($weatherResponse, true);

        if (!isset($data['timelines']['daily'])) {
            return false;
        }

        $tomorrow = $data['timelines']['daily'];

        return $tomorrow[1]['values']['temperatureAvg'];
    }

    private function getFromVisualCrossing($city) : float | false
    {
        $apiKey = $_ENV['API_KEY_VISUAL_CROSSING'];
        $encodedCity = urlencode($city);
        $requestUrl = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$encodedCity?unitGroup=metric&key=$apiKey&contentType=json";

        $weatherResponse = file_get_contents($requestUrl);
        $data = json_decode($weatherResponse, true);

        if (!isset($data['days'][1])) {
            return false;
        }

        return $data['days'][1]['temp'];
    }
}
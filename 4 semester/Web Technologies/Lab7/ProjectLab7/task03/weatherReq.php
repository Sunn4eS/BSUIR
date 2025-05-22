<?php

require_once './WeatherService.php';

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST["city"])) {
    $city = $_POST["city"];
    $weather = new WeatherForecastAggregator();

    $temp = $weather->getWeather($city) . " °C";

    $output = "<link rel='stylesheet' href='style03.css'>";
    $output .= "<h1>Прогноз погоды на завтра в городе $city: $temp</h1>";
    echo $output;
}
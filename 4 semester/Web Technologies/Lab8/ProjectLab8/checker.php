<?php
function getBrowserName($userAgent) {
if (strpos($userAgent, 'Chrome') !== false) {
return 'Chrome';
} elseif (strpos($userAgent, 'Firefox') !== false) {
return 'Firefox';
} elseif (strpos($userAgent, 'Safari') !== false) {
return 'Safari';
} elseif (strpos($userAgent, 'Edge') !== false) {
return 'Edge';
} else {
return 'Other';
}
}

$logFile = 'browser_stats.log';
if (file_exists($logFile)) {
$userAgents = file($logFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
} else {
$userAgents = [];
}

$browserStats = [];
foreach ($userAgents as $userAgent) {
$browser = getBrowserName($userAgent);
if (isset($browserStats[$browser])) {
$browserStats[$browser]++;
} else {
$browserStats[$browser] = 1;
}
}

arsort($browserStats);

// Выводим в HTML-таблице
echo "<table border='1'>";
    echo "<thead><tr><th>Браузер</th><th>Количество</th></tr></thead>";
    echo "<tbody>";
    foreach ($browserStats as $browser => $count) {
    echo "<tr><td>" . htmlspecialchars($browser) . "</td><td>" . $count . "</td></tr>";
    }
    echo "</tbody>";
    echo "</table>";

?>
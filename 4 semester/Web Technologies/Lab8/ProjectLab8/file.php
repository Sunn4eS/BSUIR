<?php

$userAgent = $_SERVER['HTTP_USER_AGENT'];
$logFile = 'browser_stats.log';
file_put_contents($logFile, $userAgent . "\n", FILE_APPEND);

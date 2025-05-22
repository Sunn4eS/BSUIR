<?php
class ImageDownloader {

    public function download(string $url, int $max, int $maxLinks, string $dir): array
    {
        $html = file_get_contents($url);
        if (!$html) {
            return ["<p style='color:red;'>❌ Не удалось загрузить главную страницу: {$this->baseUrl}</p>"];
        }

        libxml_use_internal_errors(true);
        $dom = new DOMDocument;
        $dom->loadHTML($html);
        $xpath = new DOMXPath($dom);
        $links = $xpath->query("//a[contains(@class, 'tm-main-menu__item')]");

        if ($links->length === 0) {
            return ["<p style='color:red;'>❌ Не найдено ни одной подстраницы с обоями.</p>"];
        }

        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }

        $result = [];
        $result[] = "<h2>Результат:</h2><ul>";
        $count = 0;

        foreach ($links as $link) {
            if ($count > $maxLinks) break;

            $href = $link->getAttribute('href');
            $title = trim($link->textContent);

            $fullUrl = $this->makeAbsoluteUrl($url, $href);

            $folderName = preg_replace('/[^a-zA-Z0-9_-]+/', '_', strtolower($title));
            $subDir = $dir . DIRECTORY_SEPARATOR . $folderName;
            $imgPath = 'images' . DIRECTORY_SEPARATOR . $folderName;

            $result[] = "<li><strong>📁 Раздел: $title</strong><br>";

            $result = array_merge($result, $this->downloadFromPage($fullUrl, $max, $subDir, $imgPath));
            $result[] = "</li>";
            $count++;
        }

        return $result;
    }

    public function downloadFromPage(string $url, int $max, string $localDir, string $imgPath): array {
        $html = file_get_contents($url);
        if (!$html) {
            return ["<p style='color:red;'>❌ Не удалось загрузить подстраницу: $url</p>"];
        }

        libxml_use_internal_errors(true);
        $dom = new DOMDocument;
        $dom->loadHTML($html);
        $images = $dom->getElementsByTagName('img');
        $imageUrls = [];
        foreach ($images as $img) {
            $src = $img->getAttribute('src');
            if ($src) {
                $imageUrls[] = $src;
            }
        }

        if (!is_dir($localDir)) {
            mkdir($localDir, 0777, true);
        }

        $count = 0;
        $result = [];
        foreach ($imageUrls as $src) {
            if ($count >= $max) break;
            if (!filter_var($src, FILTER_VALIDATE_URL)) continue;

            $imageName = basename(parse_url($src, PHP_URL_PATH)) ?: uniqid('img_') . '.jpg';
            $imgData = file_get_contents($src);
            if ($imgData) {
                $localPath = $localDir . DIRECTORY_SEPARATOR . $imageName;
                file_put_contents($localPath, $imgData);
                $result[] = "<img src='$imgPath/$imageName' style='max-width:150px;margin-right:4px'/>";
                $count++;
            }
        }

        $result[] = "<p>🔽 Загружено $count изображений из <a href='$url' target='_blank'>$url</a></p>";
        return $result;
    }

    private function makeAbsoluteUrl(string $baseUrl, string $relativeUrl): string
    {
        if (parse_url($relativeUrl, PHP_URL_SCHEME)) {
            return $relativeUrl;
        }

        $parsedBase = parse_url($baseUrl);

        $scheme = $parsedBase['scheme'] ?? 'http';
        $host = $parsedBase['host'] ?? '';
        $port = isset($parsedBase['port']) ? ':' . $parsedBase['port'] : '';
        $basePath = isset($parsedBase['path']) ? rtrim(dirname($parsedBase['path']), '/') : '';

        // Если относительная ссылка начинается со слеша, просто подставляем домен
        if (str_starts_with($relativeUrl, '/')) {
            return "$scheme://$host$port$relativeUrl";
        }

        // Иначе — добавляем к текущей директории
        return "$scheme://$host$port$basePath/$relativeUrl";
    }

}
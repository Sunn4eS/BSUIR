FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY public /usr/share/nginx/html

# Кэш-бастинг на этапе сборки: подставляем в index.html короткий хеш
# содержимого каждого подключаемого файла (css/*.css, js/*.js).
#
# Зачем: без заголовков Cache-Control браузер применяет «heuristic caching»
# по Last-Modified/ETag. Старая сборка попадает в кэш браузера, и после
# пересборки образа страница подгружает прежний .js — в UI появляются новые
# элементы разметки (они в index.html), но не работает логика из устаревшего
# скрипта: пустое поле даты, неработающая валюта, отсутствующие кнопки.
# Заголовки no-store в nginx.conf этого не отменяют: уже закэшированная
# копия остаётся в кэше и повторно не запрашивается.
#
# Хеш содержимого решает задачу жёстко: изменённый файл получает новый URL,
# поэтому старая закэшированная копия просто не может быть использована.
RUN set -eu; \
    cd /usr/share/nginx/html; \
    for f in $(grep -oE '(css|js)/[A-Za-z0-9_.-]+\.(css|js)' index.html | sort -u); do \
        [ -f "$f" ] || continue; \
        h=$(md5sum "$f" | cut -c1-10); \
        sed -i "s|\"$f\"|\"$f?v=$h\"|g" index.html; \
    done

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
#!/usr/bin/env bash
# Универсальный запуск любой лабораторной через venv.
# Использование: ./run_lab.sh lab3   (можно: 3, lab1_2, lab1_3)
set -euo pipefail

MMO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$MMO_DIR"

LAB_ID="${1:-}"

case "$LAB_ID" in
  lab1|1)    FILE="lab1/code/lab1.py" ;;
  lab1_2)    FILE="lab1/code/lab1_2.py" ;;
  lab1_3)    FILE="lab1/code/lab1_3.py" ;;
  lab2|2)    FILE="lab2/code/lab2.py" ;;
  lab3|3)    FILE="lab3/code/lab3.py" ;;
  lab4|4)    FILE="lab4/code/lab4.py" ;;
  lab5|lab6|lab7|lab8|lab9|lab10|5|6|7|8|9|10)
    echo "Для lab${LAB_ID#lab} пока нет кода (папка lab${LAB_ID#lab}/code пустая)."
    exit 1 ;;
  lab*)
    N="${LAB_ID#lab}"
    if [ -f "lab$N/code/$LAB_ID.py" ]; then
      FILE="lab$N/code/$LAB_ID.py"
    else
      echo "Файл lab$N/code/$LAB_ID.py не найден."
      echo "Доступные файлы: $(ls lab*/code/*.py 2>/dev/null | tr '\n' ' ')"
      exit 1
    fi ;;
  *)
    echo "Использование: $0 lab<N>   например: $0 lab3"
    echo "Доступные лабораторные с кодом:"
    ls lab*/code/*.py 2>/dev/null | sed 's|/code/| → |'
    exit 1 ;;
esac

if [ ! -f "$FILE" ]; then
  echo "Не найден файл: $FILE"
  exit 1
fi

echo "Запуск: $FILE  (через venv)"
exec ./venv/bin/python "$FILE"
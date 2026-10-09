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
  lab5|5)    FILE="lab5/code/lab5.py" ;;
  lab6|6)    FILE="lab6/code/lab6.py" ;;
  lab7|7)    FILE="lab7/code/lab7.py" ;;
  lab8|8)    FILE="lab8/code/lab8.py" ;;
  lab9|9)    FILE="lab9/code/lab9.py" ;;
  lab10|10)
    echo "Для lab10 пока нет кода (папка lab10/code пустая)."
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
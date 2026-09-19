# -*- coding: utf-8 -*-
"""Создаёт «ЛР1_вариант3.xlsx» — один Excel-файл со всем:
  • «Отчёт»  — текст лабораторной (все разделы 1-7) + таблицы + встроенные PNG-графики
  • «Данные» — исходные данные + вычисления моделей формулами Excel
  • «Модели» — сводная таблица уравнений, R², прогнозов
  • «Графики» — нативные Excel-графики (линейный с трендами, R², прогноз)
"""
import json
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, Border, Side, PatternFill
from openpyxl.utils import get_column_letter
from openpyxl.chart import LineChart, BarChart, Reference
from openpyxl.chart.label import DataLabelList
from openpyxl.drawing.image import Image as XlImage

# ─── загрузка результатов ────────────────────────────────────────────────────
R = json.load(open("lab1_v3_results.json", encoding="utf-8"))
MODELS = R["models"]
YEARS  = R["years"]
Y      = R["y"]
FY     = R["forecast_years"]
BEST   = R["best"]

EQT = {
    "linear": "y = 69.2857 - 4.6429*t",
    "poly2":  "y = 0.1905*t^2 - 6.1667*t + 71.5714",
    "poly3":  "y = -0.2778*t^3 + 3.5238*t^2 - 17.5556*t + 81.5714",
    "poly4":  "y = -0.1970*t^4 + 2.8737*t^3 - 13.5*t^2 + 17.7864*t + 59.2857",
    "log":    "y = 68.3681 - 14.4955*ln(t)",
    "exp":    "y = 72.2049*e^(-0.0930*t)",
    "power":  "y = 70.2485*t^(-0.2830)",
}
EQ_UNI = {
    "linear": "\u0302y = 69.2857 \u2212 4.6429\u00b7t",
    "poly2":  "\u0302y = 0.1905\u00b7t\u00b2 \u2212 6.1667\u00b7t + 71.5714",
    "poly3":  "\u0302y = \u22120.2778\u00b7t\u00b3 + 3.5238\u00b7t\u00b2 \u2212 17.5556\u00b7t + 81.5714",
    "poly4":  "\u0302y = \u22120.1970\u00b7t\u2074 + 2.8737\u00b7t\u00b3 \u2212 13.5\u00b7t\u00b2 + 17.7864\u00b7t + 59.2857",
    "log":    "\u0302y = 68.3681 \u2212 14.4955\u00b7ln(t)",
    "exp":    "\u0302y = 72.2049\u00b7e^(\u22120.0930\u00b7t)",
    "power":  "\u0302y = 70.2485\u00b7t^(\u22120.2830)",
}
ORDER = ["linear","poly2","poly3","poly4","log","exp","power"]
NAME = {
    "linear":"Линейная", "poly2":"Полиномиальная (степень 2)",
    "poly3":"Полиномиальная (степень 3)", "poly4":"Полиномиальная (степень 4)",
    "log":"Логарифмическая", "exp":"Экспоненциальная", "power":"Степенная",
}
COLORS = ["#1f77b4","#2ca02c","#d62728","#9467bd","#ff7f0e","#17becf","#e377c2"]

# ─── стили ───────────────────────────────────────────────────────────────────
thin  = Side(style="thin", color="999999")
bdr   = Border(left=thin, right=thin, top=thin, bottom=thin)
hfill = PatternFill("solid", fgColor="DDEBF7")
pfill = PatternFill("solid", fgColor="FFC7CE")
wrap  = Alignment(horizontal="left", vertical="top", wrap_text=True)
ctr   = Alignment(horizontal="center", vertical="center", wrap_text=True)
b11   = Font(bold=True, size=11)
b12   = Font(bold=True, size=12)
b14   = Font(bold=True, size=14)
r11   = Font(bold=True, size=11, color="9C0006")

wb = Workbook()

# ═══════════════════════════════════════════════════════════════════════════════
# ЛИСТ «ДАННЫЕ» — исходные данные + вычисления формулами Excel
# ═══════════════════════════════════════════════════════════════════════════════
wsD = wb.active
wsD.title = "Данные"

# заголовки
HEADERS = ["Год","t","Факт y",
           "Линейная","Полином 2","Полином 3","Полином 4",
           "Логарифм.","Экспоненц.","Степенная"]
for c, h in enumerate(HEADERS, 1):
    cell = wsD.cell(1, c, value=h)
    cell.font = b11
    cell.fill = hfill
    cell.alignment = ctr
wsD.row_dimensions[1].height = 40

# коэффициенты моделей (строки 16-22)
wsD.append([])
wsD.append([])
COEFF_START = 18
wsD.cell(COEFF_START, 1, value="Коэффициенты моделей").font = b12
wsD.cell(COEFF_START, 1).fill = PatternFill("solid", fgColor="FCE4D6")
wsD.merge_cells(start_row=COEFF_START, start_column=1,
                end_row=COEFF_START, end_column=8)
coeff_headers = ["Параметр","linear","poly2","poly3","poly4","log","exp","power"]
coeff_data = [
    ["b/a","slope","c2","c3","c4","al","cexp","cpow"],
    ["a","interc","c1","c2","c3","bl","bexp","bpow"],
    ["c0","","c0","c1","c2","","",""],
    ["","","","c0","c1","","",""],
    ["","","","","c0","","",""],
]
COEFF_VALS = [
    ["", -4.642857, 0.190476, -0.277778, -0.196970, 68.368108, 72.204909, 70.248515],
    ["", 69.285714, -6.166667, 3.523810, 2.873737, -14.495533, -0.093045, -0.283043],
    ["", "", 71.571429, -17.555556, -13.500000, "", "", ""],
    ["", "", "", 81.571429, 17.786436, "", "", ""],
    ["", "", "", "", 59.285714, "", "", ""],
]
for ci, h in enumerate(coeff_headers):
    wsD.cell(COEFF_START + 1, ci + 1, value=h).font = b11
    wsD.cell(COEFF_START + 1, ci + 1).fill = hfill
for ri, (row_n, row_v) in enumerate(zip(coeff_data, COEFF_VALS)):
    for ci, val in enumerate(row_n):
        wsD.cell(COEFF_START + 2 + ri, ci + 1, value=val)
    for ci, val in enumerate(row_v):
        if val != "":
            cell = wsD.cell(COEFF_START + 2 + ri, ci + 1, value=val)
            cell.number_format = "0.000000"

CR = COEFF_START + 2  # строка первого коэффициента (row 20)

# данные и формулы (12 строк: 2014-2025)
FULL_YEARS = list(range(2014, 2026))
for i, yr in enumerate(FULL_YEARS):
    row = 2 + i
    t_val = i + 1
    wsD.cell(row, 1, value=yr)
    wsD.cell(row, 2, value=t_val)
    if yr <= 2020:
        wsD.cell(row, 3, value=Y[yr - 2014])
    # формулы: t = B{row}; коэффициенты моделей в столбцах B..H (col 2..8),
    # строки CR=20..24: linear=B20,B21; poly2=C20..22; poly3=D20..23;
    # poly4=E20..24; log=F20,F21; exp=G20,G21; power=H20,H21
    t_ref = f"$B${row}"
    # Linear: p1*t + p2
    wsD.cell(row, 4, value=f"=$B${CR}*{t_ref}+$B${CR+1}")
    # Poly2: p1*t^2 + p2*t + p3
    wsD.cell(row, 5, value=f"=$C${CR}*{t_ref}^2+$C${CR+1}*{t_ref}+$C${CR+2}")
    # Poly3: p1*t^3 + p2*t^2 + p3*t + p4
    wsD.cell(row, 6, value=f"=$D${CR}*{t_ref}^3+$D${CR+1}*{t_ref}^2+$D${CR+2}*{t_ref}+$D${CR+3}")
    # Poly4: p1*t^4 + p2*t^3 + p3*t^2 + p4*t + p5
    wsD.cell(row, 7, value=f"=$E${CR}*{t_ref}^4+$E${CR+1}*{t_ref}^3+$E${CR+2}*{t_ref}^2+$E${CR+3}*{t_ref}+$E${CR+4}")
    # Log: p1 + p2*LN(t)
    wsD.cell(row, 8, value=f"=$F${CR}+$F${CR+1}*LN({t_ref})")
    # Exp: p1*EXP(p2*t)
    wsD.cell(row, 9, value=f"=$G${CR}*EXP($G${CR+1}*{t_ref})")
    # Power: p1*t^p2
    wsD.cell(row, 10, value=f"=$H${CR}*{t_ref}^$H${CR+1}")

LAST_ROW = 13
for c in range(1, 11):
    wsD.column_dimensions[get_column_letter(c)].width = 15 if c >= 4 else 10
wsD.column_dimensions["B"].width = 5

# ═══════════════════════════════════════════════════════════════════════════════
# ЛИСТ «МОДЕЛИ» — сводная таблица
# ═══════════════════════════════════════════════════════════════════════════════
wsM = wb.create_sheet("Модели")
wsM.append(["Модель","Уравнение","R\u00b2",
            "2021","2022","2023","2024","2025"])
for c in range(1, 9):
    wsM.cell(1, c).font = b11
    wsM.cell(1, c).fill = hfill
    wsM.cell(1, c).alignment = ctr
for i, k in enumerate(ORDER, start=2):
    wsM.cell(i, 1, value=NAME[k])
    wsM.cell(i, 2, value=EQ_UNI[k])
    wsM.cell(i, 3, value=round(MODELS[k]["R2"], 4))
    wsM.cell(i, 3).number_format = "0.0000"
    for j in range(5):
        wsM.cell(i, 4 + j, value=round(MODELS[k]["fcst"][j], 3))
        wsM.cell(i, 4 + j).number_format = "0.000"
br = ORDER.index(BEST) + 2
wsM.cell(br, 3).font = r11
wsM.cell(br, 3).fill = pfill
for row in wsM.iter_rows(min_row=1, max_row=8, max_col=8):
    for cell in row:
        cell.border = bdr
wsM.column_dimensions["A"].width = 28
wsM.column_dimensions["B"].width = 48
for c in "CDEFGH":
    wsM.column_dimensions[c].width = 12

# ═══════════════════════════════════════════════════════════════════════════════
# ЛИСТ «ОТЧЁТ» — полный текст лабораторной
# ═══════════════════════════════════════════════════════════════════════════════
wsR = wb.create_sheet("Отчет")
wsR.column_dimensions["A"].width = 100
wsR.sheet_properties.pageSetUpPr.fitToPage = True

def add_text(r, text, bold=False, italic=False, size=11, fill=None):
    wsR.row_dimensions[r].height = max(18, 15 * ((len(text) // 90) + 1))
    c = wsR.cell(r, 1, value=text)
    c.font = Font(bold=bold, italic=italic, size=size)
    c.alignment = wrap
    if fill:
        c.fill = fill
    return r + 1

def add_table_row(ws, r, vals, bold=False):
    for ci, v in enumerate(vals, 1):
        c = ws.cell(r, ci, value=v)
        c.font = Font(bold=bold, size=10)
        c.border = bdr
        c.alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)

row = 1
row = add_text(row, "")
row = add_text(row, "ЛАБОРАТОРНАЯ РАБОТА № 1", bold=True, size=16)
row = add_text(row, "ПРОГНОЗ ЦЕЛЕВЫХ ПОКАЗАТЕЛЕЙ ДЕЯТЕЛЬНОСТИ ПРЕДПРИЯТИЯ",
               bold=True, size=14)
row = add_text(row, "Вариант 3. Показатель: «Затраты на обучение персонала, руб.»",
               italic=True, size=12)
row += 1

row = add_text(row, "1. ЦЕЛЬ РАБОТЫ", bold=True, size=12, fill=hfill)
row = add_text(row,
    "С использованием средств Excel и методов аналитического выравнивания "
    "временного ряда построить не менее пяти линий тренда различного вида, "
    "определить для каждой из них уравнение и коэффициент достоверности "
    "аппроксимации R², выбрать наилучшую модель по максимуму R² и рассчитать "
    "по её уравнению прогноз показателя на 5 временных шагов вперёд. "
    "Все линии тренда должны быть отображены на одном графике, подписаны в "
    "легенде и обозначены индивидуальными цветами.")
row += 1

row = add_text(row, "2. ИСХОДНЫЕ ДАННЫЕ", bold=True, size=12, fill=hfill)
row = add_text(row,
    "Данные по варианту 3 (затраты на обучение персонала, руб.) за 2014–2020 гг. "
    "приведены в таблице 1. Здесь t — номер уровня ряда (шаг квантования = 1 год).")
row += 1
# таблица 1
add_table_row(wsR, row, ("Год", "Уровень t", "Затраты, руб."), bold=True)
row += 1
for y_, t_, v_ in zip(YEARS, R["t"], Y):
    add_table_row(wsR, row, (y_, int(t_), v_))
    row += 1
row = add_text(row, "Таблица 1 — исходные данные", italic=True, size=10)
row += 1

row = add_text(row, "3. ЛИНИИ ТРЕНДА И КОЭФФИЦИЕНТЫ ДОСТОВЕРНОСТИ", bold=True, size=12, fill=hfill)
row = add_text(row,
    "Для временного ряда построены семь линий тренда: линейная, полиномиальная "
    "степени 2, 3 и 4, логарифмическая, экспоненциальная и степенная. "
    "Уравнения и коэффициенты достоверности R² приведены в таблице 2.")
row += 1
add_table_row(wsR, row, ("Модель", "Уравнение", "R²"), bold=True)
row += 1
for k in ORDER:
    add_table_row(wsR, row, (NAME[k], EQ_UNI[k], round(MODELS[k]["R2"], 4)))
    row += 1
row = add_text(row, "Таблица 2 — уравнения линий тренда и коэффициенты достоверности",
               italic=True, size=10)
row += 1

row = add_text(row,
    "Рис. 1. Временной ряд, 7 линий тренда (уравнения и R² в легенде) "
    "и прогноз на 5 шагов вперёд (см. встроенный ниже график).",
    italic=True, size=10)
row += 1

# встраиваем PNG основного графика
img1 = XlImage("lab1_v3_trends.png")
img1.width = 960
img1.height = 610
wsR.add_image(img1, f"A{row}")
row += 22

row = add_text(row, "4. ВЫБОР НАИЛУЧШЕЙ МОДЕЛИ", bold=True, size=12, fill=hfill)
row = add_text(row,
    f"Наибольший коэффициент достоверности R² = {MODELS[BEST]['R2']:.4f} "
    f"(96,6% дисперсии ряда объяснено моделью) имеет модель "
    f"«{NAME[BEST]}». Сравнение моделей по R² показано на рис. 2.")
row = add_text(row,
    f"Уравнение лучшей модели:  \u0302y = \u22120.1970\u00b7t\u2074 "
    f"+ 2.8737\u00b7t\u00b3 \u2212 13.5000\u00b7t\u00b2 "
    f"+ 17.7864\u00b7t + 59.2857,   R² = {MODELS[BEST]['R2']:.4f}.")
row += 1

img2 = XlImage("lab1_v3_r2.png")
img2.width = 620
img2.height = 390
wsR.add_image(img2, f"A{row}")
row = add_text(row,
    "Рис. 2. Сравнение коэффициентов достоверности R² по выбранным моделям",
    italic=True, size=10)
row += 14

row = add_text(row, "5. ПРОГНОЗ НА 5 ВРЕМЕННЫХ ШАГОВ ВПЕРЁД", bold=True, size=12, fill=hfill)
row = add_text(row,
    "Прогнозные значения получены подстановкой t = 8, 9, …, 12 "
    "(2021–2025 гг.) в уравнение выбранной модели (таблица 3, рис. 3).")
row += 1
add_table_row(wsR, row, ("Год", "t", "Прогноз \u0302y, руб."), bold=True)
row += 1
for i, (yf, v_) in enumerate(zip(FY, MODELS[BEST]["fcst"])):
    add_table_row(wsR, row, (yf, 8 + i, f"{v_:.3f}"))
    row += 1
row = add_text(row, "Таблица 3 — прогноз по лучшей модели на 2021–2025 гг.",
               italic=True, size=10)
row += 1

img3 = XlImage("lab1_v3_forecast.png")
img3.width = 620
img3.height = 385
wsR.add_image(img3, f"A{row}")
row = add_text(row,
    "Рис. 3. Прогноз «Затрат на обучение персонала» на 5 шагов вперёд",
    italic=True, size=10)
row += 14

row = add_text(row, "6. ЗАМЕЧАНИЕ ОБ АДЕКВАТНОСТИ ЭКСТРАПОЛЯЦИИ",
               bold=True, size=12, fill=hfill)
row = add_text(row,
    "Наибольший R² у полинома 4-й степени достигается за счёт тесной "
    "подгонки под исходные точки; при экстраполяции далеко за пределами "
    "наблюдаемого интервала крылья полинома высокой степени быстро уводят "
    "прогноз в область отрицательных значений (t = 10…12), что экономически "
    "невозможно для затрат. Поэтому для практического краткосрочного "
    "прогноза этого убывающего ряда целесообразно дополнительно рассмотреть "
    "экспоненциальную модель (R² = 0.9153) и квадратичную модель (R² = 0.9144), "
    "которые дают монотонно убывающие и всегда положительные значения.")
row += 1

row = add_text(row, "7. ВЫВОД", bold=True, size=12, fill=hfill)
fcst_str = "; ".join(
    f"{FY[i]} г. — {MODELS[BEST]['fcst'][i]:.2f}" for i in range(len(FY)))
row = add_text(row,
    "В ходе работы построен график временного ряда «Затраты на обучение "
    "персонала», к нему подобраны 7 линий тренда различного вида; для каждой "
    "линии определены уравнение и коэффициент достоверности R². Лучшей по R² "
    f"признана модель «{NAME[BEST]}» (R² = {MODELS[BEST]['R2']:.4f}). "
    "По уравнению выбранной модели выполнен прогноз на 5 шагов вперёд "
    f"(2021–2025 гг.): {fcst_str} руб.")

# ═══════════════════════════════════════════════════════════════════════════════
# ЛИСТ «ГРАФИКИ» — нативные Excel-графики
# ═══════════════════════════════════════════════════════════════════════════════
wsG = wb.create_sheet("Графики")

# --- Рис. 1: основной линейный график ---
c1 = LineChart()
c1.title = ("Рис. 1. Затраты на обучение персонала: "
            "временной ряд + 7 линий тренда + прогноз")
c1.x_axis.title = "Год"
c1.y_axis.title = "Затраты, руб."
c1.x_axis.numFmt = "0"
c1.width, c1.height = 28, 17
c1.style = 10

cats = Reference(wsD, min_col=1, min_row=2, max_row=13)
# факт (col 3) — только 7 точек
fact = Reference(wsD, min_col=3, min_row=1, max_row=8)
c1.add_data(fact, titles_from_data=True)
c1.set_categories(cats)
s0 = c1.series[0]
s0.graphicalProperties.line.solidFill = "111111"
s0.graphicalProperties.line.width = 28000
s0.marker.symbol = "circle"
s0.marker.size = 8

# 7 трендов (cols 4..10, 12 строк)
for ci in range(4, 11):
    ref = Reference(wsD, min_col=ci, min_row=1, max_row=13)
    c1.add_data(ref, titles_from_data=True)
    s = c1.series[ci - 3]
    s.graphicalProperties.line.solidFill = COLORS[ci - 4]
    s.graphicalProperties.line.width = 22000

c1.legend.position = "b"
wsG.add_chart(c1, "B2")

# --- Рис. 2: сравнение R² ---
c2 = BarChart()
c2.type = "bar"
c2.title = "Рис. 2. Сравнение R²"
c2.width, c2.height = 20, 14
c2.style = 10

r2_ref = Reference(wsM, min_col=3, min_row=1, max_row=8)
cats2  = Reference(wsM, min_col=1, min_row=2, max_row=8)
c2.add_data(r2_ref, titles_from_data=True)
c2.set_categories(cats2)
s2 = c2.series[0]
s2.graphicalProperties.solidFill = "4472C4"
s2.dLbls = DataLabelList()
s2.dLbls.showVal = True
s2.dLbls.numFmt = "0.0000"
c2.legend = None
wsG.add_chart(c2, "B34")

# --- Рис. 3: прогноз лучшей модели ---
# формируем отдельный блок для bar chart
wsG.cell(34, 12, value="Год").font = b11
wsG.cell(34, 13, value="\u0302y, руб.").font = b11
for j, yf in enumerate(FY):
    wsG.cell(35 + j, 12, value=yf)
    wsG.cell(35 + j, 13, value=round(MODELS[BEST]["fcst"][j], 3))

c3 = BarChart()
c3.type = "col"
c3.title = (f"Рис. 3. Прогноз: {NAME[BEST]} (R²={MODELS[BEST]['R2']:.4f})")
c3.x_axis.title = "Год"
c3.y_axis.title = "Затраты, руб."
c3.width, c3.height = 20, 14
c3.style = 10

fc_vals = Reference(wsG, min_col=13, min_row=34, max_row=39)
fc_cats = Reference(wsG, min_col=12, min_row=35, max_row=39)
c3.add_data(fc_vals, titles_from_data=True)
c3.set_categories(fc_cats)
s3 = c3.series[0]
s3.graphicalProperties.solidFill = COLORS[3]
s3.dLbls = DataLabelList()
s3.dLbls.showVal = True
s3.dLbls.numFmt = "0.00"
c3.legend = None
wsG.add_chart(c3, "L34")

# ─── порядок листов: «Отчет», «Данные», «Модели», «Графики» ─────────────────
order = ["Отчет", "Данные", "Модели", "Графики"]
wb._sheets = [wb[name] for name in order]
wb.active = 0

OUT = "ЛР1_вариант3.xlsx"
wb.save(OUT)
print(f"Сохранён: {OUT}")
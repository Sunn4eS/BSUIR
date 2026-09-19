# -*- coding: utf-8 -*-
"""Формирует Excel-файл (lab1_v3.xlsx) и отчёт Word (lab1_v3_otchet.docx)
по ЛР1, вариант 3 (Затраты на обучение персонала)."""
import json
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, Border, Side, PatternFill
from openpyxl.drawing.image import Image as XlImage
from openpyxl.utils import get_column_letter
from docx import Document
from docx.shared import Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT

R = json.load(open("lab1_v3_results.json", encoding="utf-8"))
MODELS = R["models"]
YEARS = R["years"]
Y = R["y"]
FY = R["forecast_years"]
BEST = R["best"]

EQ = {
    "linear": "y = 69.2857 − 4.6429·t",
    "poly2":  "y = 0.1905·t² − 6.1667·t + 71.5714",
    "poly3":  "y = −0.2778·t³ + 3.5238·t² − 17.5556·t + 81.5714",
    "poly4":  "y = −0.1970·t⁴ + 2.8737·t³ − 13.5000·t² + 17.7864·t + 59.2857",
    "log":    "y = 68.3681 − 14.4955·ln(t)",
    "exp":    "y = 72.2049·e^(−0.0930·t)",
    "power":  "y = 70.2485·t^(−0.2830)",
}
ORDER = ["linear", "poly2", "poly3", "poly4", "log", "exp", "power"]
NAME = {k: MODELS[k]["name"] for k in ORDER}

thin = Side(style="thin", color="999999")
border = Border(left=thin, right=thin, top=thin, bottom=thin)
hfill = PatternFill("solid", fgColor="DDEBF7")
center = Alignment(horizontal="center", vertical="center")

# ============================== EXCEL ==============================
wb = Workbook()

ws = wb.active
ws.title = "Данные"
ws.append(["Год", "t", "Затраты на обучение персонала, руб."])
for y_, t_, v_ in zip(YEARS, R["t"], Y):
    ws.append([y_, t_, v_])
for c in (1, 2, 3):
    ws.cell(row=1, column=c).font = Font(bold=True)
    ws.cell(row=1, column=c).fill = hfill
    ws.cell(row=1, column=c).alignment = center
ws.append([])
ws.append(["ПРОГНОЗ на 5 шагов вперёд (модель «Полиномиальная степень 4», R²=0.9660)"])
ws.cell(row=len(YEARS) + 3, column=1).font = Font(bold=True)
ws.append(["Год", "t", "Прогнозное значение, руб."])
for i, yf in enumerate(FY):
    ws.append([yf, 8 + i, round(MODELS[BEST]["fcst"][i], 3)])
for c in (1, 2, 3):
    ws.cell(row=len(YEARS) + 4, column=c).font = Font(bold=True)
ws.cell(row=len(YEARS) + 4, column=1).fill = hfill
for col, w in zip("ABC", (12, 8, 34)):
    ws.column_dimensions[col].width = w

ws2 = wb.create_sheet("Модели")
ws2.append(["Модель", "Уравнение", "R²", "Прогноз R²-лучшей модели (t=8..12)",
            "Прогноз t=8", "t=9", "t=10", "t=11", "t=12"])
for c in range(1, 10):
    ws2.cell(row=1, column=c).font = Font(bold=True)
    ws2.cell(row=1, column=c).fill = hfill
    ws2.cell(row=1, column=c).alignment = center
ws2.cell(row=1, column=1).value = "Модель"
for i, k in enumerate(ORDER, start=2):
    ws2.cell(row=i, column=1, value=NAME[k])
    ws2.cell(row=i, column=2, value=EQ[k])
    ws2.cell(row=i, column=3, value=round(MODELS[k]["R2"], 4))
    ws2.cell(row=i, column=5, value=round(MODELS[k]["fcst"][0], 3))
    ws2.cell(row=i, column=6, value=round(MODELS[k]["fcst"][1], 3))
    ws2.cell(row=i, column=7, value=round(MODELS[k]["fcst"][2], 3))
    ws2.cell(row=i, column=8, value=round(MODELS[k]["fcst"][3], 3))
    ws2.cell(row=i, column=9, value=round(MODELS[k]["fcst"][4], 3))
for row in ws2.iter_rows(min_row=1, max_row=8, max_col=9):
    for cell in row:
        cell.border = border
ws2.column_dimensions["A"].width = 30
ws2.column_dimensions["B"].width = 42
for col in "CDEFGHI":
    ws2.column_dimensions[col].width = 11
ws2.cell(row=2 + ORDER.index(BEST), column=3).font = Font(bold=True,
        color="9C0006")
ws2.cell(row=2 + ORDER.index(BEST), column=3).fill = PatternFill("solid",
        fgColor="FFC7CE")
img = XlImage("lab1_v3_trends.png")
img.width = 980
img.height = 624
ws2.add_image(img, "A11")

ws3 = wb.create_sheet("Прогноз")
ws3["A1"] = "Прогнозные значения по всем моделям (t=8..12)"
ws3["A1"].font = Font(bold=True)
ws3.append(["Год", "t"] + FY)
ws3.cell(row=2, column=1).font = Font(bold=True)
ws3.cell(row=2, column=2).font = Font(bold=True)
for c in range(3, 8):
    ws3.cell(row=2, column=c).font = Font(bold=True)
for i, k in enumerate(ORDER, start=3):
    ws3.cell(row=i, column=1, value=NAME[k])
    ws3.cell(row=i, column=2, value=8)
    for j in range(5):
        ws3.cell(row=i, column=3 + j, value=round(MODELS[k]["fcst"][j], 3))
for row in ws3.iter_rows(min_row=2, max_row=9, max_col=7):
    for cell in row:
        cell.border = border
ws3.column_dimensions["A"].width = 32
for col in "BCDEFG":
    ws3.column_dimensions[col].width = 10
imgf = XlImage("lab1_v3_forecast.png")
imgf.width = 780
imgf.height = 475
ws3.add_image(imgf, "I3")

wb.save("lab1_v3.xlsx")
print("Excel сохранён: lab1_v3.xlsx")

# ============================== WORD ==============================
doc = Document()
style = doc.styles["Normal"]
style.font.name = "Times New Roman"
style.font.size = Pt(12)
style._element.rPr.rFonts.set(__import__("docx.oxml.ns",
        fromlist=["qn"]).qn("w:eastAsia"), "Times New Roman")

def p(text="", bold=False, size=12, align=None, italic=False):
    par = doc.add_paragraph()
    run = par.add_run(text)
    run.bold = bold
    run.italic = italic
    run.font.size = Pt(size)
    if align:
        par.alignment = align
    return par

def h1(t):  return doc.add_heading(t, level=1)
def h2(t):  return doc.add_heading(t, level=2)

h1("ЛАБОРАТОРНАЯ РАБОТА № 1")
p("ПРОГНОЗ ЦЕЛЕВЫХ ПОКАЗАТЕЛЕЙ ДЕЯТЕЛЬНОСТИ ПРЕДПРИЯТИЯ", bold=True, size=14,
  align=WD_ALIGN_PARAGRAPH.CENTER)
p("Вариант 3. Показатель: «Затраты на обучение персонала, руб.»", italic=True,
  size=12, align=WD_ALIGN_PARAGRAPH.CENTER)

h2("1. Цель работы")
p("С использованием средств Excel и методов аналитического выравнивания "
  "временного ряда построить не менее пяти линий тренда различного вида, "
  "определить для каждой из них уравнение и коэффициент достоверности "
  "аппроксимации R², выбрать наилучшую модель по максимуму R² и рассчитать "
  "по её уравнению прогноз показателя на 5 временных шагов вперёд. "
  "Все линии тренда должны быть отображены на одном графике, подписаны в "
  "легенде и обозначены индивидуальными цветами.")

h2("2. Исходные данные")
p("Данные по варианту 3 (затраты на обучение персонала, руб., за 2014–2020 гг.) "
  "приведены в таблице 1. Здесь t — номер уровня ряда (шаг квантования — 1 год).")
tbl = doc.add_table(rows=len(YEARS) + 1, cols=3)
tbl.style = "Table Grid"
tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
hdr = tbl.rows[0].cells
for j, t_ in enumerate(("Год", "Уровень ряда t", "Затраты, руб.")):
    hdr[j].text = t_
    hdr[j].paragraphs[0].runs[0].bold = True
for i, (y_, t_, v_) in enumerate(zip(YEARS, R["t"], Y), start=1):
    tbl.rows[i].cells[0].text = str(y_)
    tbl.rows[i].cells[1].text = str(int(t_))
    tbl.rows[i].cells[2].text = str(v_)
p()
p("Таблица 1", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

h2("3. Линии тренда и коэффициенты достоверности")
p("Для временного ряда построены семь линий тренда: линейная, "
  "полиномиальная степени 2, 3 и 4, логарифмическая, экспоненциальная и "
  "степенная. Уравнения и коэффициенты достоверности аппроксимации R² "
  "приведены в таблице 2, графическое представление — на рис. 1.")
tbl2 = doc.add_table(rows=len(ORDER) + 1, cols=3)
tbl2.style = "Table Grid"
for j, t_ in enumerate(("Модель", "Уравнение", "R²")):
    c = tbl2.rows[0].cells[j]
    c.text = t_
    c.paragraphs[0].runs[0].bold = True
for i, k in enumerate(ORDER, start=1):
    tbl2.rows[i].cells[0].text = NAME[k]
    tbl2.rows[i].cells[1].text = EQ[k]
    tbl2.rows[i].cells[2].text = f"{MODELS[k]['R2']:.4f}"
p()
p("Таблица 2 — уравнения линий тренда и коэффициенты достоверности",
  italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

doc.add_picture("lab1_v3_trends.png", width=Cm(24.5))
p("Рис. 1. Временной ряд, линии тренда (уравнения и R² — в легенде) и "
  "прогноз на 5 шагов вперёд", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

h2("4. Выбор наилучшей модели")
p(f"Наибольший коэффициент достоверности R² = {MODELS[BEST]['R2']:.4f} "
  f"(96,6% дисперсии ряда объяснено моделью) имеет модель "
  f"«{NAME[BEST]}». Сравнение моделей по R² показано на рис. 2.")
p(f"Уравнение лучшей модели:  ŷ = −0.1970·t⁴ + 2.8737·t³ − 13.5000·t² "
  f"+ 17.7864·t + 59.2857,   R² = {MODELS[BEST]['R2']:.4f}.")
doc.add_picture("lab1_v3_r2.png", width=Cm(16))
p("Рис. 2. Сравнение коэффициентов достоверности R² по выбранным моделям",
  italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

h2("5. Прогноз на 5 временных шагов вперёд")
p("Прогнозные значения получены подстановкой t = 8, 9, …, 12 "
  "(2021–2025 гг.) в уравнение выбранной модели (таблица 3, рис. 3).")
tbl3 = doc.add_table(rows=len(FY) + 1, cols=3)
tbl3.style = "Table Grid"
for j, t_ in enumerate(("Год", "t", "Прогноз ŷ, руб.")):
    c = tbl3.rows[0].cells[j]
    c.text = t_
    c.paragraphs[0].runs[0].bold = True
for i, (yf, v_) in enumerate(zip(FY, MODELS[BEST]["fcst"]), start=1):
    tbl3.rows[i].cells[0].text = str(yf)
    tbl3.rows[i].cells[1].text = str(int(R["t"][-1] + i))
    tbl3.rows[i].cells[2].text = f"{v_:.3f}"
p()
p("Таблица 3 — прогноз по лучшей модели на 2021–2025 гг.",
  italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)
doc.add_picture("lab1_v3_forecast.png", width=Cm(15.5))
p("Рис. 3. Прогноз «Затрат на обучение персонала» на 5 шагов вперёд",
  italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

h2("6. Замечание об адекватности экстраполяции")
p("Наибольший R² у полинома 4-й степени достигается за счёт тесной "
  "подгонки под исходные точки; при экстраполяции далеко за пределами "
  "наблюдаемого интервала крылья полинома высокой степени быстро уводят "
  "прогноз в область отрицательных значений (t = 10…12), что экономически "
  "невозможно для затрат. Поэтому для практического краткосрочного "
  "прогноза этого убывающего ряда целесообразно дополнительно рассмотреть "
  "экспоненциальную модель (ŷ = 72.2049·e^(−0.0930·t), R² = 0.9153) и "
  "квадратичную модель (ŷ = 0.1905·t² − 6.1667·t + 71.5714, R² = 0.9144), "
  "которые дают монотонно убывающие и всегда положительные значения.")

h2("7. Вывод")
p("В ходе работы построен график временного ряда «Затраты на обучение "
  "персонала», к нему подобраны 7 линий тренда различного вида; для каждой "
  "линии определены уравнение и коэффициент достоверности R². Лучшей по R² "
  f"признана модель «{NAME[BEST]}» (R² = {MODELS[BEST]['R2']:.4f}). "
  "По уравнению выбранной модели выполнен прогноз на 5 шагов вперёд "
  "(2021–2025 гг.): " +
  "; ".join(f"{FY[i]} г. — {MODELS[BEST]['fcst'][i]:.2f}"
            for i in range(len(FY))) + " руб.")

doc.save("lab1_v3_otchet.docx")
print("Отчёт сохранён: lab1_v3_otchet.docx")
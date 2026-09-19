"""ЛР1 (вариант 3): 'Затраты на обучение персонала, руб.'.
Построение 7 линий тренда, расчёт R2, выбор лучшей модели
и прогноз на 5 временных шагов вперёд.
"""
import json
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

YEARS = np.arange(2014, 2021)          # t = 1..7
T = np.arange(1, len(YEARS) + 1, dtype=float)
Y = np.array([66, 62, 50, 51, 45, 46, 35], dtype=float)
N_FORECAST = 5                          # шагов вперёд
T_FUT = np.arange(len(YEARS) + 1, len(YEARS) + 1 + N_FORECAST)
Y_FUT_YEARS = np.arange(YEARS[-1] + 1, YEARS[-1] + 1 + N_FORECAST)


def r2(y, yhat):
    return 1 - np.sum((y - yhat) ** 2) / np.sum((y - y.mean()) ** 2)


def poly_repr(coeffs, var="t"):
    """coeffs = [старшая..., 0], напр. из np.polyfit."""
    terms = []
    n = len(coeffs) - 1
    for p, c in zip(range(n, -1, -1), coeffs):
        if abs(c) < 1e-12:
            continue
        if p == 0:
            s = f"{c:+.4f}"
        else:
            s = f"{c:+.4f}{var}{p if p > 1 else ''}"
        terms.append(s)
    if not terms:
        return "0"
    expr = " ".join(terms)
    return expr[2:] if expr.startswith("+") else expr


models = {}
order = []

# 1. Линейная  y = a + b t
b, a = np.polyfit(T, Y, 1)
m = dict(name="Линейная", f=lambda tt: a + b * tt, R2=r2(Y, a + b * T))
m["formula"] = (f"$\\hat y = {poly_repr([b, a])}$"
                f"\n$R^2 = {m['R2']:.4f}$")
models["linear"] = m
order.append("linear")

# 2..4. Полиномиальные (степени 2..4)
for k in (2, 3, 4):
    c = np.polyfit(T, Y, k)
    m = dict(name=f"Полиномиальная (степень {k})",
             f=lambda tt, c=c: np.polyval(c, tt),
             R2=r2(Y, np.polyval(c, T)))
    m["formula"] = (f"$\\hat y = {poly_repr(c)}$"
                    f"\n$R^2 = {m['R2']:.4f}$")
    models[f"poly{k}"] = m
    order.append(f"poly{k}")

# 5. Логарифмическая  y = al + bl*ln(t)
bl, al = np.polyfit(np.log(T), Y, 1)
m = dict(name="Логарифмическая",
         f=lambda tt: al + bl * np.log(tt),
         R2=r2(Y, al + bl * np.log(T)))
m["formula"] = (f"$\\hat y = {al:+.4f} {bl:+.4f}\\,\\ln t$"
                f"\n$R^2 = {m['R2']:.4f}$")
models["log"] = m
order.append("log")

# 6. Экспоненциальная  y = c * e^(b t)
bexp, lnc = np.polyfit(T, np.log(Y), 1)
cexp = np.exp(lnc)
m = dict(name="Экспоненциальная",
         f=lambda tt: cexp * np.exp(bexp * tt),
         R2=r2(Y, cexp * np.exp(bexp * T)))
m["formula"] = (f"$\\hat y = {cexp:.4f}\\,e^{{{bexp:+.4f}t}}$"
                f"\n$R^2 = {m['R2']:.4f}$")
models["exp"] = m
order.append("exp")

# 7. Степенная  y = c * t^b
bpow, lncpow = np.polyfit(np.log(T), np.log(Y), 1)
cpow = np.exp(lncpow)
m = dict(name="Степенная",
         f=lambda tt: cpow * tt ** bpow,
         R2=r2(Y, cpow * T ** bpow))
m["formula"] = (f"$\\hat y = {cpow:.4f}\\,t^{{{bpow:+.4f}}}$"
                f"\n$R^2 = {m['R2']:.4f}$")
models["power"] = m
order.append("power")

best_key = max(order, key=lambda k_: models[k_]["R2"])
best = models[best_key]
for k_ in order:
    models[k_]["fcst"] = [float(models[k_]["f"](t)) for t in T_FUT]

color = dict(linear="#1f77b4", poly2="#2ca02c", poly3="#d62728",
             poly4="#9467bd", log="#ff7f0e", exp="#17becf", power="#e377c2")

# ============================ ГРАФИК 1: все тренды ============================
fig, ax = plt.subplots(figsize=(16.5, 10.5))
X0 = YEARS[0] - 1                 # сдвиг t -> год: год = t + X0
x_hist = np.linspace(1, len(YEARS), 300)

# история всех трендов
for k_ in order:
    m = models[k_]
    c = color[k_]
    ax.plot(x_hist + X0, m["f"](x_hist), color=c, lw=2.4)

handles = [plt.Line2D([0], [0], color="#111111", lw=2, marker="o", ms=8,
                      label="Данные (затраты на обучение персонала)")]
for k_ in order:
    m = models[k_]
    handles.append(plt.Line2D([0], [0], color=color[k_], lw=2.6,
                              label=f"{m['name']}\n{m['formula']}"))

# прогнозная экстраполяция всех трендов (пунктир) и прогноз лучшей модели
x_full = np.linspace(len(YEARS), len(YEARS) + N_FORECAST, 300)
for k_ in order:
    m = models[k_]
    c = color[k_]
    ax.plot(x_full + X0, m["f"](x_full), color=c, lw=2.0,
            ls="--", alpha=0.55)
handles.append(plt.Line2D([0], [0], color="#555555", ls="--", lw=2,
                          label="Пунктир — экстраполяция тренда "
                                "на 5 шагов вперёд (2021–2025)"))
handles.append(plt.Line2D([0], [0], marker="*", ls="", ms=16,
                          color=color[best_key], label="Прогноз лучшей модели"))
ax.scatter(Y_FUT_YEARS, best["fcst"], marker="*", s=420, zorder=12,
           color=color[best_key])

# значения лучшего прогноза (там, где помещаются в границы графика)
for yy, vv in zip(Y_FUT_YEARS, best["fcst"]):
    if ax.get_ylim()[0] - 0.15 * (ax.get_ylim()[1] - ax.get_ylim()[0]) < vv < \
       ax.get_ylim()[1] + 0.15 * (ax.get_ylim()[1] - ax.get_ylim()[0]):
        ax.annotate(f"{vv:,.1f}", (yy, vv), textcoords="offset points",
                    xytext=(0, 14), ha="center", fontsize=10,
                    color="#333333", fontweight="bold")

ax.axvline(YEARS[-1] + 0.5, color="#999999", ls=":", lw=1)
ax.set_xlim(YEARS[0] - 0.5, YEARS[-1] + N_FORECAST + 0.8)
ax.set_ylim(-150, 100)
ax.text(YEARS[-1] + 0.6, ax.get_ylim()[1] - 5, "прогноз →",
        fontsize=12, color="#555555")
ax.set_xlabel("Год", fontsize=13)
ax.set_ylabel("Затраты на обучение персонала, руб.", fontsize=13)
ax.set_title("Вариант 3. «Затраты на обучение персонала»: временной ряд, "
             "7 линий тренда и прогноз на 5 шагов вперёд", fontsize=15)
ax.grid(alpha=0.3, ls="--")
ax.legend(handles=handles, loc="upper right", fontsize=9, framealpha=0.97)
fig.tight_layout()
fig.savefig("lab1_v3_trends.png", dpi=200, bbox_inches="tight")
plt.close(fig)
print("График 1 сохранён: lab1_v3_trends.png")

# ================= ГРАФИК 2: сравнение R2 =================
keys_sorted = sorted(order, key=lambda k_: models[k_]["R2"])
labels = [models[k_]["name"] for k_ in keys_sorted]
vals = [models[k_]["R2"] for k_ in keys_sorted]
cols = [color[k_] for k_ in keys_sorted]
fig, ax = plt.subplots(figsize=(11, 6.6))
bars = ax.barh(labels, vals, color=cols, edgecolor="black", lw=0.5)
for i, r2v in enumerate(vals):
    ax.text(r2v + 0.004, i, f"{r2v:.4f}", va="center", fontsize=11)
bars[keys_sorted.index(best_key)].set_hatch("//")
ax.set_xlim(0, 1.06)
ax.set_xlabel("Коэффициент достоверности аппроксимации R²", fontsize=12)
ax.set_title(f"Сравнение коэффициентов достоверности R² (лучшая модель — "
             f"«{best['name']}», выделена штриховкой)", fontsize=14)
ax.grid(axis="x", alpha=0.3, ls="--")
fig.tight_layout()
fig.savefig("lab1_v3_r2.png", dpi=200, bbox_inches="tight")
plt.close(fig)
print("График 2 сохранён: lab1_v3_r2.png")

# ================= ГРАФИК 3: прогноз =================
fig, ax = plt.subplots(figsize=(10.5, 6.4))
bars = ax.bar(Y_FUT_YEARS.astype(int), best["fcst"],
              color=[color[best_key]] * len(best["fcst"]),
              edgecolor="black", lw=0.6)
for i, v in enumerate(best["fcst"]):
    ax.text(Y_FUT_YEARS[i], v, f"{v:,.1f}", ha="center",
            va="bottom" if v >= 0 else "top", fontsize=11)
ax.axhline(0, color="#333333", lw=0.8)
ax.set_xlabel("Год", fontsize=12)
ax.set_ylabel("Затраты на обучение персонала, руб.", fontsize=12)
ax.set_title(f"Прогноз на 5 шагов вперёд по лучшей модели "
             f"«{best['name']}» (R² = {best['R2']:.4f})", fontsize=14)
ax.grid(alpha=0.3, ls="--")
fig.tight_layout()
fig.savefig("lab1_v3_forecast.png", dpi=200, bbox_inches="tight")
plt.close(fig)
print("График 3 сохранён: lab1_v3_forecast.png")

# ================= РЕЗУЛЬТАТЫ =================
out = {
    "years": YEARS.astype(int).tolist(), "t": T.tolist(), "y": Y.tolist(),
    "forecast_years": Y_FUT_YEARS.astype(int).tolist(),
    "best": best_key, "best_R2": best["R2"], "best_name": best["name"],
    "models": {k_: {"name": models[k_]["name"], "R2": models[k_]["R2"],
                    "fcst": models[k_]["fcst"]} for k_ in order},
}
with open("lab1_v3_results.json", "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
print("Результаты сохранены: lab1_v3_results.json")
print(f"\nЛучшая модель: {best['name']}, R² = {best['R2']:.6f}")
print("Прогноз " + " | ".join(map(str, Y_FUT_YEARS.astype(int))) + ":",
      [round(v, 3) for v in best["fcst"]])
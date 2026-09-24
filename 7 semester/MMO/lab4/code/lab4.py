import os
import tkinter as tk
from tkinter import ttk, filedialog
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.calibration import CalibratedClassifierCV
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                             f1_score, roc_auc_score, roc_curve,
                             confusion_matrix, classification_report)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

TARGET = 'default'
OUTLIER_FEATURES = ['income', 'debtinc', 'creddebt', 'othdebt']
CONTINUOUS_COLS = ['age', 'employ', 'address', 'income', 'debtinc',
                   'creddebt', 'othdebt']
RUS_COLS = {
    'age': 'возраст', 'ed': 'образование', 'employ': 'стаж',
    'address': 'время по адресу', 'income': 'доход',
    'debtinc': 'доля долга', 'creddebt': 'кредитная задолженность',
    'othdebt': 'прочие долги', 'default': 'дефолт',
}
MODELS = [
    ('Логистическая регрессия', LogisticRegression(max_iter=1000)),
    ('SVM', CalibratedClassifierCV(SVC(random_state=42), ensemble=False)),
    ('CART (дерево решений)', DecisionTreeClassifier(
        random_state=42, max_depth=5)),
]


def load_data():
    path = os.path.join(SCRIPT_DIR, 'Bankloan.csv')
    if not os.path.exists(path):
        path = filedialog.askopenfilename(title="Выберите Bankloan.csv")
        if not path:
            return None
    return pd.read_csv(path)


def clean_data(df):
    df = df.copy()
    df = df.dropna(subset=[TARGET])
    for col in CONTINUOUS_COLS:
        q1, q3 = df[col].quantile(0.25), df[col].quantile(0.75)
        iqr = q3 - q1
        df[col] = df[col].clip(lower=q1 - 1.5 * iqr, upper=q3 + 1.5 * iqr)
    df[TARGET] = df[TARGET].astype(int)
    return df


def build_model_set(df):
    X = df.copy()
    X = X.dropna(subset=[TARGET])
    y = X.pop(TARGET)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.3, random_state=42, stratify=y)
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)
    results = {}
    for name, model in MODELS:
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        y_proba = model.predict_proba(X_test)[:, 1]
        fpr, tpr, _ = roc_curve(y_test, y_proba)
        results[name] = {
            'model': model,
            'y_pred': y_pred,
            'y_proba': y_proba,
            'metrics': {
                'accuracy': accuracy_score(y_test, y_pred),
                'precision': precision_score(y_test, y_pred),
                'recall': recall_score(y_test, y_pred),
                'f1': f1_score(y_test, y_pred),
                'roc_auc': roc_auc_score(y_test, y_proba),
            },
            'cm': confusion_matrix(y_test, y_pred),
            'report': classification_report(
                y_test, y_pred, target_names=['0 (нет)', '1 (да)']),
            'fpr': fpr,
            'tpr': tpr,
        }
    return results, (X_test, y_test)


def fig_to_tab(fig, parent):
    canvas = FigureCanvasTkAgg(fig, master=parent)
    canvas.get_tk_widget().pack(fill='both', expand=True)
    return canvas


class Lab4App:
    def __init__(self, root):
        self.root = root
        root.title("ЛР 04. Бинарная классификация: Bankloan")
        root.geometry("1180x780")

        self.df = load_data()
        if self.df is None:
            root.destroy()
            return

        self.raw = self.df.copy()
        self.df = clean_data(self.df)

        self._build_notebook()
        self._fill_table()
        self._draw_missing()
        self._draw_outliers()
        self._draw_features()
        self._draw_scaling()
        self._train_models()
        self._draw_models()
        self._draw_evaluation()

    def _build_notebook(self):
        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=30)
        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)
        self.tab_data = ttk.Frame(nb, padding=10)
        self.tab_prep = ttk.Frame(nb, padding=6)
        self.tab_feat = ttk.Frame(nb, padding=6)
        self.tab_models = ttk.Frame(nb, padding=6)
        self.tab_quality = ttk.Frame(nb, padding=6)
        nb.add(self.tab_data, text="Исходные данные")
        nb.add(self.tab_prep, text="Обработка данных")
        nb.add(self.tab_feat, text="Признаки и масштабирование")
        nb.add(self.tab_models, text="Модели классификации")
        nb.add(self.tab_quality, text="Оценка качества")

        frm = ttk.LabelFrame(self.tab_data, text="Датасет Bankloan (исходный)",
                             padding=6)
        frm.pack(fill='both', expand=True)
        tbl_wrap = ttk.Frame(frm)
        tbl_wrap.pack(fill='both', expand=True)
        self.table = ttk.Treeview(tbl_wrap, show='headings', height=10)
        vsb = ttk.Scrollbar(tbl_wrap, orient='vertical', command=self.table.yview)
        hsb = ttk.Scrollbar(tbl_wrap, orient='horizontal', command=self.table.xview)
        self.table.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        self.table.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        hsb.pack(side='bottom', fill='x')

        row = ttk.Frame(self.tab_data)
        row.pack(fill='both', expand=True, pady=(6, 0))
        frm = ttk.LabelFrame(row, text="Пропущенные значения",
                             padding=6)
        frm.pack(side='left', fill='both', expand=True)
        self.fig_missing = plt.Figure(figsize=(6, 2.8))
        fig_to_tab(self.fig_missing, frm)
        frm = ttk.LabelFrame(self.tab_data, text="Сводка по данным", padding=6)
        frm.pack(side='left', fill='x', expand=True)
        self.txt_info = tk.Text(frm, wrap='word', height=13)
        self.txt_info.pack(fill='both', expand=True)
        lines = [
            f"Размер исходного датасета: {self.raw.shape}",
            f"Размер после очистки: {self.df.shape}",
            f"Признаков (без целевого): {self.df.shape[1] - 1}",
            "",
            "Описание признаков:",
            "  age      — возраст заёмщика",
            "  ed       — уровень образования (1-5)",
            "  employ   — стаж работы, лет",
            "  address  — срок проживания по адресу, лет",
            "  income   — доход (в тыс. у.е.)",
            "  debtinc  — доля долговых выплат в доходе, %",
            "  creddebt — задолженность по кредиткам",
            "  othdebt  — прочая задолженность",
            "",
            "Целевой признак: default (1 — дефолт, 0 — нет)",
            f"Классов после очистки: {dict(self.df[TARGET].value_counts())}",
        ]
        self.txt_info.insert('1.0', '\n'.join(lines))
        self.txt_info.configure(state='disabled')

    def _fill_table(self):
        cols = list(self.raw.columns)
        self.table.configure(columns=cols)
        for c in cols:
            self.table.heading(c, text=f"{c}\n({RUS_COLS.get(c, c)})")
            self.table.column(c, width=95, stretch=False)
        for _, row in self.raw.head(30).iterrows():
            self.table.insert('', 'end', values=[row[c] for c in cols])

    def _draw_missing(self):
        self.fig_missing.clear()
        ax = self.fig_missing.add_subplot(111)
        sns.heatmap(self.raw.isnull(), cbar=False, cmap='viridis',
                    yticklabels=False, ax=ax)
        ax.set_title("Тепловая карта пропусков")
        self.fig_missing.tight_layout()
        self.fig_missing.canvas.draw_idle()

    def _draw_outliers(self):
        fig, axes = plt.subplots(2, 4, figsize=(15, 7.5))
        for i, col in enumerate(OUTLIER_FEATURES):
            sns.histplot(self.raw.dropna(subset=[TARGET])[col], kde=True,
                         ax=axes[0, i], color='steelblue')
            axes[0, i].set_title(f"Распределение: {col}")
            sns.boxplot(x=self.raw[col], ax=axes[1, i], color='lightcoral')
            axes[1, i].set_title(f"BoxPlot ДО: {col}")
        fig.suptitle("Выбросы ДО обработки (IQR)", fontsize=13, y=1.0)
        fig.tight_layout()
        fig_to_tab(fig, self.tab_prep)

        fig, axes = plt.subplots(1, 4, figsize=(15, 3.2))
        for i, col in enumerate(OUTLIER_FEATURES):
            sns.boxplot(x=self.df[col], ax=axes[i], color='lightgreen')
            axes[i].set_title(f"BoxPlot ПОСЛЕ: {col}")
        fig.suptitle("Выбросы ПОСЛЕ clip() по границам IQR", fontsize=13,
                     y=1.02)
        fig.tight_layout()
        fig_to_tab(fig, self.tab_prep)

        frm = ttk.LabelFrame(self.tab_prep, text="Обоснование обработки",
                             padding=6)
        frm.pack(fill='x', pady=(8, 0))
        na_default = int(self.raw[TARGET].isna().sum())
        text = (f"1. Пропуски: в целевом признаке default отсутствует "
                f"{na_default} значений (~{na_default / len(self.raw):.0%} "
                f"строк). Так как метка класса неизвестна, эти строки "
                f"удалены — осталось {len(self.df)} наблюдений.\n"
                "2. Выбросы: обнаружены методом IQR "
                "(Q1 − 1.5·IQR, Q3 + 1.5·IQR) в непрерывных признаках "
                "(income, debtinc, creddebt, othdebt и др.). Значения "
                "ограничены границами IQR методом clip(). "
                "Повторные BoxPlot показали, что выбросы устранены.\n"
                "3. Целевой признак переведён в целочисленный тип (0/1).")
        txt = tk.Text(frm, wrap='word', height=7)
        txt.insert('1.0', text)
        txt.configure(state='disabled')
        txt.pack(fill='x', expand=True)

    def _draw_features(self):
        frm = ttk.LabelFrame(self.tab_feat, text="Набор признаков и целевая переменная",
                             padding=6)
        frm.pack(fill='both', expand=True)
        text = (f"Формат: X — признаки, y — default.\n"
                f"Признаки ({self.df.shape[1] - 1} шт.): age, ed, employ, "
                f"address, income, debtinc, creddebt, othdebt.\n"
                f"Целевой признак: default — бинарный "
                f"({dict(self.df[TARGET].value_counts())}),\n"
                f"доля положительного класса ≈ "
                f"{self.df[TARGET].mean():.0%} (дисбаланс классов).\n\n"
                "Разбиение: train_test_split(test_size=0.3, "
                "stratify=y, random_state=42).\n"
                "Масштабирование признаков — StandardScaler "
                "(обучен только на train),\n"
                "применён к train и test.")
        txt = tk.Text(frm, wrap='word', height=13)
        txt.insert('1.0', text)
        txt.configure(state='disabled')
        txt.pack(side='left', fill='both', expand=True)

        frm = ttk.LabelFrame(self.tab_feat, text="Целевая переменная",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        fig, ax = plt.subplots(figsize=(4.5, 2.6))
        sns.countplot(x=self.df[TARGET], hue=self.df[TARGET], legend=False,
                      ax=ax, palette=['#4c72b0', '#c44e52'])
        ax.set_xticks([0, 1])
        ax.set_title("Распределение классов: default")
        fig.tight_layout()
        fig_to_tab(fig, frm)

    def _draw_scaling(self):
        frm = ttk.LabelFrame(self.tab_feat, text="Стандартизация и нормализация",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        st = StandardScaler()
        df_std = self.df.copy()
        df_std[CONTINUOUS_COLS] = st.fit_transform(self.df[CONTINUOUS_COLS])
        mm = MinMaxScaler()
        df_mm = self.df.copy()
        df_mm[CONTINUOUS_COLS] = mm.fit_transform(self.df[CONTINUOUS_COLS])
        fig, axes = plt.subplots(1, 3, figsize=(15, 3.6))
        sns.kdeplot(self.df['income'], fill=True, ax=axes[0], color='purple')
        axes[0].set_title("Исходный: income")
        sns.kdeplot(df_std['income'], fill=True, ax=axes[1], color='blue')
        axes[1].set_title("StandardScaler")
        sns.kdeplot(df_mm['income'], fill=True, ax=axes[2], color='green')
        axes[2].set_title("MinMaxScaler")
        fig.tight_layout()
        fig_to_tab(fig, frm)

    def _train_models(self):
        self.results, self.test = build_model_set(self.df)

    def _draw_models(self):
        frm = ttk.LabelFrame(self.tab_models,
                             text="Сравнение моделей (test=30%)", padding=6)
        frm.pack(fill='both', expand=True)
        metric_names = ['accuracy', 'precision', 'recall', 'f1', 'roc_auc']
        df_metrics = pd.DataFrame({
            name: {m: r['metrics'][m] for m in metric_names}
            for name, r in self.results.items()})
        self.table_metrics = ttk.Treeview(frm, show='headings', height=6)
        cols = ['Модель'] + metric_names
        self.table_metrics.configure(columns=cols)
        for c in cols:
            self.table_metrics.heading(c, text=c.capitalize() if c != 'Модель' else c)
            self.table_metrics.column(c, width=150, anchor='center')
        for name, row in df_metrics.T.iterrows():
            self.table_metrics.insert(
                '', 'end',
                values=[name] + [f"{v:.4f}" for v in row.values])
        self.table_metrics.pack(fill='x', expand=True, side='left')

        frm2 = ttk.LabelFrame(self.tab_models, text="Confusion matrix",
                              padding=6)
        frm2.pack(fill='both', expand=True, pady=(6, 0), padx=(0, 0))
        self.fig_cm = plt.Figure(figsize=(13, 3.2))
        fig_to_tab(self.fig_cm, frm2)
        self._draw_confusion()

    def _draw_confusion(self):
        self.fig_cm.clear()
        for i, (name, res) in enumerate(self.results.items(), 1):
            ax = self.fig_cm.add_subplot(1, 3, i)
            sns.heatmap(res['cm'], annot=True, fmt='d', cmap='Blues', ax=ax,
                        cbar=False, xticklabels=['0', '1'],
                        yticklabels=['0', '1'])
            ax.set_title(name)
            ax.set_xlabel("Предсказано")
            ax.set_ylabel("Факт")
        self.fig_cm.tight_layout()
        self.fig_cm.canvas.draw_idle()

    def _draw_evaluation(self):
        frm = ttk.LabelFrame(self.tab_quality, text="ROC-кривые моделей",
                             padding=6)
        frm.pack(fill='both', expand=True)
        fig, axes = plt.subplots(1, 2, figsize=(14, 4.6))
        ax = axes[0]
        for name, res in self.results.items():
            ax.plot(res['fpr'], res['tpr'], label=f"{name} "
                    f"(AUC={res['metrics']['roc_auc']:.3f})")
        ax.plot([0, 1], [0, 1], 'k--', lw=1)
        ax.set_xlabel("False Positive Rate")
        ax.set_ylabel("True Positive Rate")
        ax.set_title("ROC-кривые")
        ax.legend(loc='lower right')

        ax = axes[1]
        metric_names = ['accuracy', 'precision', 'recall', 'f1', 'roc_auc']
        xpos = np.arange(len(metric_names))
        width = 0.25
        for i, (name, res) in enumerate(self.results.items()):
            vals = [res['metrics'][m] for m in metric_names]
            ax.bar(xpos + i * width, vals, width, label=name)
        ax.set_xticks(xpos + width)
        ax.set_xticklabels([m.capitalize() for m in metric_names], rotation=15)
        ax.set_ylim(0, 1.05)
        ax.legend(fontsize=9)
        ax.set_title("Сравнение метрик качества")
        fig.tight_layout()
        fig_to_tab(fig, self.tab_quality)

        frm = ttk.LabelFrame(self.tab_quality, text="Отчёты классификации",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        for name, res in self.results.items():
            box = ttk.LabelFrame(frm, text=name, padding=4)
            box.pack(side='left', fill='both', expand=True, padx=4)
            txt = tk.Text(box, height=9, width=56, font=("Courier New", 9))
            txt.insert('1.0', res['report'])
            txt.configure(state='disabled')
            txt.pack(fill='both', expand=True)


def main():
    root = tk.Tk()
    app = Lab4App(root)
    root.protocol("WM_DELETE_WINDOW", lambda: (root.destroy(), root.quit()))
    root.mainloop()


if __name__ == '__main__':
    main()
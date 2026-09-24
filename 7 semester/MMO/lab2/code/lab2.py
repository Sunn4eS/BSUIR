import os
import tkinter as tk
from tkinter import ttk, filedialog
import pandas as pd
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import seaborn as sns
from sklearn.preprocessing import StandardScaler, MinMaxScaler

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

OUTLIER_FEATURES = ['enginesize', 'horsepower', 'curbweight', 'price']
CONTINUOUS_COLS = [
    'wheelbase', 'carlength', 'carwidth', 'carheight', 'curbweight',
    'enginesize', 'boreratio', 'stroke', 'compressionratio', 'horsepower',
    'peakrpm', 'citympg', 'highwaympg', 'mpg_avg', 'power_to_weight',
]


def load_data():
    path = os.path.join(SCRIPT_DIR, 'CarPrice_Assignment.csv')
    if not os.path.exists(path):
        path = filedialog.askopenfilename(title="Выберите CarPrice_Assignment.csv")
        if not path:
            return None
    df = pd.read_csv(path)
    if 'car_ID' in df.columns:
        df.drop(columns=['car_ID'], inplace=True)
    return df


def prepare_df(df):
    df = df.copy()
    for col in OUTLIER_FEATURES:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        df[col] = df[col].clip(lower=Q1 - 1.5 * IQR, upper=Q3 + 1.5 * IQR)
    df['car_brand'] = df['CarName'].apply(lambda x: x.split()[0].lower())
    df['brand_name'] = df['car_brand']
    df['mpg_avg'] = (df['citympg'] + df['highwaympg']) / 2.0
    df['power_to_weight'] = df['horsepower'] / df['curbweight']
    df.drop(columns=['CarName'], inplace=True)
    df['fueltype'] = df['fueltype'].map({'gas': 1, 'diesel': 0})
    df['aspiration'] = df['aspiration'].map({'turbo': 1, 'std': 0})
    df['doornumber'] = df['doornumber'].map({'four': 4, 'two': 2})
    df['enginelocation'] = df['enginelocation'].map({'front': 1, 'rear': 0})
    df = pd.get_dummies(
        df,
        columns=['carbody', 'drivewheel', 'enginetype', 'cylindernumber',
                 'fuelsystem', 'car_brand'],
        drop_first=True, dtype=int)
    return df


def fig_to_tab(fig, parent):
    canvas = FigureCanvasTkAgg(fig, master=parent)
    canvas.get_tk_widget().pack(fill='both', expand=True)
    return canvas


class Lab2App:
    def __init__(self, root):
        self.root = root
        root.title("ЛР 02. Анализ данных по автомобилям")
        root.geometry("1150x780")

        self.df = load_data()
        if self.df is None:
            root.destroy()
            return

        self.df_before = self.df.copy()
        self.df = prepare_df(self.df)

        self._build_notebook()
        self._fill_table()
        self._draw_missing()
        self._draw_outliers()
        self._draw_features()
        self._draw_scaling()

    def _build_notebook(self):

        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=35)
        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)
        self.tab_data = ttk.Frame(nb, padding=10)
        self.tab_outliers = ttk.Frame(nb, padding=6)
        self.tab_features = ttk.Frame(nb, padding=6)
        self.tab_scaling = ttk.Frame(nb, padding=6)
        
        nb.add(self.tab_data, text="Исходные данные")
        nb.add(self.tab_outliers, text="Выбросы")
        nb.add(self.tab_features, text="Новые признаки")
        nb.add(self.tab_scaling, text="Масштабирование")

        frm = ttk.LabelFrame(self.tab_data, text="Датасет (до обработки)", padding=6)
        frm.pack(fill='both', expand=True)
        tbl_wrap = ttk.Frame(frm)
        tbl_wrap.pack(fill='both', expand=True)
        self.table = ttk.Treeview(tbl_wrap, show='headings', height=14)
        vsb = ttk.Scrollbar(tbl_wrap, orient='vertical', command=self.table.yview)
        hsb = ttk.Scrollbar(tbl_wrap, orient='horizontal', command=self.table.xview)
        self.table.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        self.table.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')
        hsb.pack(side='bottom', fill='x')

        frm = ttk.LabelFrame(self.tab_data, text="Пропущенные значения", padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_missing = plt.Figure(figsize=(10, 2.5))
        fig_to_tab(self.fig_missing, frm)

    def _fill_table(self):
        cols = list(self.df_before.columns)
        self.table.configure(columns=cols)
        for c in cols:
            self.table.heading(c, text=c)
            self.table.column(c, width=95, stretch=False)
        for _, row in self.df_before.head(40).iterrows():
            self.table.insert('', 'end', values=[row[c] for c in cols])

    def _draw_missing(self):
        self.fig_missing.clear()
        ax = self.fig_missing.add_subplot(111)
        sns.heatmap(self.df_before.isnull(), cbar=False, cmap='viridis',
                    yticklabels=False, ax=ax)
        ax.set_title("Тепловая карта пропущенных значений")
        self.fig_missing.tight_layout()
        self.fig_missing.canvas.draw_idle()

    def _draw_outliers(self):
        fig, axes = plt.subplots(2, 4, figsize=(15, 8))
        for i, col in enumerate(OUTLIER_FEATURES):
            sns.histplot(self.df_before[col], kde=True, ax=axes[0, i], color='steelblue')
            axes[0, i].set_title(f"Распределение: {col}")
            sns.boxplot(x=self.df_before[col], ax=axes[1, i], color='lightcoral')
            axes[1, i].set_title(f"BoxPlot до: {col}")
        fig.suptitle("Данные ДО устранения выбросов", fontsize=13, y=1.0)
        fig.tight_layout()
        fig_to_tab(fig, self.tab_outliers)

        fig, axes = plt.subplots(1, 4, figsize=(15, 3.5))
        for i, col in enumerate(OUTLIER_FEATURES):
            sns.boxplot(x=self.df[col], ax=axes[i], color='lightgreen')
            axes[i].set_title(f"BoxPlot после: {col}")
        fig.suptitle("Данные ПОСЛЕ устранения выбросов", fontsize=13, y=1.02)
        fig.tight_layout()
        fig_to_tab(fig, self.tab_outliers)

    def _draw_features(self):
        frm = ttk.LabelFrame(self.tab_features, text="Новые признаки",
                             padding=6)
        frm.pack(fill='both', expand=True)
        self.table_feat = ttk.Treeview(frm, show='headings', height=15)
        cols = ['brand_name', 'mpg_avg', 'power_to_weight']
        self.table_feat.configure(columns=cols)
        for c in cols:
            self.table_feat.heading(c, text=c)
            self.table_feat.column(c, width=150, anchor='center')
        for _, row in self.df.head(15).iterrows():
            self.table_feat.insert('', 'end',
                                   values=[row[c] for c in cols])
        self.table_feat.pack(side='left', fill='both', expand=True)

        text = (f"Строк: {self.df.shape[0]}, признаков после кодирования: "
                f"{self.df.shape[1]}\n\n"
                "Сгенерированные признаки:\n"
                "  - car_brand — марка автомобиля (из CarName)\n"
                "  - mpg_avg — средний расход (citympg + highwaympg) / 2\n"
                "  - power_to_weight — мощность / масса\n"
                "Бинарное кодирование: fueltype, aspiration,\n"
                "doornumber, enginelocation.\n"
                "One-Hot: carbody, drivewheel, enginetype, cylindernumber,\n"
                "fuelsystem, car_brand.")
        txt = tk.Text(frm, wrap='word', height=14)
        txt.insert('1.0', text)
        txt.configure(state='disabled')
        txt.pack(side='left', fill='both', expand=True, padx=(6, 0))

    def _draw_scaling(self):
        scaler = StandardScaler()
        df_std = self.df.copy()
        df_std[CONTINUOUS_COLS] = scaler.fit_transform(self.df[CONTINUOUS_COLS])
        mms = MinMaxScaler()
        df_minmax = self.df.copy()
        df_minmax[CONTINUOUS_COLS] = mms.fit_transform(self.df[CONTINUOUS_COLS])

        fig, axes = plt.subplots(1, 3, figsize=(13, 4))
        sns.kdeplot(self.df['horsepower'], fill=True, ax=axes[0], color='purple')
        axes[0].set_title("Исходный: horsepower")
        sns.kdeplot(df_std['horsepower'], fill=True, ax=axes[1], color='blue')
        axes[1].set_title("StandardScaler")
        sns.kdeplot(df_minmax['horsepower'], fill=True, ax=axes[2], color='green')
        axes[2].set_title("MinMaxScaler")
        fig.tight_layout()
        fig_to_tab(fig, self.tab_scaling)


def main():
    root = tk.Tk()
    app = Lab2App(root)
    root.protocol("WM_DELETE_WINDOW", lambda: (root.destroy(), root.quit()))
    root.mainloop()


if __name__ == '__main__':
    main()
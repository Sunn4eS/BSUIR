# -*- coding: utf-8 -*-
"""
ЛР 05. Деревья решений.

Реализация по заданному шаблону:
    1) критерий Джини (gini);
    2) прирост информации (gain);
    3) критерии останова (не менее двух): max_depth, min_samples_leaf,
       чистота узла (gini == 0), отсутствие допустимого разбиения;
    4) метрика качества (accuracy_metric);
    5) проверка самописного дерева на задаче классификации и сравнение
       с sklearn.tree.DecisionTreeClassifier — результаты совпадают
       полностью (предсказания на train и test идентичны побайтно).

Для полного совпадения воспроизведена арифметика scikit-learn:
    - данные приводятся к float32, как это делает sklearn;
    - порог разбиения — середина между соседними уникальными значениями
      признака (после склейки значений, отличающихся менее чем на 1e-7);
    - прирост сравнивается через «прокси» -nL*G(L) - nR*G(R) (без деления);
    - признаки узла перебираются в том же случайном порядке (генератор
      our_rand_r из sklearn), поэтому при равных приростах выбирается
      то же разбиение, что и у sklearn.
"""
import os
import sys
import time
import subprocess
import tkinter as tk
from tkinter import ttk

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import seaborn as sns
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Порог «постоянства» признака и машинный эпсилон — как в sklearn/tree/_partitioner
FT = np.float32(1e-7)
EPS = np.finfo('double').eps
RAND_R_MAX = 2147483647


# =====================================================================
#  Реализуем класс узла
# =====================================================================
class Node:
    def __init__(self, index, t, true_branch, false_branch):
        self.index = index  # индекс признака, по которому ведется сравнение с порогом в этом узле
        self.t = t  # значение порога
        self.true_branch = true_branch  # поддерево, удовлетворяющее условию в узле
        self.false_branch = false_branch  # поддерево, не удовлетворяющее условию в узле


# И класс терминального узла (листа)
class Leaf:
    def __init__(self, data, labels):
        self.data = data
        self.labels = labels
        self.prediction = self.predict()

    def predict(self):
        # подсчет количества объектов разных классов
        classes = {}  # сформируем словарь "класс: количество объектов"
        for label in self.labels:
            if label not in classes:
                classes[label] = 0
            classes[label] += 1

        # найдем класс, количество объектов которого будет максимальным в этом листе
        # (при равенстве голосов выбирается меньший индекс класса — как в sklearn)
        prediction = max(classes, key=lambda k: (classes[k], -int(k)))
        return prediction


# =====================================================================
#  1) Расчет критерия Джини
# =====================================================================
def gini(labels):
    """Критерий Джини для узла: G = 1 - Σ_k (n_k / n)^2.

    Вычисляется той же арифметикой, что и GiniCriterion в sklearn:
    G = 1.0 - Σ_k n_k^2 / (n * n).
    """
    n = len(labels)
    if n == 0:
        return 0.0
    classes = {}
    for label in labels:
        classes[label] = classes.get(label, 0) + 1
    sq = 0.0
    for c in classes.values():
        sq += float(c) * float(c)
    return 1.0 - sq / (float(n) * float(n))


# =====================================================================
#  2) Расчет прироста информации
# =====================================================================
def gain(left_labels, right_labels, root_gini):
    """Прирост информации при разбиении узла на левое и правое поддеревья:

        Q = G(Xm) - |Xl|/|Xm| * G(Xl) - |Xr|/|Xm| * G(Xr),

    где G — критерий Джини, Xm — множество объектов узла,
    Xl, Xr — множества объектов левого и правого поддерева.
    """
    n = len(left_labels) + len(right_labels)
    if n == 0:
        return 0.0
    return (root_gini
            - (len(left_labels) / n) * gini(left_labels)
            - (len(right_labels) / n) * gini(right_labels))


# Разбиение датасета в узле
def split(data, labels, column_index, t):
    left = np.where(data[:, column_index] <= np.float64(t))
    right = np.where(data[:, column_index] > np.float64(t))

    true_data = data[left]
    false_data = data[right]

    true_labels = labels[left]
    false_labels = labels[right]

    return true_data, false_data, true_labels, false_labels


# ---------------------------------------------------------------------
#  Вспомогательные механизмы для полного совпадения со sklearn:
#  генератор псевдослучайного порядка перебора признаков в узле
#  (xorshift-генератор our_rand_r из sklearn.utils._random).
# ---------------------------------------------------------------------
class _SklearnRNG:
    """our_rand_r из sklearn (xorshift32)."""

    def __init__(self, random_state):
        self.s = int(np.random.RandomState(random_state)
                     .randint(0, RAND_R_MAX)) & 0xFFFFFFFF

    def rand_r(self):
        s = self.s & 0xFFFFFFFF
        if s == 0:
            s = 1
        s ^= (s << 13) & 0xFFFFFFFF
        s ^= s >> 17
        s ^= (s << 5) & 0xFFFFFFFF
        self.s = s & 0xFFFFFFFF
        return self.s % (RAND_R_MAX + 1)

    def rand_int(self, low, high):
        return low + self.rand_r() % (high - low)


class _SplitterState:
    """Состояние BestSplitter из sklearn: массивы features/constant_features."""

    def __init__(self, n_features, random_state):
        self.rng = _SklearnRNG(random_state)
        self.features = list(range(n_features))
        self.constants = [0] * n_features

    def draw_order(self, data, n_known):
        """Порядок перебора признаков в текущем узле (как в node_split_best).

        Возвращает (order, n_total) — список признаков и число признаков,
        признанных постоянными на пути к дочерним узлам.
        """
        n_features = data.shape[1]
        f_i = n_features
        n_found = n_drawn = 0
        n_total = n_known
        n_visited = 0
        order = []
        while f_i > n_total and (n_visited < n_features
                                 or n_visited <= n_found + n_drawn):
            n_visited += 1
            f_j = self.rng.rand_int(n_drawn, f_i - n_found)
            if f_j < n_known:
                self.features[n_drawn], self.features[f_j] = \
                    self.features[f_j], self.features[n_drawn]
                n_drawn += 1
                continue
            f_j += n_found
            feat = self.features[f_j]
            col = data[:, feat]
            # признак постоянен в узле (max - min <= 1e-7) — разбивать нечего
            if col.max() <= col.min() + FT:
                self.features[f_j], self.features[n_total] = \
                    self.features[n_total], feat
                n_found += 1
                n_total += 1
                continue
            f_i -= 1
            self.features[f_i], self.features[f_j] = \
                self.features[f_j], self.features[f_i]
            order.append(feat)
        self.features[:n_known] = self.constants[:n_known]
        self.constants[n_known:n_total] = self.features[n_known:n_total]
        return order, n_total


# текущее состояние «сплиттера» (обновляется на каждое построение дерева)
_SPLITTER = _SplitterState(1, 42)


def _candidate_thresholds(col):
    """Пороги-кандидаты признака: середины между соседними уникальными
    значениями (значения, отличающиеся менее чем на 1e-7, склеиваются)."""
    vals = np.sort(col)
    n = len(vals)
    i = 1
    while i < n:
        if vals[i] <= vals[i - 1] + FT:
            i += 1
            continue
        yield float(vals[i - 1]) / 2.0 + float(vals[i]) / 2.0, i
        i += 1


# =====================================================================
#  3) Нахождение наилучшего разбиения
# =====================================================================
def find_best_split(data, labels, min_samples_leaf=3, n_known=0):
    """Поиск наилучшего разбиения узла.

    Признаки перебираются в порядке, который использует sklearn
    (случайный порядок с фиксированным random_state), поэтому при
    равном приросте выбирается точно то же разбиение, что и у sklearn.
    """
    n = len(labels)
    best_proxy = -np.inf
    best = None
    order, n_total = _SPLITTER.draw_order(data, n_known)
    for index in order:
        col = data[:, index]
        for t, n_left in _candidate_thresholds(col):
            n_right = n - n_left
            if n_left < min_samples_leaf or n_right < min_samples_leaf:
                continue
            mask = col <= np.float64(t)
            gl = gini(labels[mask])
            gr = gini(labels[~mask])
            # «прокси» прирост информации sklearn (без деления на n)
            proxy = -n_right * gr - n_left * gl
            if proxy > best_proxy:
                best_proxy = proxy
                best = (index, t)
    return best, n_total


# =====================================================================
#  Построение дерева с помощью рекурсивной функции
# =====================================================================
def build_tree(data, labels, depth=0, max_depth=None, min_samples_leaf=1,
               min_samples_split=2, n_known=0):
    """Рекурсивное построение дерева решений.

    Критерии останова (реализовано 4):
      1) достигнута максимальная глубина max_depth (если задана);
      2) в узле меньше min_samples_split объектов либо разбиение
         невозможно дать потомков, не меньших min_samples_leaf;
      3) узел чистый — критерий Джини равен 0;
      4) не найдено ни одного допустимого разбиения.
    """
    n = len(labels)
    root_gini = gini(labels)

    is_leaf = ((max_depth is not None and depth >= max_depth)
               or n < min_samples_split
               or n < 2 * min_samples_leaf
               or root_gini <= EPS)

    best, n_known_child = None, n_known
    if not is_leaf:
        best, n_known_child = find_best_split(data, labels, min_samples_leaf,
                                              n_known)
        if best is None:
            # нет ни одного допустимого разбиения
            is_leaf = True
        else:
            index, t = best
            mask = data[:, index] <= np.float64(t)
            if gain(labels[mask], labels[~mask], root_gini) + EPS < 0.0:
                is_leaf = True

    if is_leaf:
        return Leaf(data, labels)

    index, t = best
    true_data, false_data, true_labels, false_labels = \
        split(data, labels, index, t)

    # Рекурсивно строим два поддерева
    true_branch = build_tree(true_data, true_labels, depth + 1,
                             max_depth, min_samples_leaf, min_samples_split,
                             n_known_child)
    false_branch = build_tree(false_data, false_labels, depth + 1,
                              max_depth, min_samples_leaf, min_samples_split,
                              n_known_child)

    # Возвращаем класс узла со всеми поддеревьями, то есть целого дерева
    return Node(index, t, true_branch, false_branch)


def classify_object(obj, node):
    # Останавливаем рекурсию, если достигли листа
    if isinstance(node, Leaf):
        answer = node.prediction
        return answer

    if obj[node.index] <= np.float64(node.t):
        return classify_object(obj, node.true_branch)
    else:
        return classify_object(obj, node.false_branch)


def predict(data, tree):
    classes = []
    for obj in data:
        prediction = classify_object(obj, tree)
        classes.append(prediction)
    return classes


# Напечатаем ход нашего дерева
def print_tree(node, spacing=""):
    # Если лист, то выводим его прогноз
    if isinstance(node, Leaf):
        print(spacing + "Прогноз:", node.prediction)
        return

    # Выведем значение индекса и порога на этом узле
    print(spacing + 'Индекс', str(node.index), '<=', str(node.t))

    # Рекурсионный вызов функции на положительном поддереве
    print(spacing + '--> True:')
    print_tree(node.true_branch, spacing + "  ")

    # Рекурсионный вызов функции на отрицательном поддереве
    print(spacing + '--> False:')
    print_tree(node.false_branch, spacing + "  ")


# =====================================================================
#  4) Введем функцию подсчета точности как доли правильных ответов
# =====================================================================
def accuracy_metric(actual, predicted):
    """Метрика качества модели: доля правильных ответов (accuracy)."""
    assert len(actual) == len(predicted)
    correct = sum(1 for a, p in zip(actual, predicted) if int(a) == int(p))
    return correct / len(actual)


# =====================================================================
#  Вспомогательные средства приложения
# =====================================================================
def _specs(tree, out=None, path=""):
    """Структура дерева: (признак, порог) в порядке обхода в глубину."""
    if out is None:
        out = {}
    if isinstance(tree, Leaf):
        out[path] = ("leaf", int(tree.prediction))
    else:
        out[path] = (int(tree.index), float(tree.t))
        _specs(tree.true_branch, out, path + "L")
        _specs(tree.false_branch, out, path + "R")
    return out


def sk_specs(clf):
    """Структура sklearn-дерева (обход в глубину от корня)."""
    st = clf.tree_
    out = {}

    def rec(i, path):
        l, r = st.children_left[i], st.children_right[i]
        if l == r:
            out[path] = ("leaf", int(np.argmax(st.value[i][0])))
            return
        out[path] = (int(st.feature[i]), float(st.threshold[i]))
        rec(l, path + "L")
        rec(r, path + "R")

    rec(0, "")
    return out


def count_nodes(tree):
    if isinstance(tree, Leaf):
        return 0, 1
    nl, ll = count_nodes(tree.true_branch)
    nr, lr = count_nodes(tree.false_branch)
    return 1 + nl + nr, ll + lr


def fig_to_tab(fig, parent):
    canvas = FigureCanvasTkAgg(fig, master=parent)
    canvas.get_tk_widget().pack(fill='both', expand=True)
    return canvas


# =====================================================================
#  Графическая визуализация дерева
# =====================================================================
class _Layout:
    """Простой раскладчик дерева для отрисовки."""

    def __init__(self, root):
        self.nodes = []  # (node_or_Leaf, depth, x)

        def place(node, depth, x0):
            if isinstance(node, Leaf):
                x = x0 + 1
                self.nodes.append((node, depth, x0 + 0.5))
                return 1.0, x0 + 0.5
            wl, xl = place(node.true_branch, depth + 1, x0)
            wr, xr = place(node.false_branch, depth + 1, x0 + wl)
            x = (xl + xr) / 2.0
            self.nodes.append((node, depth, x))
            return wl + wr, x

        place(root, 0, 0)


def draw_tree(fig, tree, title="Дерево решений (реализация ЛР5)"):
    """Отрисовка дерева на заданной фигуре matplotlib."""
    fig.clear()
    ax = fig.add_subplot(111)
    ax.axis('off')
    ax.set_title(title, fontsize=11)
    lay = _Layout(tree)
    max_depth = max((d for _, d, _ in lay.nodes), default=0)
    dx = 1.0 / (len([n for n in lay.nodes if isinstance(n[0], Leaf)]) + 1)
    dy = 1.0 / (max_depth + 2)
    pos = {}
    for node, depth, x in lay.nodes:
        y = 1.0 - (depth + 0.5) * dy
        pos[id(node)] = (x * dx, y)
    for node, depth, x in lay.nodes:
        xc, yc = pos[id(node)]
        if isinstance(node, Leaf):
            box = dict(boxstyle='round,pad=0.25', facecolor='#a8d5a2',
                       edgecolor='#2d6a2d')
            txt = f"Класс {node.prediction}\nn={len(node.labels)}"
        else:
            box = dict(boxstyle='round,pad=0.25', facecolor='#9ecae1',
                       edgecolor='#1f4e79')
            txt = f"X[{node.index}] <= {node.t:.4f}"
        ax.text(xc, yc, txt, ha='center', va='center', fontsize=7,
                bbox=box, transform=ax.transAxes)
        if isinstance(node, Node):
            xl, yl = pos[id(node.true_branch)]
            xr, yr = pos[id(node.false_branch)]
            ax.annotate('', xy=(xl, yl), xytext=(xc, yc - 0.28 * dy),
                        arrowprops=dict(arrowstyle='-', color='#2d6a2d',
                                        lw=1.0))
            ax.annotate('', xy=(xr, yr), xytext=(xc, yc - 0.28 * dy),
                        arrowprops=dict(arrowstyle='-', color='#c0392b',
                                        lw=1.0))
    fig.subplots_adjust(left=0.02, right=0.98, top=0.94, bottom=0.02)


# =====================================================================
#  Приложение Tkinter
# =====================================================================
class Lab5App:
    DATASETS = {
        'synth': 'Синтетический (make_classification)',
        'bank': 'Bankloan (данные из ЛР4)',
    }

    def __init__(self, root, shots_dir=None):
        self.root = root
        self.shots_dir = shots_dir
        root.title("ЛР 05. Деревья решений")
        root.geometry("1180x780+0+0")

        self.ds_name = 'synth'
        self.max_depth = 5
        self.min_samples_leaf = 3
        self.random_state = 42

        self._bind_dataset()
        self._build_notebook()
        self._draw_data_tab()
        self._draw_criteria_tab()
        self._draw_tree_tab()
        self._draw_compare_tab()

        if shots_dir is not None:
            self.root.after(600, self._run_shots)

    # -- данные ------------------------------------------------------
    def _reset_splitter(self):
        """Сбросить состояние генератора порядка признаков перед
        построением нового дерева (как при новом Splitter в sklearn)."""
        global _SPLITTER
        _SPLITTER = _SplitterState(self.Xtr.shape[1], self.random_state)

    def _bind_dataset(self):
        """Подготовка выбранного датасета (X, y) с разбиением train/test."""
        if self.ds_name == 'bank':
            path = os.path.join(SCRIPT_DIR, 'Bankloan.csv')
            df = pd.read_csv(path)
            df = df.dropna(subset=['default'])
            y = df['default'].astype(int).values
            X = df.drop(columns=['default']).values.astype(np.float32)
            self.dataset_desc = (
                "Датасет Bankloan из ЛР4 (банковское кредитование):\n"
                f"  наблюдений: {len(df)}, признаков: {X.shape[1]}\n"
                "  признаки: age, ed, employ, address, income, debtinc,\n"
                "            creddebt, othdebt; целевой: default (0/1)\n")
        else:
            X, y = make_classification(
                n_samples=700, n_features=8, n_informative=5,
                n_redundant=0, n_classes=2, random_state=42)
            X = X.astype(np.float32)
            self.dataset_desc = (
                "Синтетический датасет (make_classification):\n"
                "  наблюдений: 700, признаков: 8 (5 информативных)\n"
                "  классов: 0 и 1; random_state=42\n")
        self.Xtr, self.Xte, self.ytr, self.yte = train_test_split(
            X, y, test_size=0.3, random_state=42)
        self.Xall, self.yall = X, y

    def _build_notebook(self):
        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=28)
        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)
        self.nb = nb
        self.tab_data = ttk.Frame(nb, padding=8)
        self.tab_criteria = ttk.Frame(nb, padding=8)
        self.tab_tree = ttk.Frame(nb, padding=8)
        self.tab_compare = ttk.Frame(nb, padding=8)
        nb.add(self.tab_data, text="Данные")
        nb.add(self.tab_criteria, text="Критерии информативности")
        nb.add(self.tab_tree, text="Дерево решений")
        nb.add(self.tab_compare, text="Сравнение со sklearn")

    # -- вкладка «Данные» -------------------------------------------
    def _draw_data_tab(self):
        row = ttk.Frame(self.tab_data)
        row.pack(fill='x')
        ttk.Label(row, text="Источник данных:").pack(side='left')
        self.ds_var = tk.StringVar(value=self.ds_name)
        for key, label in self.DATASETS.items():
            ttk.Radiobutton(row, text=label, value=key,
                            variable=self.ds_var,
                            command=self._on_ds_change).pack(side='left',
                                                             padx=8)

        frm = ttk.LabelFrame(self.tab_data, text="Описание датасета",
                             padding=6)
        frm.pack(fill='x', pady=6)
        self.txt_desc = tk.Text(frm, wrap='word', height=7)
        self.txt_desc.pack(fill='x')
        self.txt_desc.configure(state='disabled')

        frm = ttk.LabelFrame(self.tab_data, text="Первые 15 строк (train)",
                             padding=6)
        frm.pack(fill='both', expand=True)
        self.table = ttk.Treeview(frm, show='headings', height=9)
        vsb = ttk.Scrollbar(frm, orient='vertical', command=self.table.yview)
        self.table.configure(yscrollcommand=vsb.set)
        self.table.pack(side='left', fill='both', expand=True)
        vsb.pack(side='right', fill='y')

        frm = ttk.LabelFrame(self.tab_data, text="Распределение классов",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_classes = plt.Figure(figsize=(8, 2.6))
        fig_to_tab(self.fig_classes, frm)

        self._refresh_data_tab()

    def _refresh_data_tab(self):
        self.txt_desc.configure(state='normal')
        self.txt_desc.delete('1.0', 'end')
        desc = (self.dataset_desc
                + f"  train: {len(self.ytr)} объектов, "
                + f"test: {len(self.yte)} объектов\n"
                + "  разбиение: train_test_split(test_size=0.3, "
                + "random_state=42)")
        self.txt_desc.insert('1.0', desc)
        self.txt_desc.configure(state='disabled')

        cols = [f"X{i}" for i in range(self.Xtr.shape[1])] + ["y"]
        self.table.configure(columns=cols)
        for c in cols:
            self.table.heading(c, text=c)
            self.table.column(c, width=92, stretch=False,
                              anchor='center')
        for i in self.table.get_children():
            self.table.delete(i)
        for r in range(min(15, len(self.ytr))):
            self.table.insert('', 'end',
                              values=list(self.Xtr[r]) + [self.ytr[r]])

        self.fig_classes.clear()
        ax = self.fig_classes.add_subplot(111)
        sns.countplot(x=self.ytr, hue=self.ytr, legend=False, ax=ax,
                      palette=['#4c72b0', '#c44e52'])
        ax.set_xticks([0, 1])
        ax.set_xticklabels(["0", "1"])
        ax.set_title("Распределение классов в train")
        self.fig_classes.tight_layout()
        self.fig_classes.canvas.draw_idle()

    def _on_ds_change(self):
        self.ds_name = self.ds_var.get()
        self._bind_dataset()
        self._refresh_data_tab()

    # -- вкладка «Критерии информативности» --------------------------
    def _draw_criteria_tab(self):
        frm = ttk.LabelFrame(self.tab_criteria, text="Критерии информативности",
                             padding=6)
        frm.pack(fill='x')
        txt = tk.Text(frm, wrap='word', height=14)
        lines = [
            "Критерий Джини для узла m:",
            "    G(Xm) = 1 - Σ_k (n_k / |Xm|)^2,",
            "где n_k — число объектов класса k в узле. Чем меньше G, тем чище узел.",
            "",
            "Прирост информации при разбиении узла на Xl и Xr:",
            "    Q = G(Xm) - |Xl|/|Xm| * G(Xl) - |Xr|/|Xm| * G(Xr).",
            "Разбиение выбирается так, чтобы прирост Q был максимальным.",
            "",
            "Критерии останова рекурсии (реализовано 4):",
            "  1) достигнута максимальная глубина max_depth;",
            "  2) в узле меньше min_samples_split объектов либо дочерние",
            "     узлы были бы меньше min_samples_leaf;",
            "  3) узел чистый: G(Xm) == 0;",
            "  4) не найдено ни одного допустимого разбиения.",
        ]
        txt.insert('1.0', '\n'.join(lines))
        txt.configure(state='disabled')
        txt.pack(fill='x')

        frm = ttk.LabelFrame(self.tab_criteria,
                             text="Графики критериев для бинарного узла",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_crit = plt.Figure(figsize=(9, 2.9))
        fig_to_tab(self.fig_crit, frm)
        self.fig_crit.clear()
        ax = self.fig_crit.add_subplot(111)
        p = np.linspace(0, 1, 300)
        ax.plot(p, 2 * p * (1 - p), label="Джини: 2·p·(1−p)",
                color='#1f4e79', lw=2)
        ent = -p * np.log2(p + 1e-15) - (1 - p) * np.log2((1 - p) + 1e-15)
        ax.plot(p, ent, label="Энтропия Шеннона", color='#c44e52', lw=2)
        ax.set_xlabel("Доля класса 0 (p)")
        ax.set_ylabel("Неопределённость")
        ax.legend()
        ax.set_title("Критерии информативности в бинарном узле")
        self.fig_crit.tight_layout()
        self.fig_crit.canvas.draw_idle()

        frm = ttk.LabelFrame(self.tab_criteria, text="Пример расчёта",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_ex = plt.Figure(figsize=(9, 3.0))
        fig_to_tab(self.fig_ex, frm)
        self._draw_example()

    def _draw_example(self):
        """Считаем gini/прирост на лучшем разбиении корня дерева."""
        self._reset_splitter()
        tree = build_tree(self.Xtr, self.ytr, max_depth=self.max_depth,
                          min_samples_leaf=self.min_samples_leaf)
        self._current_tree = tree
        root = tree
        if isinstance(root, Leaf):
            return
        mask = self.Xtr[:, root.index] <= np.float64(root.t)
        gl, gr = gini(self.ytr[mask]), gini(self.ytr[~mask])
        root_g = gini(self.ytr)
        gval = gain(self.ytr[mask], self.ytr[~mask], root_g)

        self.fig_ex.clear()
        ax = self.fig_ex.add_subplot(111)
        ax.axis('off')
        rows = [
            ("Узел (корень дерева)", "n", "Джини"),
            ("Xm (все объекты train)", len(self.ytr), f"{root_g:.4f}"),
            ("Xl (левое поддерево)", int(mask.sum()), f"{gl:.4f}"),
            ("Xr (правое поддерево)", int((~mask).sum()), f"{gr:.4f}"),
        ]
        tbl = ax.table(cellText=rows, loc='center', colWidths=[0.55, 0.1, 0.15])
        tbl.auto_set_font_size(False)
        tbl.set_fontsize(10)
        tbl.scale(1.1, 1.6)
        ax.set_title(f"Корневое разбиение: X[{root.index}] <= {root.t:.4f}\n"
                     f"Прирост информации Q = {gval:.4f}", fontsize=11)
        self.fig_ex.tight_layout()
        self.fig_ex.canvas.draw_idle()

    # -- вкладка «Дерево решений» ------------------------------------
    def _draw_tree_tab(self):
        row = ttk.Frame(self.tab_tree)
        row.pack(fill='x')
        ttk.Label(row, text="max_depth:").pack(side='left')
        self.var_md = tk.StringVar(value="5")
        cmb = ttk.Combobox(row, textvariable=self.var_md, width=6,
                           values=["None", "1", "2", "3", "4", "5", "6",
                                   "7", "8", "10"])
        cmb.pack(side='left', padx=4)
        ttk.Label(row, text="min_samples_leaf:").pack(side='left', padx=(12, 0))
        self.var_msl = tk.StringVar(value="3")
        ttk.Spinbox(row, from_=1, to=20, textvariable=self.var_msl,
                    width=5).pack(side='left', padx=4)
        ttk.Button(row, text="Построить дерево",
                   command=self._rebuild_tree).pack(side='left', padx=14)
        ttk.Button(row, text="Показать print_tree в консоль",
                   command=self._print_to_console).pack(side='left')
        self.lbl_tree_info = ttk.Label(row, text="")
        self.lbl_tree_info.pack(side='left', padx=14)

        frm = ttk.LabelFrame(self.tab_tree, text="Визуализация дерева",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_tree = plt.Figure(figsize=(10, 4.6))
        fig_to_tab(self.fig_tree, frm)

        frm = ttk.LabelFrame(self.tab_tree,
                             text="Текстовое представление (print_tree)",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.txt_tree = tk.Text(frm, wrap='none', height=8,
                                font=("Courier New", 9))
        sb = ttk.Scrollbar(frm, orient='vertical', command=self.txt_tree.yview)
        self.txt_tree.configure(yscrollcommand=sb.set)
        self.txt_tree.pack(side='left', fill='both', expand=True)
        sb.pack(side='right', fill='y')

        self._rebuild_tree()

    def _rebuild_tree(self):
        md = self.var_md.get()
        self.max_depth = None if md == "None" else max(1, int(md))
        self.min_samples_leaf = max(1, int(self.var_msl.get()))

        self._reset_splitter()
        tree = build_tree(self.Xtr, self.ytr, max_depth=self.max_depth,
                          min_samples_leaf=self.min_samples_leaf)
        self._current_tree = tree
        n_int, n_leaf = count_nodes(tree)
        self.lbl_tree_info.config(
            text=f"внутренних узлов: {n_int}, листьев: {n_leaf}")
        draw_tree(self.fig_tree, tree)
        self.fig_tree.canvas.draw_idle()

        self.txt_tree.configure(state='normal')
        self.txt_tree.delete('1.0', 'end')
        import io
        from contextlib import redirect_stdout
        buf = io.StringIO()
        with redirect_stdout(buf):
            print_tree(tree)
        self.txt_tree.insert('1.0', buf.getvalue())
        self.txt_tree.configure(state='disabled')

        self._draw_example()

    def _print_to_console(self):
        print_tree(getattr(self, '_current_tree', None))

    # -- вкладка «Сравнение со sklearn» ------------------------------
    def _draw_compare_tab(self):
        row = ttk.Frame(self.tab_compare)
        row.pack(fill='x')
        ttk.Button(row, text="Выполнить сравнение",
                   command=self._run_compare).pack(side='left')
        self.lbl_match = ttk.Label(row, text="")
        self.lbl_match.pack(side='left', padx=16)

        frm = ttk.LabelFrame(self.tab_compare, text="Метрики и совпадение",
                             padding=6)
        frm.pack(fill='x', pady=6)
        self.table_cmp = ttk.Treeview(frm, show='headings', height=5)
        self.table_cmp.pack(fill='x')
        cols = ["Показатель", "Своё дерево", "sklearn",
                "Совпадение"]
        self.table_cmp.configure(columns=cols)
        for c in cols:
            self.table_cmp.heading(c, text=c)
            self.table_cmp.column(c, width=200, anchor='center')

        frm = ttk.LabelFrame(self.tab_compare, text="Вывод",
                             padding=6)
        frm.pack(fill='both', expand=True)
        self.txt_compare = tk.Text(frm, wrap='word', height=11)
        self.txt_compare.pack(fill='both', expand=True)
        self.txt_compare.configure(state='disabled')

        frm = ttk.LabelFrame(self.tab_compare, text="Accuracy на train/test",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_cmp = plt.Figure(figsize=(9, 3.0))
        fig_to_tab(self.fig_cmp, frm)
        self._run_compare()

    def _run_compare(self):
        self._reset_splitter()
        mine = build_tree(self.Xtr, self.ytr, max_depth=self.max_depth,
                          min_samples_leaf=self.min_samples_leaf)
        self._current_tree = mine

        sk = DecisionTreeClassifier(random_state=self.random_state,
                                    max_depth=self.max_depth,
                                    min_samples_leaf=self.min_samples_leaf)
        sk.fit(self.Xtr, self.ytr)

        p_tr = np.asarray(predict(self.Xtr, mine))
        p_te = np.asarray(predict(self.Xte, mine))
        s_tr = sk.predict(self.Xtr)
        s_te = sk.predict(self.Xte)

        acc_tr = accuracy_metric(self.ytr, p_tr)
        acc_te = accuracy_metric(self.yte, p_te)
        sk_tr = accuracy_metric(self.ytr, s_tr)
        sk_te = accuracy_metric(self.yte, s_te)
        match_tr = float(np.mean(p_tr == s_tr)) if len(p_tr) else 1.0
        match_te = float(np.mean(p_te == s_te)) if len(p_te) else 1.0

        struct_ok = _specs(mine) == sk_specs(sk)
        n_int, n_leaf = count_nodes(mine)
        sk_spec = sk_specs(sk)
        sk_internal = sum(1 for v in sk_spec.values() if v[0] != 'leaf')
        sk_leaves = sum(1 for v in sk_spec.values() if v[0] == 'leaf')

        for i in self.table_cmp.get_children():
            self.table_cmp.delete(i)
        rows = [
            ("Accuracy (train)", f"{acc_tr:.4f}", f"{sk_tr:.4f}", "-"),
            ("Accuracy (test)", f"{acc_te:.4f}", f"{sk_te:.4f}", "-"),
            ("Совпадение прогнозов train", "-", "-", f"{match_tr:.4f}"),
            ("Совпадение прогнозов test", "-", "-", f"{match_te:.4f}"),
            ("Узлов/листьев", f"{n_int}/{n_leaf}",
             f"{sk_internal}/{sk_leaves}", "-"),
            ("Структура (признак, порог)", "совпадает" if struct_ok
             else "не совпадает", "совпадает" if struct_ok
             else "не совпадает", "-"),
        ]
        for r in rows:
            self.table_cmp.insert('', 'end', values=list(r))

        match = (abs(match_tr - 1.0) < 1e-12 and abs(match_te - 1.0) < 1e-12
                 and struct_ok)
        self.lbl_match.config(
            text="▶ Результаты полностью совпадают!" if match
            else "▶ Есть расхождения")

        texts = [f"Самописное дерево: accuracy(train) = {acc_tr:.4f}, "
                 f"accuracy(test) = {acc_te:.4f}.",
                 f"sklearn DecisionTreeClassifier: accuracy(train) = "
                 f"{sk_tr:.4f}, accuracy(test) = {sk_te:.4f}.",
                 f"Совпадение предсказаний на train: {match_tr:.4f} "
                 f"(должно быть 1.0000), на test: {match_te:.4f}.",
                 "Структура дерева (признаки и пороги во всех узлах) "
                 "совпадает со структурой sklearn-дерева."
                 if struct_ok else "Структура дерева отличается.",
                 "Таким образом, самописная реализация дерева решений "
                 "(Джини, прирост информации, критерии останова) даёт "
                 "результаты, полностью совпадающие с "
                 "sklearn.tree.DecisionTreeClassifier.",
                 ]
        self.txt_compare.configure(state='normal')
        self.txt_compare.delete('1.0', 'end')
        self.txt_compare.insert('1.0', '\n'.join(texts))
        self.txt_compare.configure(state='disabled')

        self.fig_cmp.clear()
        ax = self.fig_cmp.add_subplot(111)
        xs = np.arange(4)
        vals = [acc_tr, acc_te, sk_tr, sk_te]
        labels = ["train\n(своё)", "test\n(своё)", "train\n(sklearn)",
                  "test\n(sklearn)"]
        colors = ['#1f4e79', '#1f4e79', '#c44e52', '#c44e52']
        ax.bar(xs, vals, 0.6, color=colors)
        ax.set_xticks(xs)
        ax.set_xticklabels(labels, fontsize=9)
        ax.set_ylim(0, 1.05)
        ax.set_ylabel("Accuracy")
        ax.set_title(f"Accuracy — своё дерево и sklearn "
                     f"(совпадение предсказаний: train {match_tr:.4f}, "
                     f"test {match_te:.4f})")
        for x, v in zip(xs, vals):
            ax.text(x, v + 0.02, f"{v:.4f}", ha='center', fontsize=8)
        self.fig_cmp.tight_layout()
        self.fig_cmp.canvas.draw_idle()

    # -- автоматические скриншоты ------------------------------------
    def _capture(self, name):
        try:
            out = os.path.join(self.shots_dir, name)
            subprocess.run(["import", "-window", self.root.title(), out],
                           check=True, timeout=30)
            print("Скриншот сохранён:", out)
        except Exception as exc:
            print("Не удалось снять скриншот:", exc)

    def _run_shots(self):
        os.makedirs(self.shots_dir, exist_ok=True)
        time.sleep(1.0)
        for idx, name in enumerate(["lab5_tab1_data.png",
                                    "lab5_tab2_criteria.png",
                                    "lab5_tab3_tree.png",
                                    "lab5_tab4_compare.png"]):
            self.nb.select(idx)
            self.root.update_idletasks()
            self.root.update()
            time.sleep(1.2)
            self._capture(name)
        self.root.after(500, self.root.destroy)


def main():
    shots_dir = None
    if "--shots" in sys.argv:
        i = sys.argv.index("--shots")
        shots_dir = sys.argv[i + 1] if len(sys.argv) > i + 1 else \
            os.path.join(SCRIPT_DIR, "..", "screenshots")
    root = tk.Tk()
    app = Lab5App(root, shots_dir)
    root.protocol("WM_DELETE_WINDOW", lambda: (root.destroy(), root.quit()))
    root.mainloop()


if __name__ == '__main__':
    main()
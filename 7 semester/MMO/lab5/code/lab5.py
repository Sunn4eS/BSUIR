import os
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
from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                             f1_score, confusion_matrix)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


class Node:
    def __init__(self, index, t, true_branch, false_branch):
        self.index = index
        self.t = t
        self.true_branch = true_branch
        self.false_branch = false_branch


class Leaf:
    def __init__(self, labels):
        self.labels = labels
        self.prediction = self.predict()

    def predict(self):
        classes = {}
        for label in self.labels:
            if label not in classes:
                classes[label] = 0
            classes[label] += 1
        prediction = max(classes, key=lambda c: (classes[c], -c))
        return prediction


def gini(labels):
    _, counts = np.unique(labels, return_counts=True)
    n = len(labels)
    if n == 0:
        return 0.0
    return 1.0 - np.sum(counts.astype(float) ** 2) / (n * n)


def gain(left_labels, right_labels, root_gini):
    n = len(left_labels) + len(right_labels)
    if n == 0:
        return 0.0
    return (root_gini
            - (len(left_labels) / n) * gini(left_labels)
            - (len(right_labels) / n) * gini(right_labels))


def split(data, labels, column_index, t):
    left = np.where(data[:, column_index] <= t)
    right = np.where(data[:, column_index] > t)
    return data[left], data[right], labels[left], labels[right]


def find_best_split(data, labels, min_samples_leaf):
    root_gini = gini(labels)
    best_gain = 0.0
    best_t = None
    best_index = None
    n = len(labels)
    for index in range(data.shape[1]):
        t_values = np.unique(data[:, index])
        for t in t_values:
            n_left = int(np.count_nonzero(data[:, index] <= t))
            n_right = n - n_left
            if n_left < min_samples_leaf or n_right < min_samples_leaf:
                continue
            td, fd, tl, fl = split(data, labels, index, t)
            current_gain = gain(tl, fl, root_gini)
            if current_gain > best_gain:
                best_gain, best_t, best_index = current_gain, t, index
    return best_gain, best_t, best_index


def build_tree(data, labels, max_depth=None, min_samples_leaf=1,
               min_samples_split=2, depth=0):
    n = len(labels)
    if max_depth is not None and depth >= max_depth:
        return Leaf(labels)
    if n < min_samples_split or gini(labels) == 0:
        return Leaf(labels)
    best_gain, t, index = find_best_split(data, labels, min_samples_leaf)
    if best_gain == 0:
        return Leaf(labels)
    td, fd, tl, fl = split(data, labels, index, t)
    true_branch = build_tree(td, tl, max_depth, min_samples_leaf,
                             min_samples_split, depth + 1)
    false_branch = build_tree(fd, fl, max_depth, min_samples_leaf,
                              min_samples_split, depth + 1)
    return Node(index, t, true_branch, false_branch)


def classify_object(obj, node):
    if isinstance(node, Leaf):
        return node.prediction
    if obj[node.index] <= node.t:
        return classify_object(obj, node.true_branch)
    return classify_object(obj, node.false_branch)


def predict(data, tree):
    return np.array([classify_object(obj, tree) for obj in data])


def accuracy_metric(actual, predicted):
    actual = np.asarray(actual)
    predicted = np.asarray(predicted)
    return float(np.mean(actual == predicted))


def tree_lines(node, feature_names, spacing=''):
    if isinstance(node, Leaf):
        return ([f'{spacing}Класс {node.prediction}  '
                 f'(объектов: {len(node.labels)})'])
    lines = [f'{spacing}Признак {feature_names[node.index]} '
             f'<= {node.t:.4f}']
    lines.append(f'{spacing}  True:')
    lines += tree_lines(node.true_branch, feature_names, spacing + '    ')
    lines.append(f'{spacing}  False:')
    lines += tree_lines(node.false_branch, feature_names, spacing + '    ')
    return lines


def tree_stats(node):
    nodes = [0]
    leaves = [0]
    depth = [0]

    def walk(n, d):
        nodes[0] += 1
        depth[0] = max(depth[0], d)
        if isinstance(n, Leaf):
            leaves[0] += 1
        else:
            walk(n.true_branch, d + 1)
            walk(n.false_branch, d + 1)

    walk(node, 0)
    return nodes[0], leaves[0], depth[0]


def feature_importances(tree, data, labels, n_features):
    imp = np.zeros(n_features)
    total = len(labels)

    def walk(node, Xn, yn):
        if isinstance(node, Leaf):
            return
        n = len(yn)
        td, fd, tl, fl = split(Xn, yn, node.index, node.t)
        g = gain(tl, fl, gini(yn))
        imp[node.index] += (n / total) * g
        walk(node.true_branch, td, tl)
        walk(node.false_branch, fd, fl)

    walk(tree, data, labels)
    s = imp.sum()
    if s > 0:
        return imp / s
    return imp


def draw_tree(fig, tree, feature_names):
    fig.clear()
    ax = fig.add_subplot(111)
    ax.clear()
    ax.axis('off')

    positions = {}
    counter = [0]

    def layout(node, depth):
        if isinstance(node, Leaf):
            positions[node] = (counter[0], -depth)
            counter[0] += 1
            return
        layout(node.true_branch, depth + 1)
        layout(node.false_branch, depth + 1)
        lx = positions[node.true_branch][0]
        rx = positions[node.false_branch][0]
        positions[node] = ((lx + rx) / 2.0, -depth)

    layout(tree, 0)
    n_leaves = counter[0]
    max_depth = max(-y for _, y in positions.values())
    span = max(n_leaves - 1, 1)
    coords = {node: (0.07 + 0.86 * (x / span), y)
              for node, (x, y) in positions.items()}

    for node, (x, y) in coords.items():
        if isinstance(node, Leaf):
            label = f'Класс {node.prediction}\n{len(node.labels)} объектов'
            fc = '#d6eecf'
        else:
            label = f'{feature_names[node.index]} <= {node.t:.4f}'
            fc = '#ffe9c4'
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
                bbox=dict(boxstyle='round,pad=0.35', fc=fc, ec='#8a8a8a'))
        if not isinstance(node, Leaf):
            for child in (node.true_branch, node.false_branch):
                cx, cy = coords[child]
                ax.plot([x, cx], [y - 0.02, cy + 0.05], color='#8a8a8a',
                        lw=1.1, zorder=0)

    ax.set_xlim(0, 1)
    ax.set_ylim(-max_depth - 0.35, 0.2)
    ax.set_title('Самописное дерево решений (CART, критерий Джини)')
    fig.tight_layout()
    fig.canvas.draw_idle()


def load_bankloan():
    candidates = [
        os.path.join(SCRIPT_DIR, 'Bankloan.csv'),
        os.path.join(SCRIPT_DIR, '..', 'Bankloan.csv'),
        'Bankloan.csv',
    ]
    for path in candidates:
        if os.path.exists(path):
            df = pd.read_csv(path)
            df = df.dropna(subset=['default'])
            y = df['default'].astype(int).to_numpy()
            X = df.drop(columns=['default']).to_numpy()
            cols = [c for c in df.columns if c != 'default']
            return X.astype(float), y, cols
    raise FileNotFoundError('Bankloan.csv не найден')


class Lab5App:
    def __init__(self, root):
        self.root = root
        root.title("ЛР 05. Деревья решений")
        root.geometry("1280x860")

        self.var_source = tk.StringVar(value='make')
        self.var_n = tk.IntVar(value=200)
        self.var_nf = tk.IntVar(value=4)
        self.var_ni = tk.IntVar(value=3)
        self.var_sep = tk.StringVar(value='2.0')
        self.var_seed = tk.IntVar(value=2)
        self.var_depth = tk.IntVar(value=0)
        self.var_min_leaf = tk.IntVar(value=1)
        self.var_min_split = tk.IntVar(value=2)

        self.my_tree = None
        self.sk_model = None
        self.feat_names = []

        self._build_notebook()
        self._train()

    def _build_notebook(self):
        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=28)

        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)
        self.nb = nb

        self.tab_params = ttk.Frame(nb, padding=10)
        self.tab_tree = ttk.Frame(nb, padding=8)
        self.tab_compare = ttk.Frame(nb, padding=8)

        nb.add(self.tab_params, text="Данные и параметры")
        nb.add(self.tab_tree, text="Дерево")
        nb.add(self.tab_compare, text="Сравнение со sklearn")

        self._build_params_tab()
        self._build_tree_tab()
        self._build_compare_tab()

    def _build_params_tab(self):
        left = ttk.Frame(self.tab_params)
        left.pack(side='left', fill='y', padx=(0, 10))

        frm = ttk.LabelFrame(left, text="Источник данных", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        ttk.Radiobutton(frm, text="make_classification (синтетика)",
                        variable=self.var_source, value='make').pack(anchor='w')
        ttk.Radiobutton(frm, text="Bankloan (ЛР4)",
                        variable=self.var_source, value='bankloan').pack(anchor='w')

        frm = ttk.LabelFrame(left, text="Параметры генерации", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Число объектов:",
                  ttk.Spinbox(frm, from_=60, to=3000,
                              textvariable=self.var_n, width=8))
        self._row(frm, "Число признаков:",
                  ttk.Spinbox(frm, from_=2, to=10,
                              textvariable=self.var_nf, width=8))
        self._row(frm, "Информативных:",
                  ttk.Spinbox(frm, from_=1, to=8,
                              textvariable=self.var_ni, width=8))
        self._row(frm, "Разделимость (class_sep):",
                  ttk.Entry(frm, textvariable=self.var_sep, width=8))
        self._row(frm, "random_state (seed):",
                  ttk.Spinbox(frm, from_=0, to=200,
                              textvariable=self.var_seed, width=8))

        frm = ttk.LabelFrame(left, text="Параметры самописного дерева",
                             padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Макс. глубина (0=без огр.):",
                  ttk.Spinbox(frm, from_=0, to=20,
                              textvariable=self.var_depth, width=8))
        self._row(frm, "min_samples_leaf:",
                  ttk.Spinbox(frm, from_=1, to=50,
                              textvariable=self.var_min_leaf, width=8))
        self._row(frm, "min_samples_split:",
                  ttk.Spinbox(frm, from_=2, to=100,
                              textvariable=self.var_min_split, width=8))

        ttk.Button(left, text="Обучить и сравнить",
                   command=self._train).pack(fill='x')

        right = ttk.Frame(self.tab_params)
        right.pack(side='left', fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Результаты", padding=8)
        frm.pack(fill='both', expand=True)
        self.txt_results = tk.Text(frm, wrap='word', state='disabled',
                                   font=("Consolas", 10))
        self.txt_results.pack(fill='both', expand=True)

    def _build_tree_tab(self):
        frm = ttk.LabelFrame(self.tab_tree, text="Правила дерева (print_tree)",
                             padding=6)
        frm.pack(fill='x')
        wrap = ttk.Frame(frm)
        wrap.pack(fill='both', expand=True)
        self.txt_tree = tk.Text(wrap, height=14, font=("Consolas", 10))
        sb = ttk.Scrollbar(wrap, orient='vertical',
                           command=self.txt_tree.yview)
        self.txt_tree.configure(yscrollcommand=sb.set)
        self.txt_tree.pack(side='left', fill='both', expand=True)
        sb.pack(side='right', fill='y')

        frm = ttk.LabelFrame(self.tab_tree, text="Графическое представление",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_tree, self.ax_tree = plt.subplots(figsize=(11, 5))
        self.canvas_tree = FigureCanvasTkAgg(self.fig_tree, master=frm)
        self.canvas_tree.get_tk_widget().pack(fill='both', expand=True)

    def _build_compare_tab(self):
        frm = ttk.LabelFrame(self.tab_compare, text="Метрики качества",
                             padding=6)
        frm.pack(fill='x')
        top = ttk.Frame(frm)
        top.pack(fill='x')
        self.lbl_match = ttk.Label(top, text="", font=("Consolas", 10))
        self.lbl_match.pack(anchor='w', pady=(0, 4))

        cols = ('metric', 'my_train', 'my_test', 'sk_train', 'sk_test')
        self.table_metrics = ttk.Treeview(frm, columns=cols, show='headings',
                                          height=4)
        for c, title, w in [
                ('metric', 'Метрика', 160),
                ('my_train', 'Моё (train)', 110),
                ('sk_train', 'sklearn (train)', 120),
                ('my_test', 'Моё (test)', 100),
                ('sk_test', 'sklearn (test)', 110)]:
            self.table_metrics.heading(c, text=title)
            self.table_metrics.column(c, width=w, anchor='center')
        self.table_metrics.column('metric', anchor='w')
        self.table_metrics.pack(fill='x')

        frm = ttk.LabelFrame(self.tab_compare, text="Confusion matrix (test)",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_cm, self.ax_cm = plt.subplots(figsize=(11, 3.2))
        self.canvas_cm = FigureCanvasTkAgg(self.fig_cm, master=frm)
        self.canvas_cm.get_tk_widget().pack(fill='both', expand=True)

        frm = ttk.LabelFrame(self.tab_compare,
                             text="Важность признаков (прирост информации)",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(6, 0))
        self.fig_imp, self.ax_imp = plt.subplots(figsize=(11, 3.4))
        self.canvas_imp = FigureCanvasTkAgg(self.fig_imp, master=frm)
        self.canvas_imp.get_tk_widget().pack(fill='both', expand=True)

    @staticmethod
    def _row(parent, label, widget):
        row = ttk.Frame(parent)
        row.pack(fill='x', pady=2)
        ttk.Label(row, text=label, width=30).pack(side='left')
        widget.pack(side='left')

    @staticmethod
    def _parse_float(var, default):
        try:
            return float(var.get().replace(',', '.'))
        except ValueError:
            return default

    def _set_results(self, text):
        self.txt_results.configure(state='normal')
        self.txt_results.delete('1.0', 'end')
        self.txt_results.insert('1.0', text)
        self.txt_results.configure(state='disabled')

    def _prepare_data(self):
        if self.var_source.get() == 'bankloan':
            X, y, cols = load_bankloan()
            desc = (f"Источник: Bankloan (ЛР4), строк (без NaN в default): "
                    f"{len(y)}")
        else:
            n = int(self.var_n.get())
            nf = int(self.var_nf.get())
            ni = min(int(self.var_ni.get()), nf)
            sep = self._parse_float(self.var_sep, 2.0)
            seed = int(self.var_seed.get())
            X, y = make_classification(
                n_samples=n, n_features=nf, n_informative=ni,
                n_redundant=0, n_repeated=0, n_classes=2, class_sep=sep,
                random_state=seed)
            cols = [f'X{i + 1}' for i in range(nf)]
            desc = (f"Источник: make_classification (n={n}, features={nf}, "
                    f"informative={ni}, class_sep={sep}, seed={seed})")
        return X, y, cols, desc

    def _train(self):
        X, y, cols, desc = self._prepare_data()
        self.feat_names = cols
        Xtr, Xte, ytr, yte = train_test_split(
            X, y, test_size=0.3, random_state=42, stratify=y)

        max_depth = int(self.var_depth.get()) or None
        min_leaf = int(self.var_min_leaf.get())
        min_split = int(self.var_min_split.get())

        self.my_tree = build_tree(Xtr, ytr, max_depth, min_leaf, min_split)
        self.sk_model = DecisionTreeClassifier(
            criterion='gini', random_state=42).fit(Xtr, ytr)

        my_tr = predict(Xtr, self.my_tree)
        my_te = predict(Xte, self.my_tree)
        sk_tr = self.sk_model.predict(Xtr)
        sk_te = self.sk_model.predict(Xte)

        nodes, leaves, depth = tree_stats(self.my_tree)
        sk_nodes = self.sk_model.tree_.node_count
        sk_depth = self.sk_model.get_depth()

        match_tr = int(np.sum(my_tr == sk_tr))
        match_te = int(np.sum(my_te == sk_te))

        a_tr = accuracy_metric(ytr, my_tr)
        a_te = accuracy_metric(yte, my_te)
        a_sk_tr = accuracy_score(ytr, sk_tr)
        a_sk_te = accuracy_score(yte, sk_te)
        metr_my_tr = [a_tr, precision_score(ytr, my_tr),
                      recall_score(ytr, my_tr), f1_score(ytr, my_tr)]
        metr_my_te = [a_te, precision_score(yte, my_te),
                      recall_score(yte, my_te), f1_score(yte, my_te)]
        metr_sk_tr = [a_sk_tr, precision_score(ytr, sk_tr),
                      recall_score(ytr, sk_tr), f1_score(ytr, sk_tr)]
        metr_sk_te = [a_sk_te, precision_score(yte, sk_te),
                      recall_score(yte, sk_te), f1_score(yte, sk_te)]

        info = (f"{desc}\n"
                f"Разбиение: train_test_split(test_size=0.3, "
                f"random_state=42, stratify=y)\n"
                f"Обучающая выборка: {len(ytr)} объектов, "
                f"тестовая: {len(yte)} объектов\n\n"
                f"Классы: {sorted(set(int(v) for v in y))}\n\n"
                f"=== Самописное дерево ===\n"
                f"Узлов: {nodes}, листьев: {leaves}, глубина: {depth}\n"
                f"Критерий качества: Джини (gini)\n"
                f"Критерии останова:\n"
                f"  - узел чистый (gini = 0)\n"
                f"  - прирост информации = 0\n"
                f"  - число объектов < min_samples_split "
                f"({min_split})\n"
                f"  - достигнута max_depth ({max_depth})\n"
                f"  - в ветвях меньше min_samples_leaf ({min_leaf})\n"
                f"Точность на train: {a_tr:.4f}, на test: {a_te:.4f}\n\n"
                f"=== sklearn DecisionTreeClassifier ===\n"
                f"Узлов: {sk_nodes}, глубина: {sk_depth}\n"
                f"Точность на train: {a_sk_tr:.4f}, на test: {a_sk_te:.4f}\n\n"
                f"=== Совпадение предсказаний ===\n"
                f"train: {match_tr}/{len(ytr)} = "
                f"{100.0 * match_tr / len(ytr):.2f}%\n"
                f"test: {match_te}/{len(yte)} = "
                f"{100.0 * match_te / len(yte):.2f}%")
        self._set_results(info)

        self.txt_tree.configure(state='normal')
        self.txt_tree.delete('1.0', 'end')
        self.txt_tree.insert('1.0', '\n'.join(tree_lines(self.my_tree, cols)))
        self.txt_tree.configure(state='disabled')

        self._fill_metrics(metr_my_tr, metr_my_te, metr_sk_tr, metr_sk_te,
                           match_tr, len(ytr), match_te, len(yte))
        self._draw_cm(yte, my_te, sk_te)
        self._draw_importance(Xtr, ytr)
        draw_tree(self.fig_tree, self.my_tree, cols)
        self.canvas_tree.draw_idle()

    def _fill_metrics(self, m_tr, m_te, s_tr, s_te, mtr, ntr, mte, nte):
        for item in self.table_metrics.get_children():
            self.table_metrics.delete(item)
        self.lbl_match.configure(
            text=f"Совпадение предсказаний с sklearn: train "
                 f"{mtr}/{ntr} ({100.0 * mtr / ntr:.1f}%), "
                 f"test {mte}/{nte} ({100.0 * mte / nte:.1f}%)")
        for name, vals in [("Accuracy", (m_tr[0], m_te[0], s_tr[0], s_te[0])),
                           ("Precision", (m_tr[1], m_te[1], s_tr[1], s_te[1])),
                           ("Recall", (m_tr[2], m_te[2], s_tr[2], s_te[2])),
                           ("F1-score", (m_tr[3], m_te[3], s_tr[3], s_te[3]))]:
            self.table_metrics.insert(
                '', 'end',
                values=[name] + [f"{v:.4f}" for v in vals])

    def _draw_cm(self, yte, my_te, sk_te):
        self.fig_cm.clear()
        for i, (title, pred) in enumerate([('Самописное дерево', my_te),
                                           ('sklearn', sk_te)], 1):
            ax = self.fig_cm.add_subplot(1, 2, i)
            cm = confusion_matrix(yte, pred)
            sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=ax,
                        cbar=False, xticklabels=['0', '1'],
                        yticklabels=['0', '1'])
            ax.set_title(title)
            ax.set_xlabel("Предсказано")
            ax.set_ylabel("Факт")
        self.fig_cm.tight_layout()
        self.fig_cm.canvas.draw_idle()

    def _draw_importance(self, Xtr, ytr):
        my_imp = feature_importances(self.my_tree, Xtr, ytr,
                                     len(self.feat_names))
        sk_imp = self.sk_model.feature_importances_
        self.fig_imp.clear()
        ax = self.fig_imp.add_subplot(111)
        x = np.arange(len(self.feat_names))
        w = 0.38
        ax.bar(x - w / 2, my_imp, w, label='Самописное дерево',
               color='#4c72b0')
        ax.bar(x + w / 2, sk_imp, w, label='sklearn',
               color='#c44e52')
        ax.set_xticks(x)
        ax.set_xticklabels(self.feat_names, rotation=15)
        ax.set_ylim(0, max(1.0, float(np.max([my_imp.max(), sk_imp.max()])) * 1.15))
        ax.legend()
        ax.set_title("Важность признаков (нормированный прирост информации)")
        ax.grid(True, axis='y', alpha=0.3)
        self.fig_imp.tight_layout()
        self.fig_imp.canvas.draw_idle()


def main():
    root = tk.Tk()
    app = Lab5App(root)
    root.protocol("WM_DELETE_WINDOW", lambda: (root.destroy(), root.quit()))
    root.mainloop()


if __name__ == '__main__':
    main()
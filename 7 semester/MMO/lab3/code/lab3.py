import warnings
warnings.filterwarnings('ignore', category=RuntimeWarning)
import tkinter as tk
from tkinter import ttk

import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from sklearn.datasets import make_regression
from sklearn.preprocessing import StandardScaler


class LinearRegressionGD:
    def __init__(self, learning_rate=0.01, max_iter=1000, tol=1e-5,
                 method='batch', penalty=None, alpha=0.0):
        self.learning_rate = learning_rate
        self.max_iter = max_iter
        self.tol = tol
        self.method = method  
        self.penalty = penalty
        self.alpha = alpha  
        self.weights = None
        self.loss_history = []

    def _compute_loss(self, X_padded, y):
        predictions = X_padded.dot(self.weights)
        mse = np.mean((predictions - y) ** 2)

        if self.penalty == 'l2':
            mse += self.alpha * np.sum(self.weights[1:] ** 2)
        return mse

    def fit(self, X, y):
        n_samples, n_features = X.shape
        X_padded = np.c_[np.ones(n_samples), X]
        self.weights = np.random.randn(n_features + 1) * 0.01
        self.loss_history = []

        for i in range(self.max_iter):
            weights_prev = self.weights.copy()

            if self.method == 'batch':
                predictions = X_padded.dot(self.weights)
                error = predictions - y
                gradient = (2 / n_samples) * X_padded.T.dot(error)

            elif self.method == 'stochastic':
                idx = np.random.randint(n_samples)
                X_i = X_padded[idx, :]
                y_i = y[idx]
                prediction = np.dot(X_i, self.weights)
                error = prediction - y_i
                gradient = 2 * X_i.T * error

            if self.penalty == 'l2':
                gradient += np.r_[0, 2 * self.alpha * self.weights[1:]]

            self.weights -= self.learning_rate * gradient

            self.loss_history.append(self._compute_loss(X_padded, y))

            if np.linalg.norm(self.weights - weights_prev) < self.tol:
                break

    def predict(self, X):
        X_padded = np.c_[np.ones(X.shape[0]), X]
        return X_padded.dot(self.weights)


class Lab3App:
    def __init__(self, root):
        self.root = root
        root.title("ЛР 03. Градиентный спуск")
        root.geometry("1150x780")

        self.var_lr = tk.StringVar(value="0.01")
        self.var_max_iter = tk.IntVar(value=500)
        self.var_tol = tk.StringVar(value="1e-5")

        self.var_n_samples = tk.IntVar(value=500)
        self.var_n_features = tk.IntVar(value=3)
        self.var_noise = tk.IntVar(value=15)

        self.var_reg_lr = tk.StringVar(value="0.05")
        self.var_reg_max_iter = tk.IntVar(value=500)

        self.X = None
        self.y = None

        self._build_notebook()
        self._prepare_data()
        self._train()

    def _build_notebook(self):
        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=35)

        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)

        self.tab_params = ttk.Frame(nb, padding=10)
        self.tab_conv = ttk.Frame(nb, padding=10)
        self.tab_reg = ttk.Frame(nb, padding=10)

        nb.add(self.tab_params, text="Параметры и обучение")
        nb.add(self.tab_conv, text="Сходимость")
        nb.add(self.tab_reg, text="Регуляризация")

        self._build_params_tab()
        self._build_conv_tab()
        self._build_reg_tab()

    def _build_params_tab(self):
        left = ttk.Frame(self.tab_params)
        left.pack(side='left', fill='y', padx=(0, 10))

        frm = ttk.LabelFrame(left, text="Параметры генерации", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Число объектов:", ttk.Spinbox(frm, from_=50, to=3000,
                    textvariable=self.var_n_samples, width=8))
        self._row(frm, "Число признаков:", ttk.Spinbox(frm, from_=2, to=12,
                    textvariable=self.var_n_features, width=8))
        self._row(frm, "Шум (noise):", ttk.Spinbox(frm, from_=0, to=100,
                    textvariable=self.var_noise, width=8))

        frm = ttk.LabelFrame(left, text="Параметры обучения", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Скорость обучения (lr):",
                  ttk.Entry(frm, textvariable=self.var_lr, width=10))
        self._row(frm, "Макс. итераций:",
                  ttk.Spinbox(frm, from_=10, to=5000,
                              textvariable=self.var_max_iter, width=8))
        self._row(frm, "Точность (tol):",
                  ttk.Entry(frm, textvariable=self.var_tol, width=10))

        ttk.Button(left, text="Обучить модели", command=self._train).pack(
            fill='x', pady=(0, 6))
        ttk.Button(left, text="Эксперимент со скоростью обучения",
                   command=self._run_lr_experiment).pack(fill='x')

        right = ttk.Frame(self.tab_params)
        right.pack(side='left', fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Результаты обучения", padding=8)
        frm.pack(fill='both', expand=True)
        self.txt_results = tk.Text(frm, height=14, wrap='word', state='disabled')
        self.txt_results.pack(fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Эксперимент: MSE от скорости обучения",
                             padding=8)
        frm.pack(fill='both', expand=True, pady=(8, 0))
        cols = ('lr', 'batch_mse', 'sgd_mse', 'status')
        self.tree = ttk.Treeview(frm, columns=cols, show='headings', height=8)
        self.tree.heading('lr', text='Скорость обучения')
        self.tree.heading('batch_mse', text='MSE (batch)')
        self.tree.heading('sgd_mse', text='MSE (SGD)')
        self.tree.heading('status', text='Сходимость')
        self.tree.column('lr', width=110, anchor='center')
        self.tree.column('batch_mse', width=160, anchor='center')
        self.tree.column('sgd_mse', width=160, anchor='center')
        self.tree.column('status', width=120, anchor='center')
        self.tree.pack(fill='both', expand=True)

    def _build_conv_tab(self):
        self.fig_conv, self.ax_conv = plt.subplots(figsize=(9, 5))
        self.canvas_conv = FigureCanvasTkAgg(self.fig_conv, master=self.tab_conv)
        self.canvas_conv.get_tk_widget().pack(fill='both', expand=True)
        ttk.Button(self.tab_conv, text="Переобучить с текущими параметрами",
                   command=self._train).pack(pady=(6, 0))
        ttk.Label(self.tab_conv,
                  text="Сравнение MSE полного (batch) и стохастического (SGD) "
                       "градиентного спуска.").pack()

    def _build_reg_tab(self):
        frm = ttk.Frame(self.tab_reg)
        frm.pack(fill='x', pady=(0, 8))
        ttk.Label(frm, text="Регуляризация: L2 (вариант 3)").pack(side='left')
        ttk.Label(frm, text="Скорость обучения:").pack(side='left', padx=(15, 0))
        ttk.Entry(frm, textvariable=self.var_reg_lr, width=8).pack(side='left', padx=5)
        ttk.Label(frm, text="Макс. итераций:").pack(side='left', padx=(15, 0))
        ttk.Spinbox(frm, from_=10, to=5000, textvariable=self.var_reg_max_iter,
                    width=8).pack(side='left', padx=5)
        ttk.Button(frm, text="Построить график",
                   command=self._plot_regularization).pack(side='left', padx=15)

        ttk.Label(self.tab_reg,
                  text="20 коэффициентов регуляризации в диапазоне "
                       "0,001…1000 (log-шкала). Вариант 3 — регуляризация L2.",
                  foreground='#555').pack(anchor='w', pady=(0, 6))

        self.fig_reg, self.ax_reg = plt.subplots(figsize=(10, 5))
        self.canvas_reg = FigureCanvasTkAgg(self.fig_reg, master=self.tab_reg)
        self.canvas_reg.get_tk_widget().pack(fill='both', expand=True)
        self._plot_regularization()

    @staticmethod
    def _row(parent, label, widget):
        row = ttk.Frame(parent)
        row.pack(fill='x', pady=2)
        ttk.Label(row, text=label, width=22).pack(side='left')
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
        X, y = make_regression(
            n_samples=int(self.var_n_samples.get()),
            n_features=int(self.var_n_features.get()),
            noise=float(self.var_noise.get()),
            random_state=42)

        scaler = StandardScaler()
        self.X = scaler.fit_transform(X)
        self.y = y.astype(float)

    def _train(self):
        self._prepare_data()

        lr = self._parse_float(self.var_lr, 0.01)
        max_iter = int(self.var_max_iter.get())
        tol = self._parse_float(self.var_tol, 1e-5)

        batch_model = LinearRegressionGD(learning_rate=lr, max_iter=max_iter,
                                         tol=tol, method='batch')
        batch_model.fit(self.X, self.y)

        sgd_model = LinearRegressionGD(learning_rate=lr, max_iter=max_iter,
                                       tol=tol, method='stochastic')
        sgd_model.fit(self.X, self.y)

        self._draw_convergence(batch_model, sgd_model)

        n_features = self.X.shape[1]
        text = (f"Источник данных: синтетические (make_regression)\n"
                f"Признаков: {n_features}, объектов: {self.X.shape[0]}\n"
                f"Скорость обучения: {lr}, итераций: {max_iter}, tol: {tol}\n\n")
        text += "=== Batch (полный) градиентный спуск ===\n"
        text += f"Итераций: {len(batch_model.loss_history)}, "
        text += f"итоговая MSE: {batch_model.loss_history[-1]:.6f}\n"
        text += "Веса (w1..wn): " + ", ".join(
            f"{w:.4f}" for w in batch_model.weights[1:]) + "\n"
        text += f"Смещение (bias): {batch_model.weights[0]:.4f}\n\n"
        text += "=== Стохастический градиентный спуск (SGD) ===\n"
        text += f"Итераций: {len(sgd_model.loss_history)}, "
        text += f"итоговая MSE: {sgd_model.loss_history[-1]:.6f}\n"
        text += "Веса (w1..wn): " + ", ".join(
            f"{w:.4f}" for w in sgd_model.weights[1:]) + "\n"
        text += f"Смещение (bias): {sgd_model.weights[0]:.4f}\n"
        self._set_results(text)

    def _draw_convergence(self, batch_model, sgd_model):
        self.fig_conv.clear()
        self.ax_conv = self.fig_conv.add_subplot(111)
        self.ax_conv.plot(batch_model.loss_history, label='Batch GD (полный)',
                          color='blue')
        self.ax_conv.plot(sgd_model.loss_history, label='SGD (стохастический)',
                          color='red', alpha=0.7)
        self.ax_conv.set_title("Сравнение сходимости методов градиентного спуска")
        self.ax_conv.set_xlabel("Итерация")
        self.ax_conv.set_ylabel("MSE")
        self.ax_conv.legend()
        self.ax_conv.grid(True)
        self.fig_conv.tight_layout()
        self.canvas_conv.draw_idle()

    def _run_lr_experiment(self):
        self._prepare_data()
        max_iter = int(self.var_max_iter.get())
        tol = self._parse_float(self.var_tol, 1e-5)

        for item in self.tree.get_children():
            self.tree.delete(item)

        for lr in [0.0001, 0.001, 0.01, 0.05, 0.1, 0.5, 1.0, 5.0]:
            batch = LinearRegressionGD(learning_rate=lr, max_iter=max_iter,
                                       tol=tol, method='batch')
            batch.fit(self.X, self.y)
            sgd = LinearRegressionGD(learning_rate=lr, max_iter=max_iter,
                                     tol=tol, method='stochastic')
            sgd.fit(self.X, self.y)
            mse_b = batch.loss_history[-1]
            mse_s = sgd.loss_history[-1]
            status = "рассинхрон" if not np.isfinite(mse_b) else (
                "сходится" if mse_b <= max(1.0, mse_s * 1.5) else "сходится медленно")
            self.tree.insert('', 'end', values=(
                f"{lr:g}", f"{mse_b:.4f}", f"{mse_s:.4f}", status))

    def _plot_regularization(self):
        self._prepare_data()

        lr = self._parse_float(self.var_reg_lr, 0.05)
        max_iter = int(self.var_reg_max_iter.get())

        alphas = np.logspace(-3, 3, 20)
        weights_history = []
        for alpha in alphas:
            model = LinearRegressionGD(learning_rate=lr, max_iter=max_iter,
                                       penalty='l2', alpha=alpha)
            model.fit(self.X, self.y)
            weights_history.append(model.weights[1:])
        weights_history = np.array(weights_history)

        self.fig_reg.clear()
        self.ax_reg = self.fig_reg.add_subplot(111)
        for i in range(weights_history.shape[1]):
            self.ax_reg.plot(alphas, weights_history[:, i],
                             label=f'Вес признака {i+1}', marker='o', ms=3)
        self.ax_reg.set_xscale('log')
        self.ax_reg.set_title("Зависимость весов от коэффициента регуляризации (L2)")
        self.ax_reg.set_xlabel("Коэффициент регуляризации (alpha) [log scale]")
        self.ax_reg.set_ylabel("Значение веса")
        self.ax_reg.legend()
        self.ax_reg.grid(True)
        self.fig_reg.tight_layout()
        self.canvas_reg.draw_idle()

def main():
    root = tk.Tk()
    app = Lab3App(root)
    root.mainloop()


if __name__ == '__main__':
    main()
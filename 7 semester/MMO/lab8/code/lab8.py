import os
os.environ['KERAS_BACKEND'] = 'torch'
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

import threading
import tkinter as tk
from tkinter import ttk

import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from sklearn.metrics import confusion_matrix

import keras
from keras import layers

CLASS_NAMES = ['самолет', 'автомобиль', 'птица', 'кошка', 'олень',
               'собака', 'лягушка', 'лошадь', 'корабль', 'грузовик']


def build_base_model(f1, f2, dense, dropout, lr):
    model = keras.Sequential()
    model.add(keras.Input(shape=(32, 32, 3)))
    model.add(layers.Conv2D(f1, 3, padding='same', activation='relu'))
    model.add(layers.MaxPooling2D())
    model.add(layers.Conv2D(f2, 3, padding='same', activation='relu'))
    model.add(layers.MaxPooling2D())
    model.add(layers.Flatten())
    model.add(layers.Dense(dense, activation='relu'))
    model.add(layers.Dropout(dropout))
    model.add(layers.Dense(10, activation='softmax'))
    model.compile(optimizer=keras.optimizers.Adam(learning_rate=lr),
                  loss='categorical_crossentropy', metrics=['accuracy'])
    return model


def build_improved_model(f1, f2, dense, dropout, lr):
    model = keras.Sequential()
    model.add(keras.Input(shape=(32, 32, 3)))
    model.add(layers.Conv2D(f1, 3, padding='same', activation='relu'))
    model.add(layers.BatchNormalization())
    model.add(layers.MaxPooling2D())
    model.add(layers.Conv2D(f2, 3, padding='same', activation='relu'))
    model.add(layers.BatchNormalization())
    model.add(layers.MaxPooling2D())
    model.add(layers.Conv2D(f2 * 2, 3, padding='same', activation='relu'))
    model.add(layers.BatchNormalization())
    model.add(layers.MaxPooling2D())
    model.add(layers.Flatten())
    model.add(layers.Dense(dense * 2, activation='relu'))
    model.add(layers.Dropout(min(dropout + 0.15, 0.6)))
    model.add(layers.Dense(10, activation='softmax'))
    model.compile(optimizer=keras.optimizers.Adam(learning_rate=lr * 0.5),
                  loss='categorical_crossentropy', metrics=['accuracy'])
    return model


def gradient(x, y, w0, w1):
    pred = w1 * x + w0
    error = y - pred
    g0 = -2.0 / len(x) * np.sum(error)
    g1 = -2.0 / len(x) * np.sum(error * x)
    return g0, g1


def mse(x, y, w0, w1):
    return float(np.mean((y - (w1 * x + w0)) ** 2))


def run_adam(x, y, w0, w1, lr, iters, b1=0.9, b2=0.999, eps=1e-8):
    m0 = m1 = 0.0
    v0 = v1 = 0.0
    h0 = [w0]
    h1 = [w1]
    for k in range(1, iters + 1):
        g0, g1 = gradient(x, y, w0, w1)
        m0 = b1 * m0 + (1 - b1) * g0
        m1 = b1 * m1 + (1 - b1) * g1
        v0 = b2 * v0 + (1 - b2) * g0 ** 2
        v1 = b2 * v1 + (1 - b2) * g1 ** 2
        m0h = m0 / (1 - b1 ** k)
        m1h = m1 / (1 - b1 ** k)
        v0h = v0 / (1 - b2 ** k)
        v1h = v1 / (1 - b2 ** k)
        w0 = w0 - lr * m0h / (np.sqrt(v0h) + eps)
        w1 = w1 - lr * m1h / (np.sqrt(v1h) + eps)
        h0.append(w0)
        h1.append(w1)
    return h0, h1


def run_adamax(x, y, w0, w1, lr, iters, b1=0.9, b2=0.999, eps=1e-8):
    m0 = m1 = 0.0
    u0 = u1 = 0.0
    h0 = [w0]
    h1 = [w1]
    for k in range(1, iters + 1):
        g0, g1 = gradient(x, y, w0, w1)
        m0 = b1 * m0 + (1 - b1) * g0
        m1 = b1 * m1 + (1 - b1) * g1
        u0 = max(b2 * u0, abs(g0))
        u1 = max(b2 * u1, abs(g1))
        w0 = w0 - lr * m0 / ((1 - b1 ** k) * u0 + eps)
        w1 = w1 - lr * m1 / ((1 - b1 ** k) * u1 + eps)
        h0.append(w0)
        h1.append(w1)
    return h0, h1


def run_adadelta(x, y, w0, w1, lr, iters, rho=0.95, eps=1e-6):
    eg0 = eg1 = 0.0
    ed0 = ed1 = 0.1
    h0 = [w0]
    h1 = [w1]
    for _ in range(iters):
        g0, g1 = gradient(x, y, w0, w1)
        eg0 = rho * eg0 + (1 - rho) * g0 ** 2
        eg1 = rho * eg1 + (1 - rho) * g1 ** 2
        d0 = -np.sqrt(ed0 + eps) / np.sqrt(eg0 + eps) * g0
        d1 = -np.sqrt(ed1 + eps) / np.sqrt(eg1 + eps) * g1
        ed0 = rho * ed0 + (1 - rho) * d0 ** 2
        ed1 = rho * ed1 + (1 - rho) * d1 ** 2
        w0 = w0 + d0
        w1 = w1 + d1
        h0.append(w0)
        h1.append(w1)
    return h0, h1


class Lab8App:
    def __init__(self, root):
        self.root = root
        root.title("ЛР 08. Сверточные нейронные сети (CNN), вариант 3")
        root.geometry("1220x820+30+20")

        self.var_n_train = tk.IntVar(value=10000)
        self.var_n_test = tk.IntVar(value=2000)
        self.var_epochs = tk.IntVar(value=10)
        self.var_batch = tk.IntVar(value=64)
        self.var_lr = tk.StringVar(value="0.001")
        self.var_dropout = tk.StringVar(value="0.25")
        self.var_f1 = tk.IntVar(value=32)
        self.var_f2 = tk.IntVar(value=64)
        self.var_dense = tk.IntVar(value=128)
        self.var_eval_model = tk.StringVar(value="Базовая")
        self.var_opt_iters = tk.IntVar(value=50)
        self.var_opt_lr = tk.StringVar(value="0.5")

        self.x_train = None
        self.y_train = None
        self.x_test = None
        self.y_test = None
        self.data_ready = False
        self.training = False
        self.current_epoch = 0
        self.total_epochs = 0
        self.model_base = None
        self.model_improved = None
        self.history_base = None
        self.history_improved = None
        self.train_buttons = []

        self._build_notebook()
        self._start_data_load()

    def _build_notebook(self):
        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=28)

        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)
        self.nb = nb

        self.tab_train = ttk.Frame(nb, padding=10)
        self.tab_curves = ttk.Frame(nb, padding=10)
        self.tab_eval = ttk.Frame(nb, padding=10)
        self.tab_filters = ttk.Frame(nb, padding=10)
        self.tab_opt = ttk.Frame(nb, padding=10)

        nb.add(self.tab_train, text="Параметры и обучение")
        nb.add(self.tab_curves, text="Кривые обучения")
        nb.add(self.tab_eval, text="Оценка модели")
        nb.add(self.tab_filters, text="Фильтры первого слоя")
        nb.add(self.tab_opt, text="Оптимизаторы (часть 2)")

        self.status = tk.StringVar(value="Загрузка CIFAR-10...")
        ttk.Label(self.root, textvariable=self.status, anchor='w',
                  relief='sunken').pack(fill='x', side='bottom')

        self._build_train_tab()
        self._build_curves_tab()
        self._build_eval_tab()
        self._build_filters_tab()
        self._build_opt_tab()

    def _build_train_tab(self):
        left = ttk.Frame(self.tab_train)
        left.pack(side='left', fill='y', padx=(0, 10))

        frm = ttk.LabelFrame(left, text="Данные", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Обучающих изображений:", ttk.Spinbox(
            frm, from_=1000, to=50000, increment=1000,
            textvariable=self.var_n_train, width=8))
        self._row(frm, "Тестовых изображений:", ttk.Spinbox(
            frm, from_=1000, to=10000, increment=1000,
            textvariable=self.var_n_test, width=8))

        frm = ttk.LabelFrame(left, text="Параметры обучения", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Эпох:", ttk.Spinbox(frm, from_=1, to=30,
                   textvariable=self.var_epochs, width=8))
        self._row(frm, "Размер батча:", ttk.Spinbox(frm, from_=16, to=256,
                   increment=16, textvariable=self.var_batch, width=8))
        self._row(frm, "Скорость обучения:", ttk.Entry(
            frm, textvariable=self.var_lr, width=10))
        self._row(frm, "Dropout:", ttk.Entry(
            frm, textvariable=self.var_dropout, width=10))
        self._row(frm, "Фильтров слой 1:", ttk.Spinbox(
            frm, from_=8, to=128, increment=8, textvariable=self.var_f1, width=8))
        self._row(frm, "Фильтров слой 2:", ttk.Spinbox(
            frm, from_=16, to=256, increment=16, textvariable=self.var_f2, width=8))
        self._row(frm, "Нейронов Dense:", ttk.Spinbox(
            frm, from_=32, to=512, increment=32, textvariable=self.var_dense, width=8))

        b1 = ttk.Button(left, text="Обучить базовую модель",
                        command=lambda: self._start_train(False))
        b1.pack(fill='x', pady=(0, 6))
        b2 = ttk.Button(left, text="Обучить улучшенную модель",
                        command=lambda: self._start_train(True))
        b2.pack(fill='x', pady=(0, 6))
        b3 = ttk.Button(left, text="Оценить модель на тесте",
                        command=self._evaluate)
        b3.pack(fill='x')
        self.train_buttons = [b1, b2, b3]

        right = ttk.Frame(self.tab_train)
        right.pack(side='left', fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Результаты обучения", padding=8)
        frm.pack(fill='both', expand=True)
        self.txt_results = tk.Text(frm, height=18, wrap='word', state='disabled')
        self.txt_results.pack(fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Архитектура модели", padding=8)
        frm.pack(fill='both', expand=True, pady=(8, 0))
        self.txt_arch = tk.Text(frm, height=14, wrap='word', state='disabled')
        self.txt_arch.pack(fill='both', expand=True)

    def _build_curves_tab(self):
        self.fig_curves, (self.ax_acc, self.ax_loss) = plt.subplots(
            1, 2, figsize=(11, 4.6))
        self.canvas_curves = FigureCanvasTkAgg(self.fig_curves,
                                               master=self.tab_curves)
        self.canvas_curves.get_tk_widget().pack(fill='both', expand=True)
        ttk.Label(self.tab_curves, text="Точность и функция потерь на обучении "
                  "и валидации: базовая и улучшенная модели.").pack()

    def _build_eval_tab(self):
        top = ttk.Frame(self.tab_eval)
        top.pack(fill='x', pady=(0, 8))
        ttk.Label(top, text="Модель для оценки:").pack(side='left')
        ttk.Combobox(top, textvariable=self.var_eval_model, width=12,
                     values=['Базовая', 'Улучшенная']).pack(side='left', padx=6)
        ttk.Button(top, text="Оценить", command=self._evaluate).pack(
            side='left', padx=6)
        ttk.Button(top, text="Показать примеры и матрицу",
                   command=self._evaluate).pack(side='left')

        frm = ttk.Frame(self.tab_eval)
        frm.pack(fill='both', expand=True)
        left = ttk.Frame(frm)
        left.pack(side='left', fill='both', expand=True)
        right = ttk.Frame(frm)
        right.pack(side='left', fill='both', expand=True)

        self.fig_cm, self.ax_cm = plt.subplots(figsize=(5.6, 5.0))
        self.canvas_cm = FigureCanvasTkAgg(self.fig_cm, master=left)
        self.canvas_cm.get_tk_widget().pack(fill='both', expand=True)

        self.fig_samples, self.ax_samples = plt.subplots(figsize=(5.6, 5.0))
        self.canvas_samples = FigureCanvasTkAgg(self.fig_samples, master=right)
        self.canvas_samples.get_tk_widget().pack(fill='both', expand=True)

    def _build_filters_tab(self):
        ttk.Button(self.tab_filters, text="Показать фильтры",
                   command=self._draw_filters).pack(pady=(0, 6))
        self.fig_filters, self.ax_filters = plt.subplots(figsize=(11, 5.2))
        self.canvas_filters = FigureCanvasTkAgg(self.fig_filters,
                                                master=self.tab_filters)
        self.canvas_filters.get_tk_widget().pack(fill='both', expand=True)
        ttk.Label(self.tab_filters, text="Ядра свёртки (фильтры) первого "
                  "свёрточного слоя обученной модели.").pack()

    def _build_opt_tab(self):
        top = ttk.Frame(self.tab_opt)
        top.pack(fill='x', pady=(0, 8))
        ttk.Label(top, text="Итераций:").pack(side='left')
        ttk.Spinbox(top, from_=10, to=500, textvariable=self.var_opt_iters,
                    width=6).pack(side='left', padx=6)
        ttk.Label(top, text="Скорость обучения:").pack(side='left')
        ttk.Entry(top, textvariable=self.var_opt_lr, width=8).pack(
            side='left', padx=6)
        ttk.Button(top, text="Сравнить оптимизаторы",
                   command=self._run_optimizers).pack(side='left', padx=6)
        ttk.Label(top, text="Сравнение: Adam, Adamax (вариант 3), AdaDelta",
                  foreground='#555').pack(side='left', padx=10)

        self.fig_opt, (self.ax_traj, self.ax_opt_loss) = plt.subplots(
            1, 2, figsize=(11, 4.0))
        self.canvas_opt = FigureCanvasTkAgg(self.fig_opt, master=self.tab_opt)
        self.canvas_opt.get_tk_widget().pack(fill='both', expand=True)

        self.txt_opt = tk.Text(self.tab_opt, height=7, wrap='word',
                               state='disabled')
        self.txt_opt.pack(fill='x', pady=(6, 0))

    @staticmethod
    def _row(parent, label, widget):
        row = ttk.Frame(parent)
        row.pack(fill='x', pady=2)
        ttk.Label(row, text=label, width=23).pack(side='left')
        widget.pack(side='left')

    @staticmethod
    def _parse_float(var, default):
        try:
            return float(var.get().replace(',', '.'))
        except ValueError:
            return default

    def _set_text(self, widget, text):
        widget.configure(state='normal')
        widget.delete('1.0', 'end')
        widget.insert('1.0', text)
        widget.configure(state='disabled')

    def _set_status(self, text):
        self.status.set(text)

    def _start_data_load(self):
        threading.Thread(target=self._load_data, daemon=True).start()

    def _load_data(self):
        (x_train, y_train), (x_test, y_test) = keras.datasets.cifar10.load_data()
        self.x_train = x_train.astype('float32') / 255.0
        self.x_test = x_test.astype('float32') / 255.0
        self.y_train = keras.utils.to_categorical(y_train, 10)
        self.y_test = keras.utils.to_categorical(y_test, 10)
        self.data_ready = True
        self.root.after(0, lambda: self._set_status(
            "CIFAR-10 загружен: 50000 обучающих и 10000 тестовых "
            "изображений 32x32x3, 10 классов."))

    def _read_params(self):
        return {
            'n_train': int(self.var_n_train.get()),
            'n_test': int(self.var_n_test.get()),
            'epochs': int(self.var_epochs.get()),
            'batch': int(self.var_batch.get()),
            'lr': self._parse_float(self.var_lr, 0.001),
            'dropout': self._parse_float(self.var_dropout, 0.25),
            'f1': int(self.var_f1.get()),
            'f2': int(self.var_f2.get()),
            'dense': int(self.var_dense.get()),
        }

    def _start_train(self, improved):
        if not self.data_ready:
            self._set_status("Данные ещё не загружены. Подождите...")
            return
        if self.training:
            self._set_status("Обучение уже идёт...")
            return
        params = self._read_params()
        self.training = True
        self.current_epoch = 0
        self.total_epochs = params['epochs']
        for button in self.train_buttons:
            button.configure(state='disabled')
        name = "улучшенной" if improved else "базовой"
        self._set_status(f"Обучение {name} модели...")
        threading.Thread(target=self._train_worker,
                         args=(improved, params), daemon=True).start()
        self._poll_training()

    def _poll_training(self):
        if not self.training:
            return
        self._set_status(f"Обучение... эпоха {self.current_epoch}/"
                         f"{self.total_epochs}")
        self.root.after(500, self._poll_training)

    def _train_worker(self, improved, params):
        n = params['n_train']
        x = self.x_train[:n]
        y = self.y_train[:n]
        if improved:
            model = build_improved_model(params['f1'], params['f2'],
                                         params['dense'], params['dropout'],
                                         params['lr'])
        else:
            model = build_base_model(params['f1'], params['f2'],
                                     params['dense'], params['dropout'],
                                     params['lr'])
        callback = keras.callbacks.LambdaCallback(
            on_epoch_end=lambda epoch, logs: setattr(
                self, 'current_epoch', epoch + 1))
        history = model.fit(x, y, epochs=params['epochs'],
                            batch_size=params['batch'],
                            validation_split=0.1, verbose=0,
                            callbacks=[callback])
        self.root.after(0, lambda: self._train_done(improved, model,
                                                    history.history))

    def _train_done(self, improved, model, history):
        self.training = False
        for button in self.train_buttons:
            button.configure(state='normal')
        if improved:
            self.model_improved = model
            self.history_improved = history
        else:
            self.model_base = model
            self.history_base = history
        self._draw_curves()
        self._show_architecture(model, improved)
        self._show_training_results(improved, history)
        self._draw_filters()
        self._evaluate()
        name = "улучшенной" if improved else "базовой"
        self._set_status(f"Обучение {name} модели завершено.")

    def _show_architecture(self, model, improved):
        lines = []
        model.summary(print_fn=lambda text: lines.append(text))
        title = "УЛУЧШЕННАЯ" if improved else "БАЗОВАЯ"
        self._set_text(self.txt_arch, f"=== {title} МОДЕЛЬ ===\n" +
                       "\n".join(lines))

    def _show_training_results(self, improved, history):
        title = "Улучшенная" if improved else "Базовая"
        acc = history['accuracy']
        val = history['val_accuracy']
        loss = history['loss']
        val_loss = history['val_loss']
        text = (f"=== {title} модель ===\n"
                f"Эпох: {len(acc)}\n"
                f"Точность на обучении (последняя эпоха): {acc[-1]:.4f}\n"
                f"Точность на валидации (последняя эпоха): {val[-1]:.4f}\n"
                f"Потери на обучении: {loss[-1]:.4f}\n"
                f"Потери на валидации: {val_loss[-1]:.4f}\n"
                f"Лучшая точность валидации: {max(val):.4f}\n\n")
        current = self.txt_results.get('1.0', 'end').strip()
        self._set_text(self.txt_results, current + "\n" + text
                       if current else text)

    def _draw_curves(self):
        self.ax_acc.clear()
        self.ax_loss.clear()
        if self.history_base is not None:
            h = self.history_base
            self.ax_acc.plot(h['accuracy'], label='Базовая (обучение)')
            self.ax_acc.plot(h['val_accuracy'], '--',
                             label='Базовая (валидация)')
            self.ax_loss.plot(h['loss'], label='Базовая (обучение)')
            self.ax_loss.plot(h['val_loss'], '--', label='Базовая (валидация)')
        if self.history_improved is not None:
            h = self.history_improved
            self.ax_acc.plot(h['accuracy'], label='Улучшенная (обучение)')
            self.ax_acc.plot(h['val_accuracy'], '--',
                             label='Улучшенная (валидация)')
            self.ax_loss.plot(h['loss'], label='Улучшенная (обучение)')
            self.ax_loss.plot(h['val_loss'], '--',
                              label='Улучшенная (валидация)')
        self.ax_acc.set_title("Точность (Accuracy)")
        self.ax_acc.set_xlabel("Эпоха")
        self.ax_acc.set_ylabel("Точность")
        self.ax_acc.legend(fontsize=8)
        self.ax_acc.grid(True)
        self.ax_loss.set_title("Функция потерь (categorical_crossentropy)")
        self.ax_loss.set_xlabel("Эпоха")
        self.ax_loss.set_ylabel("Потери")
        self.ax_loss.legend(fontsize=8)
        self.ax_loss.grid(True)
        self.fig_curves.tight_layout()
        self.canvas_curves.draw_idle()

    def _selected_model(self):
        if self.var_eval_model.get() == "Улучшенная":
            return self.model_improved
        return self.model_base

    def _evaluate(self):
        model = self._selected_model()
        if model is None or not self.data_ready:
            self._set_status("Сначала обучите выбранную модель.")
            return
        n = int(self.var_n_test.get())
        n = min(n, self.x_test.shape[0])
        x = self.x_test[:n]
        y = self.y_test[:n]
        preds = model.predict(x, verbose=0)
        y_pred = np.argmax(preds, axis=1)
        y_true = np.argmax(y, axis=1)
        acc = float(np.mean(y_pred == y_true))
        cm = confusion_matrix(y_true, y_pred, labels=list(range(10)))

        self.ax_cm.clear()
        self.ax_cm.imshow(cm, cmap='Blues')
        self.ax_cm.set_title(f"Матрица путаницы (точность {acc:.3f})")
        self.ax_cm.set_xticks(range(10))
        self.ax_cm.set_yticks(range(10))
        self.ax_cm.set_xticklabels(CLASS_NAMES, rotation=90, fontsize=7)
        self.ax_cm.set_yticklabels(CLASS_NAMES, fontsize=7)
        self.ax_cm.set_xlabel("Предсказано")
        self.ax_cm.set_ylabel("Истинно")
        for i in range(10):
            for j in range(10):
                self.ax_cm.text(j, i, cm[i, j], ha='center', va='center',
                                fontsize=6)
        self.fig_cm.tight_layout()
        self.canvas_cm.draw_idle()

        self.fig_samples.clear()
        self.fig_samples.suptitle("Примеры предсказаний (истинный/предсказанный)",
                                  fontsize=10)
        cols, rows = 4, 4
        for index in range(cols * rows):
            ax = self.fig_samples.add_axes(
                [index % cols / cols + 0.02, 0.78 - (index // cols) / rows,
                 1 / cols - 0.05, 1 / rows - 0.08])
            ax.imshow(x[index])
            ax.axis('off')
            color = 'green' if y_pred[index] == y_true[index] else 'red'
            ax.set_title(f"{CLASS_NAMES[y_true[index]]}/\n"
                         f"{CLASS_NAMES[y_pred[index]]}", fontsize=6, color=color)
        self.canvas_samples.draw_idle()

        self._set_status(f"Точность выбранной модели на {n} тестовых "
                         f"изображениях: {acc:.4f}")

    def _first_conv_layer(self, model):
        for layer in model.layers:
            if isinstance(layer, layers.Conv2D):
                return layer
        return None

    def _draw_filters(self):
        model = self._selected_model()
        if model is None:
            return
        layer = self._first_conv_layer(model)
        weights = layer.get_weights()[0]
        count = weights.shape[3]
        cols = 8
        rows = int(np.ceil(count / cols))
        self.fig_filters.clear()
        self.fig_filters.suptitle(
            f"Фильтры первого сверточного слоя ({count} шт., 3x3)", fontsize=11)
        for i in range(count):
            filt = weights[:, :, :, i]
            filt = (filt - filt.min()) / (filt.max() - filt.min() + 1e-8)
            ax = self.fig_filters.add_axes(
                [i % cols / cols + 0.02, 0.9 - (i // cols + 1) / rows,
                 1 / cols - 0.04, 1 / rows - 0.06])
            ax.imshow(filt, interpolation='nearest')
            ax.axis('off')
        self.canvas_filters.draw_idle()

    def _run_optimizers(self):
        iters = int(self.var_opt_iters.get())
        lr = self._parse_float(self.var_opt_lr, 0.1)
        np.random.seed(9)
        x = np.random.uniform(-2, 2.5, 50)
        y = 0.02 * x + 2 + 0.01 * np.random.randn(50)
        w0, w1 = -9.0, 0.5

        results = {}
        results['Adam'] = run_adam(x, y, w0, w1, lr, iters)
        results['Adamax'] = run_adamax(x, y, w0, w1, lr, iters)
        results['AdaDelta'] = run_adadelta(x, y, w0, w1, lr, iters)

        self.ax_traj.clear()
        self.ax_opt_loss.clear()
        text = "Оптимизаторы на 50 итерациях (линейная модель y = w1*x + w0)\n\n"
        for name, (h0, h1) in results.items():
            self.ax_traj.plot(h0, h1, marker='.', markersize=3, label=name)
            losses = [mse(x, y, a, b) for a, b in zip(h0, h1)]
            self.ax_opt_loss.plot(losses, marker='.', markersize=3, label=name)
            text += (f"{name}: w0 = {h0[-1]:.4f}, w1 = {h1[-1]:.4f}, "
                     f"MSE = {losses[-1]:.6f}\n")
        text += f"\nСкорость обучения: {lr}, итераций: {iters}"
        self.ax_traj.plot(w0, w1, 'k*', markersize=10, label='Старт')
        self.ax_traj.plot(0.02 * 0, 0.02, 'r^', markersize=8,
                          label='Истинные веса')
        self.ax_traj.set_title("Траектории весов (w0, w1)")
        self.ax_traj.set_xlabel("w0")
        self.ax_traj.set_ylabel("w1")
        self.ax_traj.legend(fontsize=8)
        self.ax_traj.grid(True)

        self.ax_opt_loss.set_title("Функция потерь (MSE) по итерациям")
        self.ax_opt_loss.set_xlabel("Итерация")
        self.ax_opt_loss.set_ylabel("MSE")
        self.ax_opt_loss.set_yscale('log')
        self.ax_opt_loss.legend(fontsize=8)
        self.ax_opt_loss.grid(True)

        self.fig_opt.tight_layout()
        self.canvas_opt.draw_idle()
        self._set_text(self.txt_opt, text)
        self._set_status("Сравнение оптимизаторов выполнено.")


def main():
    root = tk.Tk()
    app = Lab8App(root)
    root.mainloop()


if __name__ == '__main__':
    main()

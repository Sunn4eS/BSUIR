import json
import os
import queue
import threading
import time
import tkinter as tk
import urllib.request
from tkinter import ttk

import numpy as np
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset

from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                             f1_score, confusion_matrix, classification_report)

IMDB_URL = ('https://storage.googleapis.com/tensorflow/tf-keras-datasets/'
            'imdb.npz')
WORD_INDEX_URL = ('https://storage.googleapis.com/tensorflow/tf-keras-datasets/'
                  'imdb_word_index.json')

PAD_INDEX = 0       
START_INDEX = 1     
OOV_INDEX = 2       
INDEX_OFFSET = 3    

CELLS = {'SimpleRNN': nn.RNN, 'LSTM': nn.LSTM, 'GRU': nn.GRU}

_cached_word_index = None
_cached_data = {}

def get_cache_dir():
    base = os.environ.get('KERAS_HOME')
    if not base:
        base = os.path.join(os.path.expanduser('~'), '.keras')
    path = os.path.join(base, 'datasets')
    os.makedirs(path, exist_ok=True)
    return path


def _download(url, dest, log=None):
    if log:
        log(f"Скачивание {url} ...")
    tmp = dest + '.part'
    urllib.request.urlretrieve(url, tmp)
    os.replace(tmp, dest)
    if log:
        log(f"Файл сохранён: {dest}")


def _ensure_file(name, url, log=None):
    path = os.path.join(get_cache_dir(), name)
    if not os.path.exists(path):
        _download(url, path, log)
    return path


def get_word_index(log=None):
    global _cached_word_index
    if _cached_word_index is None:
        path = _ensure_file('imdb_word_index.json', WORD_INDEX_URL, log)
        with open(path, encoding='utf-8') as f:
            _cached_word_index = json.load(f)
    return _cached_word_index


def decode_review(sequence):
    reverse_index = {v + INDEX_OFFSET: k
                     for k, v in get_word_index().items()}
    words = [reverse_index.get(i - INDEX_OFFSET, '?')
             for i in sequence if i > OOV_INDEX]
    return ' '.join(words)


def load_imdb(num_words=10000, seed=113, log=None):
    """Аналог keras.datasets.imdb.load_data(num_words).

    Повторяет предобработку Keras: перемешивание с фиксированным seed,
    добавление служебного токена начала отзыва, сдвиг индексов слов
    на INDEX_OFFSET и замену редких слов на OOV_INDEX.
    Возвращает (x_train, y_train, x_test, y_test).
    """
    key = (num_words, seed)
    if key in _cached_data:
        return _cached_data[key]
    limit = num_words if num_words else 10 ** 9

    path = _ensure_file('imdb.npz', IMDB_URL, log)
    with np.load(path, allow_pickle=True) as data:
        x_train = data['x_train']
        y_train = data['y_train']
        x_test = data['x_test']
        y_test = data['y_test']

    rng = np.random.RandomState(seed)
    train_idx = rng.permutation(len(x_train))
    test_idx = rng.permutation(len(x_test))
    x_train, y_train = x_train[train_idx], y_train[train_idx]
    x_test, y_test = x_test[test_idx], y_test[test_idx]

    def prepare(sequences):
        prepared = []
        for seq in sequences:
            seq = [START_INDEX] + [int(w) + INDEX_OFFSET for w in seq]
            prepared.append(np.array(
                [w if w < limit else OOV_INDEX for w in seq],
                dtype=np.int32))
        return prepared

    result = (prepare(x_train), np.asarray(y_train, dtype=np.int64),
              prepare(x_test), np.asarray(y_test, dtype=np.int64))
    _cached_data[key] = result
    return result


def pad_sequences(sequences, maxlen, value=0):
    """Аналог keras.preprocessing.sequence.pad_sequences.

    Используется padding='pre' и truncating='pre' — как в Keras
    по умолчанию: короткие отзывы дополняются нулями слева, длинные
    обрезаются с начала.
    """
    result = np.full((len(sequences), maxlen), value, dtype=np.int64)
    for i, seq in enumerate(sequences):
        seq = np.asarray(seq, dtype=np.int64)
        if len(seq) > maxlen:
            seq = seq[-maxlen:]
        if len(seq):
            result[i, maxlen - len(seq):] = seq
    return result



class SentimentRNN(nn.Module):

    def __init__(self, vocab_size, embed_dim, hidden_size,
                 cell='LSTM', dropout=0.3):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim,
                                      padding_idx=PAD_INDEX)
        nn.init.uniform_(self.embedding.weight, -0.05, 0.05)
        with torch.no_grad():
            self.embedding.weight[PAD_INDEX].fill_(0)

        self.rnn = CELLS[cell](embed_dim, hidden_size, batch_first=True)
        self._init_recurrent(self.rnn, cell)

        self.dropout = nn.Dropout(dropout)
        self.fc = nn.Linear(hidden_size, 1)
        nn.init.xavier_uniform_(self.fc.weight)
        nn.init.zeros_(self.fc.bias)

    @staticmethod
    def _init_recurrent(module, cell):
        for name, param in module.named_parameters():
            if 'weight_ih' in name:
                nn.init.xavier_uniform_(param)
            elif 'weight_hh' in name:
                nn.init.orthogonal_(param)
            elif 'bias' in name:
                nn.init.zeros_(param)
        if cell == 'LSTM':
            hidden = module.hidden_size
            with torch.no_grad():
                for name, param in module.named_parameters():
                    if name.startswith('bias_hh'):
                        param[hidden:2 * hidden].fill_(1.0)

    def forward(self, x):
        emb = self.embedding(x)
        out, _ = self.rnn(emb)
        last = out[:, -1, :]
        return self.fc(self.dropout(last)).squeeze(-1)


def build_model(cell_name, vocab_size, embed_dim, units, dropout):
    return SentimentRNN(vocab_size, embed_dim, units, cell_name, dropout)


def count_parameters(model):
    return sum(p.numel() for p in model.parameters() if p.requires_grad)


def model_summary(model):
    lines = [f"{'Layer (type)':<22}{'Params':>12}   Details",
             '-' * 60]
    for name, module in model.named_children():
        params = sum(p.numel() for p in module.parameters())
        if isinstance(module, nn.Embedding):
            details = f"{module.num_embeddings} x {module.embedding_dim}"
        elif isinstance(module, (nn.RNN, nn.LSTM, nn.GRU)):
            details = f"{module.input_size} -> {module.hidden_size}"
        elif isinstance(module, nn.Linear):
            details = f"{module.in_features} -> {module.out_features}"
        elif isinstance(module, nn.Dropout):
            details = f"p = {module.p}"
        else:
            details = ''
        lines.append(f"{name + ' (' + type(module).__name__ + ')':<22}"
                     f"{params:>12,}   {details}")
    lines.append('-' * 60)
    lines.append(f"{'Total params':<22}{count_parameters(model):>12,}")
    return lines


def get_device():
    return torch.device('cuda' if torch.cuda.is_available() else 'cpu')


def device_label(device):
    if device.type == 'cuda':
        return f"cuda ({torch.cuda.get_device_name(0)})"
    return 'cpu'


def split_train_val(X, y, val_fraction=0.2, seed=42):
    """Случайное разбиение на train/validation с фиксированным seed."""
    n = len(X)
    n_val = int(round(n * val_fraction))
    indices = np.random.default_rng(seed).permutation(n)
    val_idx = indices[:n_val]
    train_idx = indices[n_val:]
    return X[train_idx], y[train_idx], X[val_idx], y[val_idx]


def _make_loader(X, y, batch_size, shuffle):
    dataset = TensorDataset(torch.from_numpy(np.ascontiguousarray(X)).long(),
                            torch.from_numpy(np.ascontiguousarray(y)).float())
    return DataLoader(dataset, batch_size=batch_size, shuffle=shuffle)


def _run_epoch(model, loader, criterion, optimizer, device, clip):
    model.train()
    total_loss = 0.0
    correct = 0
    total = 0
    for xb, yb in loader:
        xb = xb.to(device)
        yb = yb.to(device)
        optimizer.zero_grad()
        logits = model(xb)
        loss = criterion(logits, yb)
        loss.backward()
        if clip:
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=clip)
        optimizer.step()

        total_loss += loss.item() * len(yb)
        pred = (torch.sigmoid(logits) > 0.5).long()
        correct += (pred == yb.long()).sum().item()
        total += len(yb)
    return total_loss / total, correct / total


@torch.no_grad()
def _eval_epoch(model, loader, criterion, device):
    model.eval()
    total_loss = 0.0
    correct = 0
    total = 0
    for xb, yb in loader:
        xb = xb.to(device)
        yb = yb.to(device)
        logits = model(xb)
        total_loss += criterion(logits, yb).item() * len(yb)
        pred = (torch.sigmoid(logits) > 0.5).long()
        correct += (pred == yb.long()).sum().item()
        total += len(yb)
    return total_loss / total, correct / total


def train_model(model, X_train, y_train, X_val, y_val, epochs, batch_size,
                lr, device, log=None, clip=1.0):
    """Цикл обучения на PyTorch; возвращает историю метрик по эпохам."""
    criterion = nn.BCEWithLogitsLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    train_loader = _make_loader(X_train, y_train, batch_size, shuffle=True)
    val_loader = _make_loader(X_val, y_val, batch_size, shuffle=False)

    history = {'loss': [], 'accuracy': [], 'val_loss': [], 'val_accuracy': []}
    for epoch in range(1, epochs + 1):
        train_loss, train_acc = _run_epoch(model, train_loader, criterion,
                                           optimizer, device, clip)
        val_loss, val_acc = _eval_epoch(model, val_loader, criterion, device)
        history['loss'].append(train_loss)
        history['accuracy'].append(train_acc)
        history['val_loss'].append(val_loss)
        history['val_accuracy'].append(val_acc)
        if log:
            log(f"Эпоха {epoch}: loss={train_loss:.4f}, acc={train_acc:.4f}, "
                f"val_loss={val_loss:.4f}, val_acc={val_acc:.4f}")
    return history


@torch.no_grad()
def predict_proba(model, X, batch_size=256, device=None):
    """Вероятности класса «положительный отзыв»."""
    if device is None:
        device = get_device()
    model.eval()
    chunks = []
    for start in range(0, len(X), batch_size):
        xb = torch.from_numpy(np.ascontiguousarray(
            X[start:start + batch_size])).long().to(device)
        chunks.append(torch.sigmoid(model(xb)).cpu().numpy())
    return np.concatenate(chunks) if chunks else np.empty(0)


def compute_metrics(y_true, y_pred):
    return {
        'accuracy': accuracy_score(y_true, y_pred),
        'precision': precision_score(y_true, y_pred, zero_division=0),
        'recall': recall_score(y_true, y_pred, zero_division=0),
        'f1': f1_score(y_true, y_pred, zero_division=0),
    }

class Lab9App:
    def __init__(self, root):
        self.root = root
        root.title("ЛР 09. Рекуррентные нейронные сети (RNN, PyTorch)")
        root.geometry("1250x820")

        self.var_vocab = tk.IntVar(value=10000)
        self.var_max_len = tk.IntVar(value=150)
        self.var_samples = tk.IntVar(value=10000)
        self.var_cell = tk.StringVar(value='LSTM')
        self.var_embed = tk.IntVar(value=32)
        self.var_units = tk.IntVar(value=32)
        self.var_dropout = tk.DoubleVar(value=0.3)
        self.var_batch = tk.StringVar(value='128')
        self.var_lr = tk.StringVar(value='0.001')
        self.var_epochs = tk.IntVar(value=5)
        self.var_exp_kind = tk.StringVar(value='Архитектуры')

        self.log_q = queue.Queue()
        self.busy = False

        self.data_loaded = False
        self.vocab_loaded = None
        self.X_train_raw = None
        self.y_train = None
        self.X_test_raw = None
        self.y_test = None

        self.history = None
        self.model = None
        self.device = get_device()
        self.train_seconds = 0
        self.test_info = ""
        self.metrics = {}
        self.cm = None
        self.y_true = None
        self.y_pred = None
        self.errors = []
        self.exp_results = []

        self._build_notebook()
        self.root.after(100, self._poll_log)

    def _build_notebook(self):
        style = ttk.Style(self.root)
        style.configure('Treeview', rowheight=26)

        nb = ttk.Notebook(self.root)
        nb.pack(fill='both', expand=True)

        self.tab_model = ttk.Frame(nb, padding=8)
        self.tab_curves = ttk.Frame(nb, padding=8)
        self.tab_quality = ttk.Frame(nb, padding=8)
        self.tab_exp = ttk.Frame(nb, padding=8)

        nb.add(self.tab_model, text="Данные и модель")
        nb.add(self.tab_curves, text="Графики обучения")
        nb.add(self.tab_quality, text="Оценка качества")
        nb.add(self.tab_exp, text="Эксперименты")

        self._build_model_tab()
        self._build_curves_tab()
        self._build_quality_tab()
        self._build_exp_tab()

    def _build_model_tab(self):
        left = ttk.Frame(self.tab_model)
        left.pack(side='left', fill='y', padx=(0, 10))

        frm = ttk.LabelFrame(left, text="Датасет IMDB", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Словарь (num_words):",
                  lambda p: ttk.Spinbox(p, from_=1000, to=50000, increment=1000,
                                        textvariable=self.var_vocab, width=9))
        self._row(frm, "Длина послед-ти (max_len):",
                  lambda p: ttk.Spinbox(p, from_=20, to=500, increment=10,
                                        textvariable=self.var_max_len, width=9))
        self._row(frm, "Обучающих отзывов:",
                  lambda p: ttk.Spinbox(p, from_=1000, to=25000, increment=1000,
                                        textvariable=self.var_samples, width=9))

        frm = ttk.LabelFrame(left, text="Модель RNN", padding=8)
        frm.pack(fill='x', pady=(0, 8))
        self._row(frm, "Тип слоя:",
                  lambda p: ttk.Combobox(p, textvariable=self.var_cell,
                                         values=('SimpleRNN', 'LSTM', 'GRU'),
                                         state='readonly', width=9))
        self._row(frm, "Размер эмбеддинга:",
                  lambda p: ttk.Spinbox(p, from_=8, to=256, increment=8,
                                        textvariable=self.var_embed, width=9))
        self._row(frm, "Число нейронов:",
                  lambda p: ttk.Spinbox(p, from_=8, to=256, increment=8,
                                        textvariable=self.var_units, width=9))
        self._row(frm, "Dropout:",
                  lambda p: ttk.Spinbox(p, from_=0.0, to=0.9, increment=0.05,
                                        textvariable=self.var_dropout, width=9))
        self._row(frm, "Batch size:",
                  lambda p: ttk.Combobox(p, textvariable=self.var_batch,
                                         values=('32', '64', '128', '256'),
                                         state='readonly', width=9))
        self._row(frm, "Скорость обучения:",
                  lambda p: ttk.Entry(p, textvariable=self.var_lr, width=11))
        self._row(frm, "Эпох:",
                  lambda p: ttk.Spinbox(p, from_=1, to=10,
                                        textvariable=self.var_epochs, width=9))

        ttk.Button(left, text="Загрузить данные",
                   command=self._load_data).pack(fill='x', pady=(0, 6))
        ttk.Button(left, text="Обучить модель",
                   command=self._train).pack(fill='x', pady=(0, 6))
        ttk.Button(left, text="Примеры отзывов",
                   command=self._show_examples).pack(fill='x')

        right = ttk.Frame(self.tab_model)
        right.pack(side='left', fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Результаты обучения", padding=8)
        frm.pack(fill='both', expand=True)
        self.txt_results = tk.Text(frm, wrap='word', state='disabled',
                                   width=42, height=12, font=("Arial", 10))
        self.txt_results.pack(fill='both', expand=True)

        frm = ttk.LabelFrame(right, text="Журнал обучения", padding=8)
        frm.pack(fill='both', expand=True, pady=(8, 0))
        self.txt_log = tk.Text(frm, wrap='word', state='disabled', height=9,
                               width=42, font=("Consolas", 9))
        self.txt_log.pack(fill='both', expand=True)

    def _build_curves_tab(self):
        self.fig_curves = plt.Figure(figsize=(11, 5.5))
        self.canvas_curves = FigureCanvasTkAgg(self.fig_curves,
                                               master=self.tab_curves)
        self.canvas_curves.get_tk_widget().pack(fill='both', expand=True)
        ttk.Label(self.tab_curves,
                  text="Изменение loss и accuracy по эпохам "
                       "(обучение и валидация).").pack()

    def _build_quality_tab(self):
        top = ttk.Frame(self.tab_quality)
        top.pack(fill='both', expand=True)
        frm = ttk.LabelFrame(top, text="Метрики на тестовых данных",
                             padding=6)
        frm.pack(side='left', fill='y')
        self.txt_metrics = tk.Text(frm, wrap='word', state='disabled', width=34,
                                   height=11, font=("Courier New", 10))
        self.txt_metrics.pack(fill='both', expand=True)

        frm = ttk.LabelFrame(top, text="Confusion matrix", padding=6)
        frm.pack(side='left', fill='both', expand=True, padx=(6, 0))
        self.fig_cm = plt.Figure(figsize=(5, 3.6))
        self.canvas_cm = FigureCanvasTkAgg(self.fig_cm, master=frm)
        self.canvas_cm.get_tk_widget().pack(fill='both', expand=True)

        frm = ttk.LabelFrame(top, text="Отчёт классификации", padding=6)
        frm.pack(side='left', fill='both', expand=True, padx=(6, 0))
        self.txt_report = tk.Text(frm, wrap='none', state='disabled', width=42,
                                  height=11, font=("Courier New", 9))
        self.txt_report.pack(fill='both', expand=True)

        frm = ttk.LabelFrame(self.tab_quality, text="Ошибки классификации",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(8, 0))
        cols = ('num', 'fact', 'pred', 'text')
        self.tree_errors = ttk.Treeview(frm, columns=cols, show='headings',
                                        height=8)
        self.tree_errors.heading('num', text='№')
        self.tree_errors.heading('fact', text='Факт')
        self.tree_errors.heading('pred', text='Прогноз')
        self.tree_errors.heading('text', text='Текст отзыва (начало)')
        self.tree_errors.column('num', width=40, anchor='center')
        self.tree_errors.column('fact', width=55, anchor='center')
        self.tree_errors.column('pred', width=65, anchor='center')
        self.tree_errors.column('text', width=900, anchor='w')
        self.tree_errors.pack(fill='both', expand=True)

    def _build_exp_tab(self):
        top = ttk.Frame(self.tab_exp)
        top.pack(fill='x', pady=(0, 8))
        ttk.Label(top, text="Виды экспериментов:").pack(side='left')
        ttk.Combobox(top, textvariable=self.var_exp_kind, state='readonly',
                     width=30, values=(
                         'Архитектуры', 'Длина последовательности',
                         'Размер эмбеддинга', 'Batch size', 'Learning rate')
                     ).pack(side='left', padx=6)
        self.btn_exp = ttk.Button(top, text="Запустить эксперимент",
                                  command=self._run_experiment)
        self.btn_exp.pack(side='left', padx=6)
        ttk.Label(top,
                  text="Эксперимент: 3 варианта, 2 эпохи, до 5000 отзывов.",
                  foreground='#555').pack(side='left', padx=10)

        mid = ttk.Frame(self.tab_exp)
        mid.pack(fill='both', expand=True)
        frm = ttk.LabelFrame(mid, text="Результаты сравнения", padding=6)
        frm.pack(side='left', fill='both', expand=True)
        cols = ('cfg', 'acc', 'prec', 'rec', 'f1', 'time')
        self.tree_exp = ttk.Treeview(frm, columns=cols, show='headings',
                                     height=9)
        self.tree_exp.heading('cfg', text='Вариант')
        self.tree_exp.heading('acc', text='Accuracy')
        self.tree_exp.heading('prec', text='Precision')
        self.tree_exp.heading('rec', text='Recall')
        self.tree_exp.heading('f1', text='F1-score')
        self.tree_exp.heading('time', text='Время, с')
        self.tree_exp.column('cfg', width=190, anchor='center')
        for c in ('acc', 'prec', 'rec', 'f1', 'time'):
            self.tree_exp.column(c, width=105, anchor='center')
        self.tree_exp.pack(fill='both', expand=True)

        frm = ttk.LabelFrame(mid, text="Accuracy по вариантам", padding=6)
        frm.pack(side='left', fill='both', expand=True, padx=(8, 0))
        self.fig_exp = plt.Figure(figsize=(6, 4.4))
        self.canvas_exp = FigureCanvasTkAgg(self.fig_exp, master=frm)
        self.canvas_exp.get_tk_widget().pack(fill='both', expand=True)

        frm = ttk.LabelFrame(self.tab_exp, text="Выводы по экспериментам",
                             padding=6)
        frm.pack(fill='both', expand=True, pady=(8, 0))
        self.txt_concl = tk.Text(frm, wrap='word', height=7)
        self.txt_concl.insert('1.0', self._conclusions_text())
        self.txt_concl.pack(fill='both', expand=True)

    def _conclusions_text(self):
        return (
            "Выводы по экспериментам:\n"
            "1. LSTM и GRU обучаются медленнее SimpleRNN, но запоминают\n"
            "   длинные зависимости лучше и дают большую точность.\n"
            "2. С ростом max_len качество сначала растёт, затем почти\n"
            "   не меняется, а время обучения увеличивается.\n"
            "3. Больший размер эмбеддинга слабо влияет на точность, но\n"
            "   заметно увеличивает число параметров модели.\n"
            "4. Увеличение batch size ускоряет обучение, но при очень\n"
            "   больших значениях точность может немного снизиться.\n"
            "5. Слишком большая скорость обучения (lr=0.01) ухудшает\n"
            "   сходимость; оптимальное значение около 0.001.\n"
            "6. Проблема исчезающего градиента решается применением\n"
            "   LSTM/GRU вместо SimpleRNN, ReLU, регуляризацией,\n"
            "   правильной инициализацией весов и отсечением градиента.")

    @staticmethod
    def _row(parent, label, factory):
        row = ttk.Frame(parent)
        row.pack(fill='x', pady=2)
        ttk.Label(row, text=label, width=26).pack(side='left')
        widget = factory(row)
        widget.pack(side='left')
        return widget

    @staticmethod
    def _parse_float(var, default):
        try:
            return float(var.get().replace(',', '.'))
        except ValueError:
            return default

    def _log(self, text):
        self.log_q.put(text)

    def _poll_log(self):
        while True:
            try:
                msg = self.log_q.get_nowait()
            except queue.Empty:
                break
            if msg == '==DONE==':
                self._after_train()
            elif msg == '==EXP_DONE==':
                self._after_experiment()
            else:
                self.txt_log.configure(state='normal')
                self.txt_log.insert('end', msg + '\n')
                self.txt_log.see('end')
                self.txt_log.configure(state='disabled')
        self.root.after(100, self._poll_log)

    def _set_text(self, widget, text):
        widget.configure(state='normal')
        widget.delete('1.0', 'end')
        widget.insert('1.0', text)
        widget.configure(state='disabled')

    def _ensure_data(self, vocab):
        if self.data_loaded and vocab == self.vocab_loaded:
            return
        self._log(f"Загрузка датасета IMDB (num_words={vocab})...")
        (self.X_train_raw, self.y_train,
         self.X_test_raw, self.y_test) = load_imdb(vocab, log=self._log)
        self.data_loaded = True
        self.vocab_loaded = vocab
        self._log(f"Данные загружены: train={len(self.X_train_raw)}, "
                  f"test={len(self.X_test_raw)}")

    def _pad_data(self, max_len):
        self.X_train = pad_sequences(self.X_train_raw, maxlen=max_len)
        self.X_test = pad_sequences(self.X_test_raw, maxlen=max_len)
        return max_len

    def _load_data(self):
        if self.busy:
            return
        try:
            vocab = int(self.var_vocab.get())
            self._ensure_data(vocab)
            max_len = int(self.var_max_len.get())
            self._pad_data(max_len)
            n_pos = int(np.sum(np.asarray(self.y_train) == 1))
            self._log(f"Предобработка: padding до длины {max_len}. "
                      f"Максимальное число слов в отзыве: "
                      f"{max(len(r) for r in self.X_train_raw)}")
            self._log(f"Классы в train: 0 = {len(self.y_train) - n_pos}, "
                      f"1 = {n_pos}")
        except Exception as e:
            self._log("Ошибка загрузки данных: " + str(e))

    def _show_examples(self):
        if self.busy:
            return
        try:
            vocab = int(self.var_vocab.get())
            self._ensure_data(vocab)
            text = "Примеры отзывов из обучающего набора:\n\n"
            pos = []
            neg = []
            i = 0
            while (len(pos) < 2 or len(neg) < 2) and i < len(self.y_train):
                label = int(self.y_train[i])
                if label == 1 and len(pos) < 2:
                    pos.append(i)
                elif label == 0 and len(neg) < 2:
                    neg.append(i)
                i += 1
            for idx in pos + neg:
                label = int(self.y_train[idx])
                text += "--- Отзыв №" + str(idx) + " ("
                text += "положительный" if label else "отрицательный"
                text += ") ---\n"
                text += decode_review(self.X_train_raw[idx])[:600] + "\n\n"
            self._set_text(self.txt_results, text)
        except Exception as e:
            self._log("Ошибка: " + str(e))

    def _train(self):
        if self.busy:
            return
        self.busy = True
        try:
            self.train_params = {
                'vocab': int(self.var_vocab.get()),
                'max_len': int(self.var_max_len.get()),
                'samples': int(self.var_samples.get()),
                'embed': int(self.var_embed.get()),
                'units': int(self.var_units.get()),
                'dropout': float(self.var_dropout.get()),
                'batch': int(self.var_batch.get()),
                'lr': self._parse_float(self.var_lr, 0.001),
                'epochs': int(self.var_epochs.get()),
                'cell': self.var_cell.get(),
            }
        except tk.TclError:
            self.busy = False
            return
        self._log("Начало обучения в фоновом потоке...")
        threading.Thread(target=self._train_worker, daemon=True).start()

    def _train_worker(self):
        try:
            p = self.train_params
            vocab = p['vocab']
            max_len = p['max_len']
            samples = p['samples']
            embed = p['embed']
            units = p['units']
            dropout = p['dropout']
            batch = p['batch']
            lr = p['lr']
            epochs = p['epochs']
            cell = p['cell']

            self._ensure_data(vocab)
            self._pad_data(max_len)

            n_train = min(samples, len(self.X_train))
            X = self.X_train[:n_train]
            y = np.asarray(self.y_train[:n_train], dtype=np.int64)
            X_tr, y_tr, X_val, y_val = split_train_val(X, y, 0.2, seed=42)

            self._log(f"Модель: {cell}, эмбеддинг={embed}, "
                      f"нейронов={units}, max_len={max_len}, "
                      f"dropout={dropout}")
            self._log(f"Параметры: batch_size={batch}, lr={lr}, "
                      f"epochs={epochs}, отзывов={n_train} "
                      f"(train={len(X_tr)}, val={len(X_val)})")
            self.device = get_device()
            self._log(f"PyTorch {torch.__version__}, "
                      f"устройство: {device_label(self.device)}")
            self._log("Отсечение градиентов: max_norm=1.0")
            self._log("Тренируем...")

            torch.manual_seed(42)
            model = build_model(cell, vocab, embed, units, dropout)
            model = model.to(self.device)

            start = time.time()
            self.history = train_model(
                model, X_tr, y_tr, X_val, y_val, epochs, batch, lr,
                self.device, log=self._log)
            self.train_seconds = time.time() - start

            self.model = model

            n_test = min(2500, len(self.X_test))
            proba = predict_proba(model, self.X_test[:n_test],
                                  device=self.device)
            self.y_pred = (proba > 0.5).astype(int)
            self.y_true = np.asarray(self.y_test[:n_test])

            self.metrics = compute_metrics(self.y_true, self.y_pred)
            self.cm = confusion_matrix(self.y_true, self.y_pred)
            self.test_info = (f"Тестовая выборка: {n_test} отзывов, "
                              f"порог = 0.5")
            self.errors = []
            for i in range(n_test):
                if self.y_true[i] != self.y_pred[i]:
                    self.errors.append((i, int(self.y_true[i]),
                                        int(self.y_pred[i]),
                                        self.X_test_raw[i]))
                    if len(self.errors) >= 15:
                        break
            self._log(f"Обучение завершено за {self.train_seconds:.1f} с. "
                      f"Accuracy: {self.metrics['accuracy']:.4f}")
        except Exception as e:
            self._log("Ошибка обучения: " + str(e))
        self._log('==DONE==')

    def _after_train(self):
        self.busy = False
        p = self.train_params
        text = (f"Архитектура (PyTorch): Embedding({p['embed']}) -> "
                f"{p['cell']}({p['units']}) -> Dropout({p['dropout']}) "
                f"-> Linear(1)\n")
        if self.model is not None:
            text += (f"Всего параметров: "
                     f"{count_parameters(self.model):,}\n")
            text += (f"Устройство: {device_label(self.device)}\n\n")
            text += "=== Сводка модели ===\n"
            text += "\n".join(model_summary(self.model)) + "\n\n"
        else:
            text += "(модель не построена)\n\n"
        text += "=== Метрики на тестовых данных ===\n"
        if self.metrics:
            text += (f"Точность (accuracy):  "
                     f"{self.metrics['accuracy']:.4f}\n")
            text += (f"Точность (precision): "
                     f"{self.metrics['precision']:.4f}\n")
            text += (f"Полнота (recall):     "
                     f"{self.metrics['recall']:.4f}\n")
            text += f"F1-score:             {self.metrics['f1']:.4f}\n"
            text += f"Время обучения:       {self.train_seconds:.1f} с\n"
        else:
            text += "Метрики не рассчитаны (см. журнал обучения).\n"
        self._set_text(self.txt_results, text)
        self._draw_curves()
        if self.metrics:
            self._draw_quality()

    def _draw_curves(self):
        h = self.history
        if not h:
            return
        fig = self.fig_curves
        fig.clear()
        ax1 = fig.add_subplot(121)
        ax1.plot(h['loss'], marker='o', color='#c44e52',
                 label='train_loss')
        ax1.plot(h['val_loss'], marker='o', color='#c44e52',
                 linestyle='--', label='val_loss')
        ax1.set_title("Функция потерь (BCEWithLogitsLoss)")
        ax1.set_xlabel("Эпоха")
        ax1.set_ylabel("Loss")
        ax1.legend()
        ax1.grid(True)

        ax2 = fig.add_subplot(122)
        ax2.plot(h['accuracy'], marker='o', color='#4c72b0',
                 label='train_accuracy')
        ax2.plot(h['val_accuracy'], marker='o', color='#4c72b0',
                 linestyle='--', label='val_accuracy')
        ax2.set_title("Точность классификации")
        ax2.set_xlabel("Эпоха")
        ax2.set_ylabel("Accuracy")
        ax2.legend()
        ax2.grid(True)

        fig.tight_layout()
        self.canvas_curves.draw_idle()

    def _draw_quality(self):
        m = self.metrics
        text = self.test_info + "\n\n"
        text += f"accuracy  = {m['accuracy']:.4f}\n"
        text += f"precision = {m['precision']:.4f}\n"
        text += f"recall    = {m['recall']:.4f}\n"
        text += f"f1-score  = {m['f1']:.4f}\n"
        text += f"Время:    = {self.train_seconds:.1f} с\n"
        self._set_text(self.txt_metrics, text)

        self.fig_cm.clear()
        ax = self.fig_cm.add_subplot(111)
        im = ax.imshow(self.cm, cmap='Blues')
        ax.set_xticks([0, 1])
        ax.set_yticks([0, 1])
        ax.set_xticklabels(['0 (негатив)', '1 (позитив)'])
        ax.set_yticklabels(['0 (негатив)', '1 (позитив)'])
        ax.set_xlabel("Предсказано")
        ax.set_ylabel("Факт")
        for i in range(2):
            for j in range(2):
                ax.text(j, i, str(self.cm[i, j]), ha='center',
                        va='center', color='black', fontsize=13)
        ax.set_title("Confusion matrix")
        self.fig_cm.colorbar(im, ax=ax, fraction=0.046)
        self.fig_cm.tight_layout()
        self.canvas_cm.draw_idle()

        report = classification_report(
            self.y_true, self.y_pred,
            target_names=['0 (негатив)', '1 (позитив)'], zero_division=0)
        self._set_text(self.txt_report, report)

        for item in self.tree_errors.get_children():
            self.tree_errors.delete(item)
        for k, (i, fact, pred, seq) in enumerate(self.errors, 1):
            snippet = decode_review(seq)[:110]
            self.tree_errors.insert('', 'end', values=(k, fact, pred, snippet))

    def _run_experiment(self):
        if self.busy:
            return
        self.busy = True
        self.btn_exp.configure(state='disabled')
        try:
            self.exp_params = {
                'kind': self.var_exp_kind.get(),
                'vocab': int(self.var_vocab.get()),
                'max_len': int(self.var_max_len.get()),
                'embed': int(self.var_embed.get()),
                'units': int(self.var_units.get()),
                'dropout': float(self.var_dropout.get()),
                'cell': self.var_cell.get(),
                'lr': self._parse_float(self.var_lr, 0.001),
                'batch': int(self.var_batch.get()),
            }
        except tk.TclError:
            self.busy = False
            return
        self._log(f"Эксперимент: {self.exp_params['kind']}...")
        threading.Thread(target=self._exp_worker, daemon=True).start()

    def _exp_worker(self):
        try:
            p = self.exp_params
            kind = p['kind']
            vocab = p['vocab']
            max_len = p['max_len']
            embed = p['embed']
            units = p['units']
            dropout = p['dropout']
            cell = p['cell']
            lr = p['lr']
            batch = p['batch']

            self._ensure_data(vocab)
            n_train = min(5000, len(self.X_train_raw))
            n_test = min(2000, len(self.X_test_raw))
            device = get_device()
            self._log(f"Устройство: {device_label(device)}")

            configs = self._experiment_configs(kind)
            results = []
            for name, override in configs:
                cur_len = override.get('max_len', max_len)
                self._pad_data(cur_len)
                X = self.X_train[:n_train]
                y = np.asarray(self.y_train[:n_train], dtype=np.int64)
                X_tr, y_tr, X_val, y_val = split_train_val(X, y, 0.2, seed=42)
                y_test_part = np.asarray(self.y_test[:n_test])

                e_dim = override.get('embed', embed)
                u = override.get('units', units)
                c_cell = override.get('cell', cell)
                c_batch = override.get('batch', batch)
                c_lr = override.get('lr', lr)

                self._log(f"Обучаю вариант '{name}' "
                          f"(max_len={cur_len})...")
                torch.manual_seed(42)
                model = build_model(c_cell, vocab, e_dim, u, dropout)
                model = model.to(device)
                start = time.time()
                train_model(model, X_tr, y_tr, X_val, y_val, 2, c_batch,
                            c_lr, device, clip=1.0)
                elapsed = time.time() - start
                proba = predict_proba(model, self.X_test[:n_test],
                                      device=device)
                y_pred = (proba > 0.5).astype(int)
                met = compute_metrics(y_test_part, y_pred)
                results.append((name, met, elapsed))
                self._log(f"'{name}': acc={met['accuracy']:.4f}, "
                          f"время={elapsed:.1f} с")
            self.exp_results = results
        except Exception as e:
            self._log("Ошибка эксперимента: " + str(e))
        self._log('==EXP_DONE==')

    def _experiment_configs(self, kind):
        if kind == 'Архитектуры':
            return [('SimpleRNN', {'cell': 'SimpleRNN'}),
                    ('LSTM', {'cell': 'LSTM'}),
                    ('GRU', {'cell': 'GRU'})]
        if kind == 'Длина последовательности':
            return [('max_len=50', {'max_len': 50}),
                    ('max_len=100', {'max_len': 100}),
                    ('max_len=200', {'max_len': 200})]
        if kind == 'Размер эмбеддинга':
            return [('embed=16', {'embed': 16}),
                    ('embed=32', {'embed': 32}),
                    ('embed=64', {'embed': 64})]
        if kind == 'Batch size':
            return [('batch=32', {'batch': 32}),
                    ('batch=64', {'batch': 64}),
                    ('batch=128', {'batch': 128})]
        return [('lr=0.0001', {'lr': 0.0001}),
                ('lr=0.001', {'lr': 0.001}),
                ('lr=0.01', {'lr': 0.01})]

    def _after_experiment(self):
        self.busy = False
        self.btn_exp.configure(state='normal')
        for item in self.tree_exp.get_children():
            self.tree_exp.delete(item)
        for name, met, elapsed in self.exp_results:
            self.tree_exp.insert('', 'end', values=(
                name, f"{met['accuracy']:.4f}", f"{met['precision']:.4f}",
                f"{met['recall']:.4f}", f"{met['f1']:.4f}",
                f"{elapsed:.1f}"))

        self.fig_exp.clear()
        ax = self.fig_exp.add_subplot(111)
        names = [r[0] for r in self.exp_results]
        accs = [r[1]['accuracy'] for r in self.exp_results]
        colors = ['#4c72b0', '#dd8452', '#55a868']
        ax.bar(names, accs, color=colors[:len(names)])
        for i, a in enumerate(accs):
            ax.text(i, a + 0.005, f"{a:.3f}", ha='center', fontsize=9)
        ax.set_ylim(0, 1.05)
        ax.set_title(f"{self.var_exp_kind.get()}: accuracy")
        ax.set_ylabel("Accuracy")
        ax.grid(True, axis='y')
        self.fig_exp.tight_layout()
        self.canvas_exp.draw_idle()
        self._log("Эксперимент завершён.")


def main():
    root = tk.Tk()
    app = Lab9App(root)
    root.protocol("WM_DELETE_WINDOW", lambda: (root.destroy(), root.quit()))
    root.mainloop()


if __name__ == '__main__':
    main()

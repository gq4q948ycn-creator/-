import tkinter as tk
from tkinter import ttk, messagebox
import random
import json
import os

# 1. Список предопределённых задач
TASKS = [
    {"text": "Прочитать статью", "type": "учёба"},
    {"text": "Сделать зарядку", "type": "спорт"},
    {"text": "Написать отчёт", "type": "работа"},
    {"text": "Посмотреть обучающее видео", "type": "учёба"},
    {"text": "Разобрать почту", "type": "работа"},
    {"text": "Погулять на свежем воздухе", "type": "отдых"}
]

HISTORY_FILE = "history.json"

class TaskGenerator:
    def __init__(self, root):
        self.root = root
        self.root.title("Task Generator")
        self.root.geometry("600x500")
        self.history = self.load_history()
        self.create_widgets()

    def create_widgets(self):
        # Кнопка генерации задачи (шаг 2)
        tk.Button(
            self.root,
            text="Сгенерировать задачу",
            command=self.generate_task,
            bg="#4CAF50",
            fg="white"
        ).pack(pady=10, fill=tk.X, padx=20)

        # Метка для текущей задачи
        self.task_label = tk.Label(
            self.root,
            text="Ваша задача появится здесь",
            font=("Arial", 12)
        )
        self.task_label.pack(pady=10, padx=20)

        # Фильтр по типу задачи (шаг 4)
        tk.Label(self.root, text="Фильтр по типу:").pack(anchor="w", padx=20)
        self.filter_var = tk.StringVar(value="все")
        types = ["все"] + list(set(task["type"] for task in TASKS))
        ttk.Combobox(
            self.root,
            textvariable=self.filter_var,
            values=types,
            state="readonly",
            width=15
        ).pack(pady=5, padx=20)

        # Список истории задач (шаг 3)
        self.history_listbox = tk.Listbox(self.root, height=15)
        self.history_listbox.pack(pady=10, padx=20, fill=tk.BOTH, expand=True)
        scrollbar = tk.Scrollbar(self.history_listbox)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.history_listbox.config(yscrollcommand=scrollbar.set)
        scrollbar.config(command=self.history_listbox.yview)

        # Поле ввода и кнопка добавления задачи
        entry_frame = tk.Frame(self.root)
        entry_frame.pack(pady=5)
        self.task_entry = tk.Entry(entry_frame, width=40)
        self.task_entry.pack(side=tk.LEFT, padx=5)
        tk.Button(
            entry_frame,
            text="Добавить задачу",
            command=self.add_task,
            bg="#2196F3",
            fg="white"
        ).pack(side=tk.LEFT, padx=5)
        tk.Label(entry_frame, text="Тип:").pack(side=tk.LEFT, padx=5)
        self.type_var = tk.StringVar(value="учёба")
        ttk.Combobox(
            entry_frame,
            textvariable=self.type_var,
            values=["учёба", "спорт", "работа", "отдых"],
            state="readonly",
            width=10
        ).pack(side=tk.LEFT, padx=5)

    def generate_task(self):
        if not TASKS:
            messagebox.showwarning("Предупреждение", "Список задач пуст!")
            return
        task = random.choice(TASKS)
        self.task_label.config(text=f"Ваша задача: {task['text']} (тип: {task['type']})")
        self.add_to_history(task)
        self.update_history_list()

    def add_task(self):
        text = self.task_entry.get().strip()
        task_type = self.type_var.get()
        if not text:  # Шаг 6 — проверка на пустую строку
            messagebox.showerror("Ошибка", "Поле задачи не может быть пустым!")
            return
        new_task = {"text": text, "type": task_type}
        TASKS.append(new_task)
        self.add_to_history(new_task)
        self.task_entry.delete(0, tk.END)
        self.update_history_list()

    def add_to_history(self, task):
        self.history.append(task)
        self.save_history()

    def update_history_list(self):
        self.history_listbox.delete(0, tk.END)
        filter_type = self.filter_var.get()
        for task in self.history:
            if filter_type == "все" or task["type"] == filter_type:
                self.history_listbox.insert(tk.END, f"{task['text']} ({task['type']})")

    def load_history(self):
        if os.path.exists(HISTORY_FILE):
            with open(HISTORY_FILE, 'r') as f:
                return json.load(f)
        return []

    def save_history(self):  # Шаг 5 — сохранение в JSON
        with open(HISTORY_FILE, 'w') as f:
            json.dump(self.history, f, indent=2)

if __name__ == "__main__":
    root = tk.Tk()
    app = TaskGenerator(root)
    root.mainloop()

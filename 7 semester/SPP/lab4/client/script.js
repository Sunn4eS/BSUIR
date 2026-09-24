const taskInput = document.getElementById("taskInput");
const addTaskButton = document.getElementById("addTaskButton");
const taskList = document.getElementById("taskList");

const webSocketProtocol =
    window.location.protocol === "https:" ? "wss" : "ws";
const socket = new WebSocket(
    webSocketProtocol + "://" + window.location.host
);

socket.addEventListener("message", function (event) {
    const data = JSON.parse(event.data);
    if (data.type === "taskCreated") {
        addTaskToPage(data.task);
    }
    if (data.type === "taskUpdated") {
        updateTaskOnPage(data.task);
    }
    if (data.type === "taskDeleted") {
        deleteTaskFromPage(data.taskId);
    }
});

async function loadTasks() {
    const response = await fetch("/api/tasks");
    const tasks = await response.json();

    taskList.innerHTML = "";

    tasks.forEach(function (task) {
        addTaskToPage(task);
    });
}

addTaskButton.addEventListener("click", createTask);

async function createTask() {
    const title = taskInput.value.trim();

    if (title === "") {
        return;
    }

    await fetch("/api/tasks", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({ title: title })
    });

    taskInput.value = "";
}

function addTaskToPage(task) {
    const existingTask = document.getElementById(task.id);
    if (existingTask) {
        return;
    }

    const taskElement = document.createElement("div");
    taskElement.id = task.id;
    taskElement.classList.add("task");

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.checked = task.isCompleted;

    const title = document.createElement("span");
    title.textContent = task.title;
    title.classList.add("task-title");

    if (task.isCompleted) {
        title.classList.add("completed");
    }

    const deleteButton = document.createElement("button");
    deleteButton.textContent = "Удалить";

    taskElement.appendChild(checkbox);
    taskElement.appendChild(title);
    taskElement.appendChild(deleteButton);

    taskList.appendChild(taskElement);

    checkbox.addEventListener("change", async function () {
        await fetch("/api/tasks/" + task.id, {
            method: "PUT",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                isCompleted: checkbox.checked
            })
        });
    });

    deleteButton.addEventListener("click", async function () {
        await fetch("/api/tasks/" + task.id, {
            method: "DELETE"
        });
    });
}

function updateTaskOnPage(task) {
    const taskElement = document.getElementById(task.id);

    if (!taskElement) {
        return;
    }

    const checkbox = taskElement.querySelector("input");
    const title = taskElement.querySelector(".task-title");

    checkbox.checked = task.isCompleted;

    title.textContent = task.title;

    if (task.isCompleted) {
        title.classList.add("completed");
    } else {
        title.classList.remove("completed");
    }
}

function deleteTaskFromPage(taskId) {
    const taskElement = document.getElementById(taskId);
    if (taskElement) {
        taskElement.remove();
    }
}

loadTasks();
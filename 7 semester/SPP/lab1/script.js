const taskInput = document.getElementById("taskInput");
const addTaskButton = document.getElementById("addTaskButton");
const taskList = document.getElementById("taskList");
addTaskButton.addEventListener("click", addTask);

function addTask() {
const taskTitle = taskInput.value.trim();
if (taskTitle === "") {
    return;
}
const taskElement = document.createElement("li");
taskElement.classList.add("task");
const completedCheckbox = document.createElement("input");
completedCheckbox.type = "checkbox";
const taskTitleElement = document.createElement("span");
taskTitleElement.classList.add("task-title");
taskTitleElement.textContent = taskTitle;
const deleteButton = document.createElement("button");
deleteButton.textContent = "Удалить";
taskElement.appendChild(completedCheckbox);
taskElement.appendChild(taskTitleElement);
taskElement.appendChild(deleteButton);
taskList.appendChild(taskElement);

function isCompleted () {
    if (completedCheckbox.checked) {
        taskTitleElement.classList.add("completed");
    } else {
        taskTitleElement.classList.remove("completed");
    }
}
completedCheckbox.addEventListener("change", isCompleted);
deleteButton.addEventListener("click", function () {
    taskElement.remove();
});
taskInput.value = "";
}

const titleInput = document.getElementById("titleInput");
const descriptionInput = document.getElementById("descriptionInput");
const createdByInput = document.getElementById("createdByInput");
const addTaskButton = document.getElementById("addTaskButton");
const taskList = document.getElementById("taskList");
const taskDetails = document.getElementById("taskDetails");
const closeDetailsButton = document.getElementById("closeDetailsButton");

async function graphQLRequest(query, variables) {
    const response = await fetch("/graphql", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            query: query,
            variables: variables
        })
    });

    return await response.json();
}

async function loadTasks() {
    const query = `
        query {
            tasks {
                id
                title
                isCompleted
            }
        }
    `;

    const result = await graphQLRequest(query, {});

    taskList.innerHTML = "";

    result.data.tasks.forEach(function (task) {
        renderTask(task);
    });
}

addTaskButton.addEventListener("click", createTask);

async function createTask() {
    const title = titleInput.value.trim();
    const description = descriptionInput.value.trim();
    const createdBy = createdByInput.value.trim();

    if (title === "") {
        return;
    }

    if (description === "") {
        return;
    }

    if (createdBy === "") {
        return;
    }

    const mutation = `
        mutation CreateTask(
            $title: String!
            $description: String!
            $createdBy: String!
        ) {
            createTask(
                title: $title
                description: $description
                createdBy: $createdBy
            ) {
                id
                title
                isCompleted
            }
        }
    `;

    const result = await graphQLRequest(mutation, {
        title: title,
        description: description,
        createdBy: createdBy
    });

    renderTask(result.data.createTask);

    titleInput.value = "";
    descriptionInput.value = "";
    createdByInput.value = "";
}

function renderTask(task) {
    if (document.getElementById(task.id)) {
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

    const detailsButton = document.createElement("button");
    detailsButton.textContent = "Подробнее";

    const deleteButton = document.createElement("button");
    deleteButton.textContent = "Удалить";

    taskElement.appendChild(checkbox);
    taskElement.appendChild(title);
    taskElement.appendChild(detailsButton);
    taskElement.appendChild(deleteButton);

    taskList.appendChild(taskElement);

    checkbox.addEventListener("change", async function () {
        const mutation = `
            mutation UpdateTask(
                $id: ID!
                $isCompleted: Boolean!
            ) {
                updateTask(
                    id: $id
                    isCompleted: $isCompleted
                ) {
                    id
                    title
                    isCompleted
                }
            }
        `;

        await graphQLRequest(mutation, {
            id: task.id,
            isCompleted: checkbox.checked
        });

        if (checkbox.checked) {
            title.classList.add("completed");
        } else {
            title.classList.remove("completed");
        }
    });

    detailsButton.addEventListener("click", function () {
        loadTaskDetails(task.id);
    });

    deleteButton.addEventListener("click", async function () {
        const mutation = `
            mutation DeleteTask(
                $id: ID!
            ) {
                deleteTask(
                    id: $id
                )
            }
        `;
        const result = await graphQLRequest(mutation, {
            id: task.id
        });
        if (result.data.deleteTask) {
            taskElement.remove();
        }
    });
}

async function loadTaskDetails(taskId) {
    const query = `
        query GetTask(
            $id: ID!
        ) {
            task(
                id: $id
            ) {
                id
                title
                isCompleted
                description
                createdAt
                createdBy
            }
        }
    `;

    const result = await graphQLRequest(query, {
        id: taskId
    });

    const task = result.data.task;

    if (!task) {
        return;
    }

    document.getElementById("detailId").textContent = task.id;
    document.getElementById("detailTitle").textContent = task.title;
    document.getElementById("detailCompleted").textContent =
        task.isCompleted ? "Да" : "Нет";
    document.getElementById("detailDescription").textContent = task.description;
    document.getElementById("detailCreatedAt").textContent = task.createdAt;
    document.getElementById("detailCreatedBy").textContent = task.createdBy;

    taskDetails.classList.remove("hidden");
}

closeDetailsButton.addEventListener("click", function () {
    taskDetails.classList.add("hidden");
});

loadTasks();
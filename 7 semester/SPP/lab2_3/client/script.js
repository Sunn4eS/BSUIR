const loginBlock =
document.getElementById("loginBlock");

const appBlock =
document.getElementById("appBlock");

const loginInput =
document.getElementById("loginInput");

const passwordInput =
document.getElementById("passwordInput");

const loginButton =
document.getElementById("loginButton");

const loginMessage =
document.getElementById("loginMessage");

const logoutButton =
document.getElementById("logoutButton");

const titleInput =
document.getElementById("titleInput");

const descriptionInput =
document.getElementById("descriptionInput");

const addTaskButton =
document.getElementById("addTaskButton");

const taskList =
document.getElementById("taskList");

loginButton.addEventListener(
"click",
login
);

async function login() {
    const login = loginInput.value;
    const password = passwordInput.value;
    const response = await fetch(
        "/api/login",
        {
            method: "POST",
            headers: {
                "Content-Type":
                "application/json"
            },
            body: JSON.stringify({
                login: login,
                password: password
            })
        }
    );
    const data =
        await response.json();
    if (response.status === 200) {
        loginMessage.textContent = "";
        loginBlock.classList.add(
            "hidden"
        );
        appBlock.classList.remove(
            "hidden"
        );
        loadTasks();

    } else {
        loginMessage.textContent =
        data.message;
    }
}

logoutButton.addEventListener(
    "click",
    logout
);

async function logout() {
    await fetch(
        "/api/logout",
        {
            method: "POST"
        }
    );

    appBlock.classList.add(
        "hidden"
    );
    loginBlock.classList.remove(
        "hidden"
    );
    taskList.innerHTML = "";
}

async function loadTasks() {
    const response = await fetch(
    "/api/tasks"
);

if (response.status === 401) {
    showLogin();
    return;
}

const tasks =
    await response.json();

taskList.innerHTML = "";

tasks.forEach(
    function (task) {
        renderTask(task);
    }
);


}


addTaskButton.addEventListener(
"click",
createTask
);

async function createTask() {


const title =
    titleInput.value.trim();

const description =
    descriptionInput.value.trim();


if (title === "") {
    return;
}


const response = await fetch(
    "/api/tasks",
    {
        method: "POST",

        headers: {
            "Content-Type":
                "application/json"
        },

        body: JSON.stringify({
            title: title,
            description: description
        })
    }
);


if (response.status === 401) {

    showLogin();

    return;

}


const task =
    await response.json();
renderTask(task);


titleInput.value = "";
descriptionInput.value = "";

}


function renderTask(task) {

const taskElement =
    document.createElement("div");
taskElement.classList.add(
    "task"
);

const checkbox =
    document.createElement("input");


checkbox.type = "checkbox";

checkbox.checked =
    task.isCompleted;


const textBlock =
    document.createElement("div");


textBlock.classList.add(
    "task-title"
);


const title =
    document.createElement("strong");


title.textContent =
    task.title;

const description =
    document.createElement("span");


description.classList.add(
    "task-description"
);


description.textContent =
    task.description;

if (task.isCompleted) {
    title.classList.add(
        "completed"
    );

}

textBlock.appendChild(
    title
);


textBlock.appendChild(
    description
);


const deleteButton =
    document.createElement("button");


deleteButton.textContent =
    "Удалить";


taskElement.appendChild(
    checkbox
);


taskElement.appendChild(
    textBlock
);


taskElement.appendChild(
    deleteButton
);


taskList.appendChild(
    taskElement
);

checkbox.addEventListener(
    "change",
    async function () {

        const response =
            await fetch(
                "/api/tasks/" + task.id,
                {
                    method: "PUT",

                    headers: {
                        "Content-Type":
                            "application/json"
                    },

                    body: JSON.stringify({
                        isCompleted:
                            checkbox.checked
                    })
                }
            );


        if (
            response.status === 401
        ) {

            showLogin();

            return;

        }


        if (
            checkbox.checked
        ) {

            title.classList.add(
                "completed"
            );

        } else {

            title.classList.remove(
                "completed"
            );

        }

    }
);



deleteButton.addEventListener(
    "click",
    async function () {

        const response =
            await fetch(
                "/api/tasks/" + task.id,
                {
                    method:
                        "DELETE"
                }
            );


        if (
            response.status === 401
        ) {

            showLogin();

            return;

        }


        if (
            response.status === 200
        ) {

            taskElement.remove();

        }

    }
);


}


function showLogin() {
appBlock.classList.add(
    "hidden"
);


loginBlock.classList.remove(
    "hidden"
);


taskList.innerHTML = "";
}
loadTasks();

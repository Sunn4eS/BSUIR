const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const cookieParser = require("cookie-parser");
const path = require("path");
const crypto = require("crypto");

const {
tasks,
users
} = require("./data");

const {
authMiddleware,
JWT_SECRET
} = require("./authMiddleware");

const app = express();

const PORT = 3000;

app.use(express.json());

app.use(cookieParser());

app.use(
express.static(
path.join(__dirname, "../client")
)
);

async function initializeUser() {

const user = users[0];

if (user.passwordHash !== null) {
    return;
}


user.passwordHash = await bcrypt.hash(
    "password",
    10
);

}

initializeUser();

app.post("/api/login", async function (req, res) {

const login = req.body.login;
const password = req.body.password;

const user = users.find(
    function (currentUser) {

        return currentUser.login === login;

    }
);

if (!user) {

    return res.status(401).json({
        message: "Неверный логин или пароль"
    });

}


const passwordIsCorrect = await bcrypt.compare(
    password,
    user.passwordHash
);


if (!passwordIsCorrect) {

    return res.status(401).json({
        message: "Неверный логин или пароль"
    });

}


const token = jwt.sign(
    {
        id: user.id,
        login: user.login
    },
    JWT_SECRET,
    {
        expiresIn: "1h"
    }
);

res.cookie(
    "token",
    token,
    {
        httpOnly: true
    }
);


res.status(200).json({
    message: "Авторизация выполнена"
});

});

app.post("/api/logout", function (req, res) {
res.clearCookie("token");


res.status(200).json({
    message: "Выход выполнен"
});


});

app.get(
"/api/tasks",
authMiddleware,
function (req, res) {
    res.status(200).json(tasks);

}


);

app.get(
"/api/tasks/:id",
authMiddleware,
function (req, res) {
    const task = tasks.find(
        function (currentTask) {

            return currentTask.id === req.params.id;

        }
    );


    if (!task) {

        return res.status(404).json({
            message: "Задача не найдена"
        });

    }


    res.status(200).json(task);

}


);

app.post(
"/api/tasks",
authMiddleware,
function (req, res) {


    const title = req.body.title;
    const description = req.body.description;

    if (
        typeof title !== "string" ||
        title.trim() === ""
    ) {

        return res.status(400).json({
            message: "Название задачи обязательно"
        });

    }


    const task = {

        id: crypto.randomUUID(),

        title: title,

        isCompleted: false,

        description:
            typeof description === "string"
                ? description
                : "",

        createdAt: Date.now(),

        createdBy: req.user.id

    };


    
    tasks.push(task);


    res.status(200).json(task);

}


);

app.put(
"/api/tasks/:id",
authMiddleware,
function (req, res) {


    const task = tasks.find(
        function (currentTask) {

            return currentTask.id === req.params.id;

        }
    );


    if (!task) {

        return res.status(404).json({
            message: "Задача не найдена"
        });

    }


    if (
        typeof req.body.title === "string"
    ) {

        task.title = req.body.title;

    }


    if (
        typeof req.body.description === "string"
    ) {

        task.description =
            req.body.description;

    }


    if (
        typeof req.body.isCompleted === "boolean"
    ) {

        task.isCompleted =
            req.body.isCompleted;

    }


    res.status(200).json(task);

}


);

app.delete(
"/api/tasks/:id",
authMiddleware,
function (req, res) {

    const taskIndex = tasks.findIndex(
        function (currentTask) {

            return currentTask.id === req.params.id;

        }
    );


    if (taskIndex === -1) {

        return res.status(404).json({
            message: "Задача не найдена"
        });

    }


    tasks.splice(
        taskIndex,
        1
    );


    res.status(200).json({
        message: "Задача удалена"
    });

}


);

app.listen(
PORT,
function () {

    console.log(
        "Сервер запущен: http://localhost:" + PORT
    );

    console.log(
        "Логин: admin"
    );

    console.log(
        "Пароль: password"
    );

}

);

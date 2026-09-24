const express = require("express");
const path = require("path");
const http = require("http");
const crypto = require("crypto");

const WebSocket = require("ws");

const app = express();
const server = http.createServer(app);

const webSocketServer = new WebSocket.Server({
    server: server
});

const PORT = 3000;

const tasks = [];

app.use(express.json());

app.use(
    express.static(
        path.join(
            __dirname,
            "../client"
        )
    )
);
app.get(
    "/",
    function (req, res) {
        res.sendFile(
            path.join(
                __dirname,
                "../client",
                "index.html"
            )
        );

    }


);

webSocketServer.on(
    "connection",
    function () {


        console.log(
            "Подключился новый WebSocket-клиент"
        );

    }


);

function broadcast(data) {
    const message =
        JSON.stringify(data);
    webSocketServer.clients.forEach(
        function (client) {

            if (
                client.readyState ===
                WebSocket.OPEN
            ) {

                client.send(message);

            }

        }
    );


}

app.get(
    "/api/tasks",
    function (req, res) {
        res.status(200).json(tasks);

    }
);

app.post(
    "/api/tasks",
    function (req, res) {
        const title =
            req.body.title;
        if (
            typeof title !== "string" ||
            title.trim() === ""
        ) {

            return res.status(400).json({
                message:
                    "Название задачи обязательно"
            });

        }

        const task = {

            id:
                crypto.randomUUID(),

            title:
                title.trim(),

            isCompleted:
                false

        };

        tasks.push(task);
        broadcast({
            type: "taskCreated",
            task: task
        });
        res.status(200).json(task);
    }

);

app.put(
    "/api/tasks/:id",
    function (req, res) {
        const task =
            tasks.find(
                function (currentTask) {

                    return (
                        currentTask.id ===
                        req.params.id
                    );

                }
            );
        if (!task) {

            return res.status(404).json({
                message:
                    "Задача не найдена"
            });

        }
        if (
            typeof req.body.title ===
            "string"
        ) {

            task.title =
                req.body.title;

        }

        if (
            typeof req.body.isCompleted ===
            "boolean"
        ) {

            task.isCompleted =
                req.body.isCompleted;

        }

        broadcast({
            type: "taskUpdated",
            task: task
        });

        res.status(200).json(task);

    }


);

app.delete(
    "/api/tasks/:id",
    function (req, res) {
        const taskIndex =
            tasks.findIndex(
                function (currentTask) {

                    return (
                        currentTask.id ===
                        req.params.id
                    );

                }
            );
        if (taskIndex === -1) {

            return res.status(404).json({
                message:
                    "Задача не найдена"
            });

        }

        const deletedTask =
            tasks[taskIndex];

        tasks.splice(
            taskIndex,
            1
        );

        broadcast({
            type: "taskDeleted",
            taskId:
                deletedTask.id
        });


        res.status(200).json({
            message:
                "Задача удалена"
        });

    }


);

server.listen(
    PORT,
    function () {
        console.log(
            "Сервер запущен: http://localhost:" +
            PORT
        );

    }
);

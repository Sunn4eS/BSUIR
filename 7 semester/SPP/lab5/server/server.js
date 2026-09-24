const express = require("express");
const path = require("path");
const http = require("http");
const crypto = require("crypto");

const {
    ApolloServer
} = require("@apollo/server");

const {
    expressMiddleware
} = require("@apollo/server/express4");
const app = express();

const httpServer =
    http.createServer(app);

const PORT = 3000;
const tasks = [];
const typeDefs = `


type Task {

    id: ID!

    title: String!

    isCompleted: Boolean!

    description: String!

    createdAt: String!

    createdBy: String!

}


type Query {

    tasks: [Task!]!

    task(id: ID!): Task

}


type Mutation {

    createTask(
        title: String!
        description: String!
        createdBy: String!
    ): Task!

    updateTask(
        id: ID!
        title: String
        description: String
        isCompleted: Boolean
    ): Task

    deleteTask(
        id: ID!
    ): Boolean!

}


`;

const resolvers = {


    Query: {
        tasks: function () {

            return tasks;
        },
        task: function (
            parent,
            args
        ) {

            const task =
                tasks.find(
                    function (currentTask) {

                        return (
                            currentTask.id ===
                            args.id
                        );

                    }
                );


            if (!task) {

                return null;

            }


            return task;

        }

    },


    Mutation: {

        createTask: function (
            parent,
            args
        ) {

            const task = {

                id:
                    crypto.randomUUID(),

                title:
                    args.title,

                isCompleted:
                    false,

                description:
                    args.description,

                createdAt:
                    new Date()
                        .toISOString(),

                createdBy:
                    args.createdBy

            };


            tasks.push(task);


            return task;

        },


        updateTask: function (
            parent,
            args
        ) {

            const task =
                tasks.find(
                    function (currentTask) {

                        return (
                            currentTask.id ===
                            args.id
                        );

                    }
                );

            if (!task) {

                return null;

            }


            if (
                typeof args.title ===
                "string"
            ) {

                task.title =
                    args.title;

            }


            if (
                typeof args.description ===
                "string"
            ) {

                task.description =
                    args.description;

            }
            if (
                typeof args.isCompleted ===
                "boolean"
            ) {

                task.isCompleted =
                    args.isCompleted;

            }


            return task;

        },

        deleteTask: function (
            parent,
            args
        ) {

            const taskIndex =
                tasks.findIndex(
                    function (currentTask) {

                        return (
                            currentTask.id ===
                            args.id
                        );

                    }
                );


            if (taskIndex === -1) {

                return false;

            }

            tasks.splice(
                taskIndex,
                1
            );


            return true;
        }
    }
};

const graphQLServer =
    new ApolloServer({


        typeDefs:
            typeDefs,

        resolvers:
            resolvers

    });

async function startServer() {

    await graphQLServer.start();

    app.use(
        express.json()
    );

    app.use(
        "/graphql",
        expressMiddleware(
            graphQLServer
        )
    );

    const clientPath =
        path.join(
            __dirname,
            "../client"
        );


    app.use(
        express.static(
            clientPath
        )
    );

    app.get(
        "/",
        function (
            req,
            res
        ) {
            res.sendFile(
                path.join(
                    clientPath,
                    "index.html"
                )
            );

        }
    );


    httpServer.listen(
        PORT,
        function () {

            console.log(
                "Сервер запущен: http://localhost:" +
                PORT
            );

            console.log(
                "GraphQL: http://localhost:" +
                PORT +
                "/graphql"
            );

        }
    );


}

startServer();

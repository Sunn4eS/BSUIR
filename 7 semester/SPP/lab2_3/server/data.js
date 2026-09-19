const crypto = require("crypto");

const tasks = [];

const users = [
{
id: crypto.randomUUID(),


    login: "admin",

    passwordHash: null
}

];

module.exports = {
tasks,
users
};

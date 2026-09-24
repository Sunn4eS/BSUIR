const jwt = require("jsonwebtoken");

const JWT_SECRET = "secret_key";

function authMiddleware(req, res, next) {

const token = req.cookies.token;


if (!token) {

    return res.status(401).json({
        message: "Требуется авторизация"
    });

}

try {

    const user = jwt.verify(
        token,
        JWT_SECRET
    );


    req.user = user;


    next();

} catch (error) {

    return res.status(401).json({
        message: "Недействительный токен"
    });

}


}

module.exports = {
authMiddleware,
JWT_SECRET
};

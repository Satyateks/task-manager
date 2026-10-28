const express = require("express");
const { signup, login, refreshAccessToken,logout } = require("../controllers/authController");

const router = express.Router();

router.post("/signup", signup);
router.post("/login", login);
router.post("/refresh-token", refreshAccessToken);
router.post("/logout", logout);



module.exports = router;



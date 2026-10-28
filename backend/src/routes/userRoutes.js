const express = require("express");

const { getUsers } = require("../controllers/userController");

const authenticate = require("../middleware/authMiddleware");

const router = express.Router();

router.use(authenticate);

router.get("/", getUsers);

module.exports = router;

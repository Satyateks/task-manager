const pool = require("../config/db");

const getUsers = async (req, res) => {
  try {
    const [users] = await pool.execute(
      `
      SELECT id, name, email, created_at
      FROM users
      ORDER BY name ASC
      `
    );

    return res.status(200).json({
      success: true,
      count: users.length,
      users,
    });
  } catch (error) {
    console.error("Get users error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

module.exports = {
  getUsers,
};

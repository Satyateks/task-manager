const pool = require("../config/db");

// Create Task
const createTask = async (req, res) => {
  try {
    const {
      title,
      description,
      status,
      assignee_id,
      due_date,
    } = req.body;

    if (!title || !title.trim()) {
      return res.status(400).json({
        success: false,
        message: "Title is required",
      });
    }

    const allowedStatuses = ["Todo", "In Progress", "Done"];
    const taskStatus = status || "Todo";

    if (!allowedStatuses.includes(taskStatus)) {
      return res.status(400).json({
        success: false,
        message: "Invalid task status",
      });
    }

    // Check assignee exists
    if (assignee_id) {
      const [users] = await pool.execute(
        "SELECT id FROM users WHERE id = ?",
        [assignee_id]
      );

      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: "Assignee not found",
        });
      }
    }

    const [result] = await pool.execute(
      `INSERT INTO tasks
       (title, description, status, assignee_id, due_date, created_by)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        title.trim(),
        description || null,
        taskStatus,
        assignee_id || null,
        due_date || null,
        req.user.id,
      ]
    );

    return res.status(201).json({
      success: true,
      message: "Task created successfully",
      task: {
        id: result.insertId,
        title: title.trim(),
        description: description || null,
        status: taskStatus,
        assignee_id: assignee_id || null,
        due_date: due_date || null,
        created_by: req.user.id,
      },
    });
  } catch (error) {
    console.error("Create task error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


// Get All Tasks
const getTasks = async (req, res) => {
  try {
    const { status, search } = req.query;

    let query = `
      SELECT
        t.id,
        t.title,
        t.description,
        t.status,
        t.due_date,
        t.created_at,
        t.updated_at,
        t.created_by,
        u.id AS assignee_id,
        u.name AS assignee_name,
        u.email AS assignee_email
      FROM tasks t
      LEFT JOIN users u
        ON t.assignee_id = u.id
      WHERE 1 = 1
    `;

    const params = [];

    // Status filter
    if (status) {
      const allowedStatuses = ["Todo", "In Progress", "Done"];

      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: "Invalid status filter",
        });
      }

      query += " AND t.status = ?";
      params.push(status);
    }

    // Title search
    if (search) {
      query += " AND t.title LIKE ?";
      params.push(`%${search}%`);
    }

    query += " ORDER BY t.created_at DESC";

    const [tasks] = await pool.execute(query, params);

    return res.status(200).json({
      success: true,
      count: tasks.length,
      tasks,
    });
  } catch (error) {
    console.error("Get tasks error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


// Get Single Task
const getTaskById = async (req, res) => {
  try {
    const { id } = req.params;

    const [tasks] = await pool.execute(
      `
      SELECT
        t.id,
        t.title,
        t.description,
        t.status,
        t.due_date,
        t.created_at,
        t.updated_at,
        t.created_by,
        u.id AS assignee_id,
        u.name AS assignee_name,
        u.email AS assignee_email
      FROM tasks t
      LEFT JOIN users u
        ON t.assignee_id = u.id
      WHERE t.id = ?
      `,
      [id]
    );

    if (tasks.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Task not found",
      });
    }

    return res.status(200).json({
      success: true,
      task: tasks[0],
    });
  } catch (error) {
    console.error("Get task error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


// Update Task
const updateTask = async (req, res) => {
  try {
    const { id } = req.params;

    const {
      title,
      description,
      status,
      assignee_id,
      due_date,
    } = req.body;

    // Check task exists
    const [existingTasks] = await pool.execute(
      "SELECT id FROM tasks WHERE id = ?",
      [id]
    );

    if (existingTasks.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Task not found",
      });
    }

    if (title !== undefined && !title.trim()) {
      return res.status(400).json({
        success: false,
        message: "Title cannot be empty",
      });
    }

    const allowedStatuses = ["Todo", "In Progress", "Done"];

    if (
      status !== undefined &&
      !allowedStatuses.includes(status)
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid task status",
      });
    }

    if (assignee_id !== undefined && assignee_id !== null) {
      const [users] = await pool.execute(
        "SELECT id FROM users WHERE id = ?",
        [assignee_id]
      );

      if (users.length === 0) {
        return res.status(404).json({
          success: false,
          message: "Assignee not found",
        });
      }
    }

    const fields = [];
    const values = [];

    if (title !== undefined) {
      fields.push("title = ?");
      values.push(title.trim());
    }

    if (description !== undefined) {
      fields.push("description = ?");
      values.push(description);
    }

    if (status !== undefined) {
      fields.push("status = ?");
      values.push(status);
    }

    if (assignee_id !== undefined) {
      fields.push("assignee_id = ?");
      values.push(assignee_id);
    }

    if (due_date !== undefined) {
      fields.push("due_date = ?");
      values.push(due_date);
    }

    if (fields.length === 0) {
      return res.status(400).json({
        success: false,
        message: "No fields provided for update",
      });
    }

    values.push(id);

    await pool.execute(
      `UPDATE tasks
       SET ${fields.join(", ")}
       WHERE id = ?`,
      values
    );

    const [updatedTasks] = await pool.execute(
      `
      SELECT
        t.id,
        t.title,
        t.description,
        t.status,
        t.due_date,
        t.created_at,
        t.updated_at,
        u.id AS assignee_id,
        u.name AS assignee_name,
        u.email AS assignee_email
      FROM tasks t
      LEFT JOIN users u
        ON t.assignee_id = u.id
      WHERE t.id = ?
      `,
      [id]
    );

    return res.status(200).json({
      success: true,
      message: "Task updated successfully",
      task: updatedTasks[0],
    });
  } catch (error) {
    console.error("Update task error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};


// Delete Task
const deleteTask = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await pool.execute(
      "DELETE FROM tasks WHERE id = ?",
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Task not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Task deleted successfully",
    });
  } catch (error) {
    console.error("Delete task error:", error);

    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

module.exports = {
  createTask,
  getTasks,
  getTaskById,
  updateTask,
  deleteTask,
};

const express = require("express");
const router = express.Router();

// Very simple login endpoint (no password). Returns a userId and role.
router.post("/login", (req, res) => {
  const { username, role } = req.body;
  if (!username || !role) {
    return res.status(400).json({ error: "username and role are required" });
  }
  const userId = Date.now().toString();
  // In production, store users in DB; here we just return an id
  return res.json({ userId, username, role });
});

module.exports = router;

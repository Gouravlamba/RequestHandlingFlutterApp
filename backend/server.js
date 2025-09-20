const express = require("express");
const http = require("http");
const cors = require("cors");
const bodyParser = require("body-parser");
const { Server } = require("socket.io");

const authRoutes = require("./routes/auth");
const requestRoutesFactory = require("./routes/requests");

const app = express();
const server = http.createServer(app);

app.use(cors({ origin: "*" }));   // ✅ allow all origins
app.use(bodyParser.json());

const io = new Server(server, {
  cors: {
    origin: "*",                  // ✅ allow Flutter web
    methods: ["GET", "POST", "PATCH"],
  },
});

// In-memory store
const store = { requests: [], users: [] };

app.use("/auth", authRoutes);
app.use("/requests", requestRoutesFactory(store, io));

const PORT = 3000;
server.listen(PORT, () => console.log(`Backend running at http://localhost:${PORT}`));

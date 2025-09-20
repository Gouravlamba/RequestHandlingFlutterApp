const express = require("express");
const { v4: uuidv4 } = require("uuid");

module.exports = (store, io) => {
  const router = express.Router();

  // Create request
  // Body: { userId: string, items: [ "itemName1", "itemName2", ... ], assignedTo?: string }
  router.post("/", (req, res) => {
    const { userId, items, assignedTo } = req.body;
    if (!userId || !items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ error: "userId and non-empty items array required" });
    }

    const newRequest = {
      id: uuidv4(),
      userId,
      items: items.map((name) => ({ id: uuidv4(), name, status: "Pending" })),
      status: "Pending",
      assignedTo: assignedTo || null,
      createdAt: new Date().toISOString()
    };

    store.requests.push(newRequest);
    io.emit("request_created", newRequest); // real-time notify
    return res.json(newRequest);
  });

  // Get requests
  // Query params: ?role=end_user&userId=xxx   OR ?role=receiver
  router.get("/", (req, res) => {
    const { role, userId } = req.query;
    if (role === "end_user" && userId) {
      return res.json(store.requests.filter((r) => r.userId === userId));
    }
    if (role === "receiver") {
      // receiver sees requests that are pending or partially fulfilled (system can be improved)
      const pendingOrPartial = store.requests.filter((r) => r.status === "Pending" || r.status === "Partially Fulfilled");
      return res.json(pendingOrPartial);
    }
    return res.json(store.requests);
  });

  // Confirm items in a request
  // PATCH /requests/:id/confirm
  // Body: { confirmations: [{ itemId: "...", available: true/false }], receiverId: "..." }
  router.patch("/:id/confirm", (req, res) => {
    const { id } = req.params;
    const { confirmations } = req.body;

    if (!Array.isArray(confirmations)) {
      return res.status(400).json({ error: "confirmations array required" });
    }

    const request = store.requests.find((r) => r.id === id);
    if (!request) return res.status(404).json({ error: "Request not found" });

    // Apply confirmations
    confirmations.forEach((c) => {
      const it = request.items.find((i) => i.id === c.itemId);
      if (it) it.status = c.available ? "Available" : "Not Available";
    });

    // Determine status
    const availableCount = request.items.filter((i) => i.status === "Available").length;
    if (availableCount === request.items.length) {
      request.status = "Confirmed";
    } else if (availableCount > 0) {
      request.status = "Partially Fulfilled";
    } else {
      // none available => keep Pending (or set special state); we keep Pending
      request.status = "Pending";
    }

    // Reassign Not Available items -> create a new request for them
    const notAvailableItems = request.items.filter((i) => i.status === "Not Available");
    let reassignedRequest = null;
    if (notAvailableItems.length > 0) {
      reassignedRequest = {
        id: uuidv4(),
        userId: request.userId,
        items: notAvailableItems.map((i) => ({ id: uuidv4(), name: i.name, status: "Pending" })),
        status: "Pending",
        assignedTo: null,
        createdAt: new Date().toISOString(),
        reassignedFrom: request.id
      };
      store.requests.push(reassignedRequest);
      io.emit("request_reassigned", reassignedRequest);
    }

    io.emit("request_updated", request);
    return res.json({ request, reassignedRequest });
  });

  return router;
};

public const express = require("express");
const { getTimeline } = require("../controllers/postController");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/timeline", protect, getTimeline);

module.exports = router;
 Main {
    
}

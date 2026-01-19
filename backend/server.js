const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const os = require('os');
const fs = require('fs');

const app = express();

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

app.use(cors());
app.use(express.json());

// Serve static files
app.use('/uploads', express.static(uploadDir));

// --- 1. MONGODB CONNECTION ---
mongoose.connect('mongodb://127.0.0.1:27017/fit_tracker')
    .then(() => console.log("✅ Successfully connected to MongoDB!"))
    .catch(err => console.error("❌ MongoDB connection error:", err));

// --- 2. MULTER CONFIGURATION (For Images) ---
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// --- 3. SCHEMAS & MODELS ---
const profileSchema = new mongoose.Schema({
    fullName: String,
    age: Number,
    weight: Number,
    height: Number,
    fitnessGoal: String,
    profileImage: String,
    updatedAt: { type: Date, default: Date.now }
});

const Profile = mongoose.model('Profile', profileSchema);

// --- 4. ROUTES ---

// Get the latest profile
app.get('/get-profile', async (req, res) => {
    try {
        const profile = await Profile.findOne().sort({ updatedAt: -1 });
        if (!profile) return res.status(404).json({ message: "No profile found" });
        res.json(profile);
    } catch (err) {
        res.status(500).json({ error: "Error fetching profile" });
    }
});

app.post('/save-profile', upload.single('profileImage'), async (req, res) => {
    try {
        // req.body contains text fields whether it's JSON or Multipart
        const { fullName, age, weight, height, fitnessGoal } = req.body;

        let updateData = {
            fullName,
            age: Number(age),
            weight: Number(weight),
            height: Number(height),
            fitnessGoal,
            updatedAt: Date.now()
        };

        // Only update image if a new file is sent
        if (req.file) { 
            updateData.profileImage = req.file.filename;
        }

        const profile = await Profile.findOneAndUpdate({}, updateData, {
            new: true,
            upsert: true // Creates if missing, updates if exists
        });

        console.log("✅ Profile Updated in DB");
        res.status(200).json({ message: "Success", profile });
    } catch (err) {
        console.error("❌ Save Error:", err);
        res.status(400).json({ error: "Failed to save profile" });
    }
});
const workoutSchema = new mongoose.Schema({
    exercise: { type: String, required: true },
    sets: { type: Number, required: true },
    reps: { type: Number, required: true },
    weight: { type: Number, required: true },
    duration: { type: Number, required: true },
    createdAt: { type: Date, default: Date.now }
});

const Workout = mongoose.model('Workout', workoutSchema);
// POST Workout data
app.post('/add-workout', async (req, res) => {
    try {
        const { exercise, sets, reps, weight, duration } = req.body;

        const newWorkout = new Workout({
            exercise,
            sets,
            reps,
            weight,
            duration
        });

        await newWorkout.save();
        
        console.log("✅ Workout saved to DB:", exercise);
        res.status(201).json({ message: "Workout added successfully!", workout: newWorkout });
    } catch (err) {
        console.error("❌ Workout Save Error:", err);
        res.status(400).json({ error: "Failed to save workout" });
    }
});
// GET all workouts
app.get('/workouts', async (req, res) => {
    try {
        // Fetch workouts sorted by newest first
        const workouts = await Workout.find().sort({ createdAt: -1 });
        res.json(workouts);
    } catch (err) {
        console.error("❌ Error fetching workouts:", err);
        res.status(500).json({ error: "Failed to fetch workouts" });
    }
});
// --- 5. START SERVER ---
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    const networkInterfaces = os.networkInterfaces();
    let localIp = 'localhost';
    for (const name of Object.keys(networkInterfaces)) {
        for (const net of networkInterfaces[name]) {
            if (net.family === 'IPv4' && !net.internal) {
                localIp = net.address;
            }
        }
    }

    console.log(`\n🚀 Fit Tracker Server is Online!`);
    console.log(`🔗 Local: http://localhost:${PORT}`);
    console.log(`📱 Flutter BaseUrl: http://${localIp}:${PORT}`);
    console.log(`📁 Images: http://${localIp}:${PORT}/uploads/filename.jpg\n`);
});
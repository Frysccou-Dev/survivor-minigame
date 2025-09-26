import express from 'express';
import mongoose from 'mongoose';
import cors from 'cors';
import dotenv from 'dotenv';
import survivorRoutes from './routes/survivorRoutes';
import seedSurvivors from './seeds/seedData';

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Conexión Mongo
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/survivor')
  .then(() => {
    console.log('✅ Connected to MongoDB');
    // Ejecutar seeding después de conectar a la base de datos
    seedSurvivors();
  })
  .catch((error) => {
    console.error('❌ MongoDB connection error:', error);
  });

// Rutas
app.use('/api/survivor', survivorRoutes);

const PORT = process.env.PORT || 4300;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
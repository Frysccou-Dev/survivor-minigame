import express, { Request, Response } from 'express';
import mongoose from 'mongoose';
import { SurvivorService } from '../services/survivorService';

const router = express.Router();

// Se listan todos los survivor
router.get('/', async (req: Request, res: Response) => {
  try {
    const survivors = await SurvivorService.getAllSurvivor();
    res.json(survivors);
  } catch (error) {
    res.status(500).json({ error: 'Error fetching survivors' });
  }
});

// Se lista en detalle un survivor por id
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    if (!id || !mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'Invalid survivor id' });
    }

    const detail = await SurvivorService.getSurvivorDetail(id);
    res.json(detail);
  } catch (error) {
    if ((error as Error).message === 'Survivor not found') {
      return res.status(404).json({ error: 'Survivor not found' });
    }
    res.status(500).json({ error: 'Error fetching survivor detail' });
  }
});

// Se une a un survivor
router.post('/join/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    if (!id || !mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ error: 'Invalid survivor id' });
    }

    const gamble = await SurvivorService.joinSurvivor(id);
    res.json(gamble);
  } catch (error) {
    res.status(500).json({ error: 'Error joining survivor' });
  }
});

// Se pickea un equipo en un match
router.post('/pick', async (req: Request, res: Response) => {
  try {
    const { survivorId, matchId, selectedTeam } = req.body;

    if (!survivorId || !matchId || !selectedTeam) {
      return res
        .status(400)
        .json({ error: 'Missing survivorId, matchId or selectedTeam' });
    }

    if (!mongoose.Types.ObjectId.isValid(survivorId)) {
      return res.status(400).json({ error: 'Invalid survivor id' });
    }

    const prediction = await SurvivorService.makePick(
      survivorId,
      matchId,
      selectedTeam
    );
    res.json(prediction);
  } catch (error) {
    res.status(500).json({ error: 'Error making pick' });
  }
});

export default router;

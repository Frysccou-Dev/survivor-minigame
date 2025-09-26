import { Request, Response } from 'express';
import { SurvivorService } from '../services/survivorService';

export class SurvivorController {
  static async getAllSurvivor(req: Request, res: Response) {
    try {
      const survivors = await SurvivorService.getAllSurvivor();
      res.json(survivors);
    } catch (err) {
      res.status(500).json({ error: 'Error fetching all survivors' });
    }
  }

  static async joinSurvivor(req: Request, res: Response) {
    try {
      const { survivorId } = req.params;
      const gamble = await SurvivorService.joinSurvivor(survivorId);
      res.json(gamble);
    } catch (err) {
      res.status(500).json({ error: 'Error joining survivor' });
    }
  }

  static async makePick(req: Request, res: Response) {
    try {
      const { survivorId, matchId } = req.params;
      const { selectedTeam } = req.body;
      const prediction = await SurvivorService.makePick(
        survivorId,
        matchId,
        selectedTeam
      );
      res.json(prediction);
    } catch (err) {
      res.status(500).json({ error: 'Error making pick' });
    }
  }

  static async calculateWinners(req: Request, res: Response) {
    try {
      const winners = await SurvivorService.calculateWinners();
      res.json(winners);
    } catch (err) {
      res.status(500).json({ error: 'Error calculating winners' });
    }
  }
}

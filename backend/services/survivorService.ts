import mongoose from 'mongoose';
import { SurvivorRepository } from '../repositories/survivorRepository';
import { GambleRepository } from '../repositories/gambleRepository';
import { PredictionRepository } from '../repositories/predictionRepository';
import { ISurvivor } from '../models/Survivor';
import { IGamble } from '../models/Gamble';
import { IPrediction } from '../models/Prediction';
import { SIMULATED_USER_ID } from '../config/user';

export class SurvivorService {
  static async getAllSurvivor(): Promise<ISurvivor[]> {
    return SurvivorRepository.findAll();
  }

  static async getSurvivorDetail(survivorId: string) {
    const objectId = new mongoose.Types.ObjectId(survivorId);

    const [survivor, gamble, predictions] = await Promise.all([
      SurvivorRepository.findById(survivorId),
      GambleRepository.findOne({
        survivorId: objectId,
        userId: SIMULATED_USER_ID,
      }),
      PredictionRepository.findAll({
        survivorId: objectId,
        userId: SIMULATED_USER_ID,
      }),
    ]);

    if (!survivor) {
      throw new Error('Survivor not found');
    }

    return {
      survivor,
      joined: Boolean(gamble),
      gamble,
      predictions: predictions.map((prediction) => ({
        id: prediction.id,
        matchId: prediction.matchId,
        selectedTeam: prediction.selectedTeam,
        result: prediction.result ?? null,
      })),
    };
  }

  static async joinSurvivor(survivorId: string): Promise<IGamble> {
    const objectId = new mongoose.Types.ObjectId(survivorId);

    const existingGamble = await GambleRepository.findOne({
      survivorId: objectId,
      userId: SIMULATED_USER_ID,
    });
    if (existingGamble) return existingGamble;

    return GambleRepository.create({
      survivorId: objectId,
      userId: SIMULATED_USER_ID,
      lives: 3,
      joinedAt: new Date(),
    });
  }

  static async makePick(
    survivorId: string,
    matchId: string,
    selectedTeam: string
  ): Promise<IPrediction> {
    const objectId = new mongoose.Types.ObjectId(survivorId);

    const existing = await PredictionRepository.findOne({
      survivorId: objectId,
      matchId,
      userId: SIMULATED_USER_ID,
    });
    if (existing) {
      if (existing.selectedTeam !== selectedTeam) {
        existing.selectedTeam = selectedTeam;
        await existing.save();
      }
      return existing;
    }

    return PredictionRepository.create({
      survivorId: objectId,
      matchId,
      userId: SIMULATED_USER_ID,
      selectedTeam,
    });
  }

  static async calculateWinners(): Promise<IGamble[]> {
    const gambles = await GambleRepository.findAll();
    if (!gambles.length) return [];

    const maxLives = Math.max(...gambles.map((g) => g.lives));
    let top = gambles.filter((g) => g.lives === maxLives);

    if (top.length === 1) return top;

    top.sort((a, b) => a.joinedAt.getTime() - b.joinedAt.getTime());
    return [top[0]];
  }
}

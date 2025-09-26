import Survivor, { ISurvivor } from '../models/Survivor';

export class SurvivorRepository {
  static async findAll(): Promise<ISurvivor[]> {
    return Survivor.find();
  }

  static async findById(id: string): Promise<ISurvivor | null> {
    return Survivor.findById(id);
  }
}

import Gamble, { IGamble } from '../models/Gamble';
import { FilterQuery } from 'mongoose';

export class GambleRepository {
  static findOne(filter: FilterQuery<IGamble>) {
    return Gamble.findOne(filter);
  }

  static findAll(filter?: FilterQuery<IGamble>) {
    return Gamble.find(filter || {});
  }

  static create(data: Partial<IGamble>) {
    return Gamble.create(data);
  }
}

import Prediction, { IPrediction } from '../models/Prediction';
import { FilterQuery } from 'mongoose';

export class PredictionRepository {
  static findOne(filter: FilterQuery<IPrediction>) {
    return Prediction.findOne(filter);
  }

  static findAll(filter?: FilterQuery<IPrediction>) {
    return Prediction.find(filter || {});
  }

  static create(data: Partial<IPrediction>) {
    return Prediction.create(data);
  }
}

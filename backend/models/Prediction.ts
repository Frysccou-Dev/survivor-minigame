import mongoose, { Document, Schema } from 'mongoose';

export interface IPrediction extends Document {
  survivorId: mongoose.Types.ObjectId;
  matchId: string;
  userId: string;
  selectedTeam: string;
  result?: 'win' | 'loss' | 'elim' | null;
}

const PredictionSchema = new Schema<IPrediction>({
  survivorId: { type: Schema.Types.ObjectId, ref: 'Survivor', required: true },
  matchId: { type: String, required: true },
  userId: { type: String, required: true },
  selectedTeam: { type: String, required: true },
  result: { type: String, enum: ['win', 'loss', 'elim', null], default: null },
});

export default mongoose.model<IPrediction>('Prediction', PredictionSchema);

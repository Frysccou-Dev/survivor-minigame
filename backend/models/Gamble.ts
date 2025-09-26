import mongoose, { Document, Schema } from 'mongoose';

export interface IGamble extends Document {
  survivorId: mongoose.Types.ObjectId;
  userId: string;
  lives: number;
  joinedAt: Date;
}

const GambleSchema = new Schema<IGamble>({
  survivorId: { type: Schema.Types.ObjectId, ref: 'Survivor', required: true },
  userId: { type: String, required: true },
  lives: { type: Number, default: 3 },
  joinedAt: { type: Date, default: () => new Date() },
});

export default mongoose.model<IGamble>('Gamble', GambleSchema);

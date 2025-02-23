const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, required: true },
  price: { type: Number, required: true },
  images: [{ type: String }],
  location: { 
    type: {
      type: String,
      enum: ['Point'], 
      required: true
    },
    coordinates: { type: [Number], required: true }
  },
  seller: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  categories: [{ type: String, required: false }],
  sold: { type: Boolean, default: false },
  chat: {type: mongoose.Schema.Types.ObjectId, ref: 'Chat'}
}, {
  timestamps: true
});

productSchema.index({ location: '2dsphere' });

const Product = mongoose.model('Product', productSchema);
module.exports = Product;

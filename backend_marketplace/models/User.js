const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  isVerified: {type: Boolean, required: true, select: false},
  verificationCode: {type: String },


  phone: { type: String },
  address: { type: String },
  avatar: { type: String },
  bio: { type: String },

  resetPasswordToken: { type: String },
  resetPasswordExpire: { type: Date },

  favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
  purchases: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
  sales: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],

  chats: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Chat' }],
  notifications: [{
    message: { type: String },
    isRead: { type: Boolean, default: false },
    createdAt: { type: Date, default: Date.now }
  }]
}, {
  timestamps: true
});

// Método para comparar contraseñas
userSchema.methods.matchPassword = async function (enteredPassword) {
  const bcrypt = require('bcryptjs');
  return await bcrypt.compare(enteredPassword, this.password);
};

const User = mongoose.model('User', userSchema);
module.exports = User;

const mongoose = require('mongoose');

const chatSchema = new mongoose.Schema({
  product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  seller: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },    
  buyer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },     
  messages: [{
    sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },  
    message: { type: String, required: true },                                     
    timestamp: { type: Date, default: Date.now }                                   
  }]
}, {
  timestamps: true
});

const Chat = mongoose.model('Chat', chatSchema);
module.exports = Chat;

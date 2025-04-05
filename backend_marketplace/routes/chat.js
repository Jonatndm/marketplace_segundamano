const express = require('express');
const mongoose = require('mongoose');
const Chat = require('../models/Chat');
const Product = require('../models/Product');
const User = require('../models/User');
const authenticateUser = require('../utils/authenticated');

const router = express.Router();

// Iniciar o obtener chat existente
router.post('/init', authenticateUser, async (req, res) => {
  try {
    const { productId } = req.body;
    const buyerId = req.user.id;
    
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    // Verificar si ya existe un chat
    let chat = await Chat.findOne({
      product: productId,
      buyer: buyerId
    })
    .populate('buyer seller product', 'name avatar title price images')
    .populate('messages.sender', 'name avatar');

    if (!chat) {
      // Crear nuevo chat
      chat = new Chat({
        product: productId,
        buyer: buyerId,
        seller: product.seller
      });
      await chat.save();
      
      // Agregar referencia a los usuarios
      await User.findByIdAndUpdate(buyerId, { $addToSet: { chats: chat._id } });
      await User.findByIdAndUpdate(product.seller, { $addToSet: { chats: chat._id } });
      
      // Volver a poblar los datos
      chat = await Chat.findById(chat._id)
        .populate('buyer seller product', 'name avatar title price images')
        .populate('messages.sender', 'name avatar');
    }

    res.json(chat);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Obtener mensajes de un chat
router.get('/:chatId/messages', authenticateUser, async (req, res) => {
  try {
    const chat = await Chat.findById(req.params.chatId)
      .populate('messages.sender', 'name avatar');
    
    if (!chat) {
      return res.status(404).json({ message: 'Chat no encontrado' });
    }
    
    // Verificar que el usuario tenga permiso para ver este chat
    if (!chat.buyer.equals(req.user.id) && !chat.seller.equals(req.user.id)) {
      return res.status(403).json({ message: 'No autorizado' });
    }
    
    res.json(chat.messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Obtener todos los chats del usuario
router.get('/user/chats', authenticateUser, async (req, res) => {
  try {
    const chats = await Chat.find({
      $or: [{ buyer: req.user.id }, { seller: req.user.id }]
    })
    .populate('buyer seller product', 'name avatar title price images')
    .populate({
      path: 'messages',
      options: { sort: { createdAt: -1 }, limit: 1 },
      populate: { path: 'sender', select: 'name avatar' }
    })
    .sort({ lastMessage: -1 });
    
    res.json(chats);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Marcar mensajes como leídos (para cuando se abre el chat)
router.post('/:chatId/read', authenticateUser, async (req, res) => {
  try {
    const result = await Chat.updateOne(
      { 
        _id: req.params.chatId,
        'messages.sender': { $ne: req.user.id } 
      },
      { $set: { 'messages.$[elem].read': true } },
      { arrayFilters: [{ 'elem.read': false }] }
    );
    
    res.json({ 
      success: true,
      modifiedCount: result.modifiedCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
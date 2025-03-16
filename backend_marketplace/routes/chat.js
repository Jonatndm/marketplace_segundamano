const express = require('express');
const Chat = require('../models/Chat');
const authenticateUser = require('../utils/authenticated');

const router = express.Router();

// Obtener los mensajes de un producto específico
router.get('/:productId', authenticateUser, async (req, res) => {
  try {
    const chat = await Chat.findOne({ product: req.params.productId })
      .populate('messages.sender', 'name avatar')
      .populate('seller', 'name')
      .populate('buyer', 'name');

    if (!chat) {
      return res.status(404).json({ message: 'No se encontraron mensajes para este producto' });
    }

    res.json(chat.messages);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mensajes', error: error.message });
  }
});

// Enviar un mensaje en un chat
router.post('/:productId', authenticateUser, async (req, res) => {
  try {
    const { message } = req.body;
    const userId = req.user.id;
    const productId = req.params.productId;

    let chat = await Chat.findOne({ product: productId });

    if (!chat) {
      chat = new Chat({
        product: productId,
        seller: req.user.id, 
        buyer: userId,
        messages: [],
      });
    }

    const newMessage = { sender: userId, message, timestamp: new Date() };
    chat.messages.push(newMessage);
    await chat.save();

    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ message: 'Error al enviar mensaje', error: error.message });
  }
});

module.exports = router;
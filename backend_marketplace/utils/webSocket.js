const socketIo = require('socket.io');
const Chat = require('../models/Chat');
const User = require('../models/User');
const jwt = require('jsonwebtoken');

let clients = {}; // Almacena los clientes conectados, por usuario

function setupWebSocket(server) {
  const io = socketIo(server, {
    cors: {
      origin: "*", // Ajusta según tu cliente Flutter
      methods: ["GET", "POST"]
    }
  });
  
  // Middleware de autenticación para Socket.io
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('No autenticado'));
      }
      
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.id);
      
      if (!user) {
        return next(new Error('Usuario no encontrado'));
      }
      
      // Guardar información del usuario en el socket
      socket.userId = user._id.toString();
      socket.user = user;
      
      // Registrar cliente conectado
      clients[user._id] = socket.id;
      
      next();
    } catch (error) {
      next(new Error('Autenticación fallida'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`Cliente conectado: ${socket.user.name} (${socket.userId})`);
    
    // Manejar errores de autenticación
    socket.on('error', (err) => {
      console.error('Error de socket:', err.message);
      socket.disconnect();
    });
    
    // Unirse a las salas de chat del usuario
    socket.on('joinChats', async () => {
      try {
        const user = await User.findById(socket.userId).populate('chats');
        user.chats.forEach(chat => {
          socket.join(chat._id.toString());
          console.log(`Usuario ${socket.user.name} unido al chat ${chat._id}`);
        });
      } catch (error) {
        console.error('Error al unirse a chats:', error);
      }
    });
    
    // Unirse a una sala de chat específica
    socket.on('joinChat', (chatId) => {
      socket.join(chatId);
      console.log(`Usuario ${socket.user.name} unido al chat ${chatId}`);
    });
    
    // Manejar mensajes
    socket.on('sendMessage', async (data) => {
      try {
        const { chatId, content } = data;
        
        // Validar datos
        if (!chatId || !content || content.trim() === '') {
          throw new Error('Datos inválidos');
        }
        
        // Guardar en la base de datos
        const chat = await Chat.findByIdAndUpdate(
          chatId,
          {
            $push: {
              messages: {
                sender: socket.userId,
                content: content.trim()
              }
            }
          },
          { new: true }
        )
        .populate('messages.sender', 'name avatar')
        .populate('buyer seller', 'name avatar');
        
        if (!chat) {
          throw new Error('Chat no encontrado');
        }
        
        const message = chat.messages[chat.messages.length - 1];
        
        // Construir respuesta enriquecida
        const response = {
          ...message.toObject(),
          chatId: chat._id,
          product: chat.product,
          buyer: chat.buyer,
          seller: chat.seller
        };
        
        // Emitir a todos en la sala
        io.to(chatId).emit('newMessage', response);
        
        // Notificar a los usuarios sobre actualización de lista de chats
        if (clients[chat.buyer._id]) {
          io.to(clients[chat.buyer._id]).emit('chatUpdated', chat);
        }
        if (clients[chat.seller._id]) {
          io.to(clients[chat.seller._id]).emit('chatUpdated', chat);
        }
        
      } catch (error) {
        console.error('Error al enviar mensaje:', error);
        socket.emit('messageError', { message: error.message });
      }
    });
    
    // Marcar mensajes como leídos
    socket.on('markAsRead', async (data) => {
      try {
        const { chatId } = data;
        
        const result = await Chat.updateOne(
          { 
            _id: chatId,
            'messages.sender': { $ne: socket.userId } 
          },
          { $set: { 'messages.$[elem].read': true } },
          { arrayFilters: [{ 'elem.read': false }] }
        );
        
        if (result.modifiedCount > 0) {
          // Notificar al otro usuario que los mensajes fueron leídos
          socket.to(chatId).emit('messagesRead', { chatId });
          
          // Actualizar lista de chats
          const chat = await Chat.findById(chatId)
            .populate('buyer seller', 'name avatar');
            
          if (chat) {
            if (clients[chat.buyer._id]) {
              io.to(clients[chat.buyer._id]).emit('chatUpdated', chat);
            }
            if (clients[chat.seller._id]) {
              io.to(clients[chat.seller._id]).emit('chatUpdated', chat);
            }
          }
        }
        
      } catch (error) {
        console.error('Error al marcar como leído:', error);
      }
    });
    
    // Manejar desconexión
    socket.on('disconnect', () => {
      console.log(`Cliente desconectado: ${socket.user.name}`);
      delete clients[socket.userId];
    });
  });
}

module.exports = setupWebSocket;
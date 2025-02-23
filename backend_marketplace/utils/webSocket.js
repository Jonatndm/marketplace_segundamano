const socketIo = require('socket.io');
const Product = require('../models/Product');

let clients = {}; // Almacena los clientes conectados, por usuario
// Función para configurar WebSocket con socket.io
function setupWebSocket(server) {
  const io = socketIo(server, {
    cors: {
      origin: "*", // Permite conexiones desde cualquier origen (ajusta según tus necesidades)
      methods: ["GET", "POST"] // Métodos HTTP permitidos
    }
  });

  // Manejo de conexiones WebSocket
  io.on('connection', (socket) => {
    console.log('nuevo cliente conectad', socket.Id);
    let userId = null;

    // Al recibir un mensaje del cliente
    socket.on('authenticate', (data) => {
      // Autenticación: se asocia el userId al socket
      console.log(data);
      userId = data.userId;
      clients[userId] = socket; // Guardamos la conexión socket asociada al usuario
    });

    // Manejo de mensajes de chat
    socket.on('chat', async (data) => {
      console.log(data);
      const { productId, text } = data;

      // Buscar el producto y agregar el mensaje al chat
      const product = await Product.findById(productId);
      if (product) {
        product.chat.push({ sender: userId, message: text });
        await product.save();

        // Enviar el mensaje solo al vendedor y al comprador interesado
        const sellerSocket = clients[product.seller]; // Conexión del vendedor
        const buyerSocket = clients[userId]; // Conexión del comprador

        if (sellerSocket) {
          sellerSocket.emit('chat', {
            productId,
            message: { sender: userId, text }
          });
        }

        if (buyerSocket) {
          buyerSocket.emit('chat', {
            productId,
            message: { sender: userId, text }
          });
        }
      }
    });

    // Manejo de cierre de conexión
    socket.on('disconnect', () => {
      if (userId) {
        delete clients[userId]; // Eliminar cliente desconectado
      }
    });
  });
}

module.exports = setupWebSocket;
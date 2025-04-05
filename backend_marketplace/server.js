const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const cors = require('cors');
const setupWebSocket = require('./utils/webSocket'); 
const dotenv = require('dotenv');
const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const profileroutes = require('./routes/profile');
const chatRoutes = require('./routes/chat');
const path = require('path');


dotenv.config();
const app = express();

app.use(cors());
// Crear el servidor HTTP
const server = http.createServer(app);
setupWebSocket(server);

// Middleware para leer JSON
app.use(express.json());

// Rutas para autenticación y productos
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/profile', profileroutes);
app.use('/api/chat', chatRoutes);
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));


// Conectar a MongoDB
mongoose.connect(process.env.MONGO_URI, {
})
  .then(() => console.log("Conectado a MongoDB"))
  .catch((err) => console.log("Error al conectar a MongoDB: ", err));

// Puerto donde correrá el servidor
const PORT = process.env.PORT || 5000;

// Iniciar el servidor HTTP (con WebSocket)
server.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});

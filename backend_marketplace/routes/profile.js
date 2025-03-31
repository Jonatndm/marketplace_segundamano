const express = require('express');
const User = require('../models/User');
const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const authenticateUser = require('../utils/authenticated');
const router = express.Router();
const dotenv = require('dotenv');

dotenv.config();


cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.API_KEY,
  api_secret: process.env.API_SECRET_KEY
});

// Configuración de Multer para subir imágenes
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'products', // Carpeta en Cloudinary donde se guardarán las imágenes
    allowed_formats: ['jpg', 'jpeg', 'png'], // Formatos permitidos
    transformation: [{ width: 500, height: 500, crop: 'limit' }] // Transformaciones opcionales
  }
});

const upload = multer({
  storage,
});

// Actualización de perfil
router.put('/:userId', authenticateUser, upload.single('avatar'), async (req, res) => {
  const { userId } = req.params;
  const { name, phone, address, bio } = req.body;

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    // Actualizar campos básicos
    user.name = name;
    if (phone) user.phone = phone;
    if (address) user.address = address;
    if (bio) user.bio = bio;
    // Subir nueva imagen de perfil a Cloudinary si se proporciona
    console.log(req.file);
    if (req.file) {
      try {
        // Eliminar la imagen anterior de Cloudinary (opcional)
        if (user.avatar) {
          const publicId = user.avatar.split('/').pop().split('.')[0]; // Extraer el public_id de la URL
          await cloudinary.uploader.destroy(publicId);
        }
        // Subir la nueva imagen
        const result = await cloudinary.uploader.upload(req.file.path, {
          folder: 'avatars', // Carpeta en Cloudinary
          transformation: [{ width: 500, height: 500, crop: 'limit' }], // Transformaciones opcionales
        });
        user.avatar = result.secure_url; // Actualizar la URL de la imagen en el usuario
      } catch (error) {
        console.error('Error al subir la imagen a Cloudinary:', error.message);
        return res.status(500).json({ message: 'Error al subir la imagen de perfil' });
      }
    }
    // Guardar los cambios en la base de datos
    await user.save();

    res.status(200).json({ message: 'Perfil actualizado correctamente', user });
  } catch (error) {
    console.error('Error al actualizar el perfil:', error.message);
    res.status(500).json({ message: 'Error al actualizar el perfil', error: error.message });
  }
});

router.get('/:userId', authenticateUser, async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    let newUser = {
      _id: user._id,
      name: user.name,
      avatar: user.avatar ?? null,
      chats: user.chats,
      favoritesSales: user.favorites,
      salesPublish: user.sales,
      phone: user.phone ?? null,
      address: user.address ?? null,
      bio: user.bio ?? null,
      purchases: user.purchases
    };
    res.status(200).json({ newUser });
  }
  catch (error) {
    res.status(500).json({ message: 'Error al buscar el perfil', error });
  }
});

module.exports = router;

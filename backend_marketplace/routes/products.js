const express = require('express');
const multer = require('multer');
const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const Product = require('../models/Product');
const User = require('../models/User');
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
  limits: { fileSize: 5 * 1024 * 1024 }, // Límite de 5MB por imagen
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    cb(allowedTypes.includes(file.mimetype) ? null : new Error('Tipo de archivo no permitido'), allowedTypes.includes(file.mimetype));
  }
});

// Crear un producto
router.post('/', authenticateUser, upload.array('images', 5), async (req, res) => {
  const { name, description, price, latitude, longitude, categories } = req.body;

  if (!name || !description || !price || !latitude || !longitude) {
    return res.status(400).json({ message: 'Faltan campos requeridos' });
  }


  try {
    // Subir imágenes a Cloudinary y obtener sus URLs
    const images = await Promise.all(
      req.files.map(async (file) => {
        const result = await cloudinary.uploader.upload(file.path);
        return result.secure_url; // URL de la imagen en Cloudinary
      })
    );


    const product = new Product({
      name,
      description,
      price: parseFloat(price),
      images,
      location: { type: 'Point', coordinates: [parseFloat(longitude), parseFloat(latitude)] },
      categories: categories ? categories.split(',').map(cat => cat.trim()) : [],
      seller: req.user.id
    });

    await product.save();
    res.status(201).json({ message: 'Producto creado correctamente', product });
  } catch (error) {
    console.error('Error al crear producto:', error.message);
    res.status(500).json({ message: 'Error al crear el producto', error: error.message });
  }
});

// Obtener productos cercanos a una ubicación
router.get('/nearby', async (req, res) => {
  const { latitude, longitude, maxDistance = 5000 } = req.query;

  if (!latitude || !longitude) {
    return res.status(400).json({ message: 'Latitud y longitud son requeridas' });
  }

  try {
    const products = await Product.find({
      location: {
        $near: {
          $geometry: { type: 'Point', coordinates: [parseFloat(longitude), parseFloat(latitude)] },
          $maxDistance: parseInt(maxDistance)
        }
      }
    });

    res.json({ products });
  } catch (error) {
    console.error('Error al obtener productos cercanos:', error.message);
    res.status(500).json({ message: 'Error al obtener productos cercanos', error: error.message });
  }
});

// Obtener todos los productos
router.get('/', async (req, res) => {
  try {
    const products = await Product.find().populate('seller', 'name email');
    res.json({ products });
  } catch (error) {
    console.error('Error al obtener productos:', error.message);
    res.status(500).json({ message: 'Error al obtener productos', error: error.message });
  }
});

// Actualizar producto
router.put('/:id', authenticateUser, upload.array('images', 5), async (req, res) => {
  const { name, description, price, categories } = req.body;
  const images = req.files?.map(file => file.path) ?? [];

  try {
    const product = await Product.findById(req.params.id);

    if (!product) return res.status(404).json({ message: 'Producto no encontrado' });
    if (product.seller.toString() !== req.user.id) return res.status(403).json({ message: 'No tienes permiso para actualizar este producto' });

    product.name = name ?? product.name;
    product.description = description ?? product.description;
    product.price = price ? parseFloat(price) : product.price;
    if (categories) product.categories = categories.split(',').map(cat => cat.trim());
    if (images.length) product.images = images;

    await product.save();
    res.json({ message: 'Producto actualizado', product });
  } catch (error) {
    console.error('Error al actualizar el producto:', error.message);
    res.status(500).json({ message: 'Error al actualizar el producto', error: error.message });
  }
});

// Eliminar producto
router.delete('/:id', authenticateUser, async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) return res.status(404).json({ message: 'Producto no encontrado' });
    if (product.seller.toString() !== req.user.id) return res.status(403).json({ message: 'No tienes permiso para eliminar este producto' });

    await product.deleteOne();
    res.json({ message: 'Producto eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar el producto:', error.message);
    res.status(500).json({ message: 'Error al eliminar el producto', error: error.message });
  }
});

router.get('/seller/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user)
      return res.status(404).json({ message: 'Vendedor no encontrado' });

    res.json({ user });
  }
  catch (error) {
    console.error('Error al obtener vendedor ', error.message);
    res.status(500).json({ message: 'Error al obtener vendedor', error: error.message });
  }
})

router.get('/user/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    // Buscar productos donde el campo "seller" coincida con el userId
    const products = await Product.find({ seller: userId }).populate('seller', 'name email');

    if (!products || products.length === 0) {
      return res.status(404).json({ message: 'No se encontraron productos para este usuario' });
    }

    res.json({ products });
  } catch (error) {
    console.error('Error al obtener productos por usuario:', error.message);
    res.status(500).json({ message: 'Error al obtener productos por usuario', error: error.message });
  }
});

router.put('/:id/sold', authenticateUser, async (req, res) => {
  try {
    const productId = req.params.id;
    const userId = req.user.id; // ID del usuario autenticado

    // Buscar el producto por ID
    const product = await Product.findById(productId);

    if (!product) {
      return res.status(404).json({ message: 'Producto no encontrado' });
    }

    // Verificar si el usuario autenticado es el vendedor del producto
    if (product.seller.toString() !== userId) {
      return res.status(403).json({ message: 'No tienes permiso para marcar este producto como vendido' });
    }

    // Marcar el producto como vendido
    product.sold = true;
    await product.save();

    res.json({ message: 'Producto marcado como vendido', product });
  } catch (error) {
    console.error('Error al marcar el producto como vendido:', error.message);
    res.status(500).json({ message: 'Error al marcar el producto como vendido', error: error.message });
  }
});


module.exports = router;

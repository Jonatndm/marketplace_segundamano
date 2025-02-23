const express = require('express');
const multer = require('multer');
const Product = require('../models/Product');
const User = require('../models/User');
const authenticateUser = require('../utils/authenticated');
const router = express.Router();

// Configuración de Multer para subir imágenes
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`)
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limite de 5MB por imagen
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

  const images = req.files?.map(file => file.path) ?? [];

  try {
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
  try{
    const user = await User.findById(req.params.id);

    if(!user) 
        return res.status(404).json({ message: 'Vendedor no encontrado' });

    res.json({ user });
  }
  catch (error) {
    console.error('Error al obtener vendedor ', error.message);
    res.status(500).json({ message: 'Error al obtener vendedor', error: error.message });
  }
})

module.exports = router;

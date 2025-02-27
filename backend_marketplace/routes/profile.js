const express = require('express');
const User = require('../models/User');
const authenticateUser = require('../utils/authenticated');
const router = express.Router();

// Actualización de perfil
router.put('/:userId', authenticateUser, async (req, res) => {
  const { userId } = req.params;
  const { phone, address, avatar, bio } = req.body;

  try {
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    if (phone) user.phone = phone;
    if (address) user.address = address;
    if (avatar) user.avatar = avatar;
    if (bio) user.bio = bio;

    await user.save();

    res.status(200).json({ message: 'Perfil actualizado correctamente', user });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar el perfil', error });
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
      id: user._id,
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

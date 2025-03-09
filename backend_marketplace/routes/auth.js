const express = require('express');
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const sgMail = require('@sendgrid/mail');
const bcrypt = require('bcryptjs');
const router = express.Router();

// Generar un código de 6 dígitos
const generateResetCode = () => {
  return Math.floor(100000 + Math.random() * 900000).toString(); // Código de 6 dígitos
};

// Registro de usuario
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;

  try {
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({ message: 'El correo ya está registrado' });
    }

    // Generar código de verificación
    const verificationCode = generateResetCode();
    
    const user = new User({
      name,
      email,
      password,
      isVerified: false,
      verificationCode,
    });

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);
    await user.save();
    // Enviar código por correo
    sgMail.setApiKey(process.env.SENDGRID_API_KEY);
    const mailOptions = {
      to: email,
      from: process.env.EMAIL_USER,
      subject: 'Código de verificación',
      text: `Tu código de verificación es: ${verificationCode}`,
    };
    await sgMail.send(mailOptions);

    res.status(201).json({ message: 'Usuario registrado. Verifica tu correo.' });
  } catch (error) {
    res.status(500).json({ message: 'Error en el registro', error });
  }
});


// Inicio de sesión
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user || !(await user.matchPassword(password))) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, userId: user.id });
  } catch (error) {
    res.status(500).json({ message: 'Error al iniciar sesión', error });
  }
});

// Enviar correo de recuperación de contraseña con código
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    // Generar un código de 6 dígitos
    const resetCode = generateResetCode();
    user.resetPasswordToken = resetCode;
    user.resetPasswordExpire = Date.now() + 3600000; // 1 hora de validez
    await user.save();

    // Configurar el correo
    sgMail.setApiKey(process.env.SENDGRID_API_KEY);
    const mailOptions = {
      to: user.email,
      from: process.env.EMAIL_USER, // Configurar en variables de entorno
      subject: 'Código de recuperación de contraseña',
      text: `Tu código de recuperación es: ${resetCode}\n\nEste código expirará en 1 hora.`,
    };

    // Enviar el correo
    await sgMail.send(mailOptions);
    res.json({ message: 'Se ha enviado un código de recuperación' });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error });
  }
});

// Verificar el código de recuperación
router.post('/verify-reset-code', async (req, res) => {
  const { email, code } = req.body;

  try {
    const user = await User.findOne({
      email,
      resetPasswordToken: code,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'Código inválido o expirado' });
    }

    res.json({ message: 'Código válido' });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error });
  }
});

// Restablecer contraseña
router.post('/reset-password', async (req, res) => {
  const { email, code, newPassword } = req.body;

  try {
    const user = await User.findOne({
      email,
      resetPasswordToken: code,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ message: 'Código inválido o expirado' });
    }
    // Actualizar la contraseña
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    res.json({ message: 'Contraseña actualizada correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error en el servidor', error });
  }
});

// Verificación del código
router.post('/verify-code', async (req, res) => {
  const { email, code } = req.body;

  try {
    const user = await User.findOne({ email, verificationCode: code });
    if (!user) {
      return res.status(400).json({ message: 'Código incorrecto o expirado' });
    }

    user.isVerified = true;
    user.verificationCode = undefined;
    await user.save();

    // Generar token
    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ token, userId: user._id, message: 'Cuenta verificada' });
  } catch (error) {
    res.status(500).json({ message: 'Error en la verificación', error });
  }
});

module.exports = router;

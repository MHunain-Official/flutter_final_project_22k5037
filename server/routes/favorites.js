const express = require('express');
const pool = require('../db/postgres');
const { requireAuth } = require('../middleware/auth');
const { invalidate, getOrCache } = require('../db/redis');
require('dotenv').config();

const router = express.Router();
// All favorites routes require a valid JWT
router.use(requireAuth);

// GET /api/favorites  — list current user's favorites
router.get('/', async (req, res) => {
  const cacheKey = `favorites:${req.userId}`;
  try {
    const data = await getOrCache(cacheKey, 60, async () => {
      const { rows } = await pool.query(
        'SELECT place_id, place_title, place_thumbnail_url, place_url, added_at FROM favorites WHERE user_id = $1 ORDER BY added_at DESC',
        [req.userId]
      );
      return rows;
    });
    res.json(data);
  } catch (err) {
    console.error('Favorites get error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// POST /api/favorites  — add a place to favorites
router.post('/', async (req, res) => {
  const { placeId, placeTitle, placeThumbnailUrl, placeUrl } = req.body;
  if (!placeId || !placeTitle) {
    return res.status(400).json({ error: 'placeId and placeTitle are required' });
  }

  try {
    const { rows } = await pool.query(
      `INSERT INTO favorites (user_id, place_id, place_title, place_thumbnail_url, place_url)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (user_id, place_id) DO NOTHING
       RETURNING *`,
      [req.userId, placeId, placeTitle, placeThumbnailUrl || null, placeUrl || null]
    );
    // Invalidate cache so next GET is fresh
    await invalidate(`favorites:${req.userId}`);
    res.status(201).json(rows[0] || { message: 'Already in favorites' });
  } catch (err) {
    console.error('Favorites add error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// DELETE /api/favorites/:placeId  — remove from favorites
router.delete('/:placeId', async (req, res) => {
  const placeId = parseInt(req.params.placeId, 10);
  if (isNaN(placeId)) return res.status(400).json({ error: 'Invalid placeId' });

  try {
    await pool.query(
      'DELETE FROM favorites WHERE user_id = $1 AND place_id = $2',
      [req.userId, placeId]
    );
    await invalidate(`favorites:${req.userId}`);
    res.json({ message: 'Removed from favorites' });
  } catch (err) {
    console.error('Favorites delete error:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

const express = require('express');
const https = require('https');
const { getOrCache } = require('../db/redis');
require('dotenv').config();

// JSONPlaceholder points at via.placeholder.com images that often fail — use stable Picsum seeds.
function reliablePhotoUrls(p) {
  const id = p.id;
  return {
    ...p,
    thumbnailUrl: `https://picsum.photos/seed/stravel${id}/240/200`,
    url: `https://picsum.photos/seed/stravel${id}/800/520`,
  };
}

const router = express.Router();
const CACHE_TTL = parseInt(process.env.CACHE_TTL, 10) || 300;

// Fetch JSON from a URL using built-in https (no extra deps)
function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try { resolve(JSON.parse(data)); }
        catch (e) { reject(new Error('Invalid JSON')); }
      });
    }).on('error', reject);
  });
}

// GET /api/places?page=1&limit=20&search=lake
router.get('/', async (req, res) => {
  const page = Math.max(1, parseInt(req.query.page, 10) || 1);
  const limit = Math.min(50, parseInt(req.query.limit, 10) || 20);
  const search = (req.query.search || '').toLowerCase().trim();

  try {
    // All 5000 photos cached in Redis for 5 min
    const all = await getOrCache('places:all', CACHE_TTL, () =>
      fetchJson('https://jsonplaceholder.typicode.com/photos')
    );

    // Filter and paginate
    const filtered = search
      ? all.filter((p) => p.title.toLowerCase().includes(search))
      : all;

    const start = (page - 1) * limit;
    const items = filtered.slice(start, start + limit).map(reliablePhotoUrls);

    res.json({
      data: items,
      total: filtered.length,
      page,
      limit,
      hasMore: start + limit < filtered.length,
    });
  } catch (err) {
    console.error('Places list error:', err.message);
    res.status(502).json({ error: 'Failed to fetch places' });
  }
});

// GET /api/places/:id
router.get('/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) return res.status(400).json({ error: 'Invalid id' });

  try {
    const place = await getOrCache(`place:${id}`, CACHE_TTL, async () => {
      const p = await fetchJson(`https://jsonplaceholder.typicode.com/photos/${id}`);
      return reliablePhotoUrls(p);
    });
    res.json(place);
  } catch (err) {
    console.error('Place detail error:', err.message);
    res.status(502).json({ error: 'Failed to fetch place' });
  }
});

// GET /api/places/weather?lat=...&lon=...
router.get('/weather/current', async (req, res) => {
  const { lat, lon } = req.query;
  if (!lat || !lon) return res.status(400).json({ error: 'lat and lon are required' });

  const cacheKey = `weather:${parseFloat(lat).toFixed(2)}:${parseFloat(lon).toFixed(2)}`;
  try {
    const data = await getOrCache(cacheKey, 600, () =>
      fetchJson(
        `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}` +
        `&current=temperature_2m,weathercode,windspeed_10m,relativehumidity_2m,apparent_temperature` +
        `&timezone=auto`
      )
    );
    res.json(data);
  } catch (err) {
    console.error('Weather error:', err.message);
    res.status(502).json({ error: 'Failed to fetch weather' });
  }
});

module.exports = router;

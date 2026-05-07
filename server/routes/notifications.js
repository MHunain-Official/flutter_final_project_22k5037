const express = require('express');
const pool = require('../db/postgres');
const { requireAuth } = require('../middleware/auth');
const { getOrCache, invalidate } = require('../db/redis');
const { LIST_KEY } = require('../services/notificationsLogic');

const router = express.Router();
router.use(requireAuth);

const LIST_TTL = parseInt(process.env.NOTIFICATIONS_CACHE_TTL, 10) || 45;

// GET /api/notifications — list for current user (respects type visibility at insert time only; list shows all rows)
router.get('/', async (req, res) => {
  const uid = String(req.userId);
  const cacheKey = LIST_KEY(uid);
  try {
    const rows = await getOrCache(cacheKey, LIST_TTL, async () => {
      const { rows: r } = await pool.query(
        `SELECT n.id, n.type_code, n.title, n.body, n.read_at, n.created_at
         FROM notifications n
         WHERE n.user_id = $1
           AND COALESCE(
             (SELECT p.enabled FROM user_notification_preferences p
              WHERE p.user_id = n.user_id AND p.type_code = n.type_code),
             (SELECT t.default_enabled FROM notification_types t WHERE t.code = n.type_code),
             FALSE
           ) = TRUE
         ORDER BY n.created_at DESC
         LIMIT 100`,
        [uid]
      );
      return r;
    });
    res.json(rows);
  } catch (err) {
    if (err.code === '42P01') {
      return res.json([]);
    }
    console.error('notifications list:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// PATCH /api/notifications/:id/read
router.patch('/:id/read', async (req, res) => {
  const uid = String(req.userId);
  const { id } = req.params;
  try {
    const { rows } = await pool.query(
      `UPDATE notifications SET read_at = NOW()
       WHERE id = $1::uuid AND user_id = $2
       RETURNING id, type_code, title, body, read_at, created_at`,
      [id, uid]
    );
    if (!rows[0]) return res.status(404).json({ error: 'Not found' });
    await invalidate(LIST_KEY(uid));
    res.json(rows[0]);
  } catch (err) {
    console.error('notifications read:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// GET /api/notifications/preferences
router.get('/preferences', async (req, res) => {
  const uid = String(req.userId);
  try {
    const { rows: types } = await pool.query(
      'SELECT code, label, default_enabled FROM notification_types ORDER BY code'
    );
    const { rows: prefs } = await pool.query(
      'SELECT type_code, enabled FROM user_notification_preferences WHERE user_id = $1',
      [uid]
    );
    const prefMap = Object.fromEntries(prefs.map((p) => [p.type_code, p.enabled]));
    res.json(
      types.map((t) => ({
        type_code: t.code,
        label: t.label,
        effective_enabled: prefMap[t.code] !== undefined ? prefMap[t.code] : t.default_enabled,
        default_enabled: t.default_enabled,
      }))
    );
  } catch (err) {
    if (err.code === '42P01') return res.json([]);
    console.error('notifications preferences get:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

// PUT /api/notifications/preferences  { "type_code": "login", "enabled": false }
router.put('/preferences', async (req, res) => {
  const uid = String(req.userId);
  const { type_code: typeCode, enabled } = req.body;
  if (typeCode === undefined || typeof enabled !== 'boolean') {
    return res.status(400).json({ error: 'type_code and enabled (boolean) are required' });
  }
  try {
    const { rows: t } = await pool.query('SELECT code FROM notification_types WHERE code = $1', [typeCode]);
    if (!t[0]) return res.status(400).json({ error: 'Unknown type_code' });

    await pool.query(
      `INSERT INTO user_notification_preferences (user_id, type_code, enabled)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, type_code) DO UPDATE SET enabled = EXCLUDED.enabled`,
      [uid, typeCode, enabled]
    );
    await invalidate(LIST_KEY(uid));
    res.json({ type_code: typeCode, enabled });
  } catch (err) {
    console.error('notifications preferences put:', err.message);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

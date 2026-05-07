const pool = require('../db/postgres');
const { invalidate } = require('../db/redis');

const LIST_KEY = (userId) => `notifications:list:${userId}`;
const ME_KEY = (userId) => `user:me:${userId}`;

async function isTypeEnabled(userId, typeCode) {
  const uid = String(userId);
  const { rows } = await pool.query(
    `SELECT COALESCE(
       (SELECT p.enabled FROM user_notification_preferences p
        WHERE p.user_id = $1 AND p.type_code = $2),
       (SELECT t.default_enabled FROM notification_types t WHERE t.code = $2),
       FALSE
     ) AS ok`,
    [uid, typeCode]
  );
  return !!rows[0]?.ok;
}

async function insertNotification(userId, typeCode, title, body) {
  const uid = String(userId);
  const ok = await isTypeEnabled(uid, typeCode);
  if (!ok) return null;

  const { rows } = await pool.query(
    `INSERT INTO notifications (user_id, type_code, title, body)
     VALUES ($1, $2, $3, $4)
     RETURNING id, user_id, type_code, title, body, read_at, created_at`,
    [uid, typeCode, title, body]
  );
  await invalidate(LIST_KEY(uid));
  return rows[0];
}

async function notifyLogin(userId, userName) {
  try {
    return await insertNotification(
      userId,
      'login',
      'New sign-in',
      userName
        ? `Hello ${userName}, we recorded a successful login to your account.`
        : 'We recorded a successful login to your account.'
    );
  } catch (e) {
    if (e.code === '42P01') console.warn('notifications: tables missing, run server/db/schema_notifications.sql');
    else console.warn('notifyLogin:', e.message);
    return null;
  }
}

async function notifyWelcome(userId, name) {
  try {
    return await insertNotification(
      userId,
      'welcome',
      'Welcome to Smart Travel',
      name ? `Hi ${name}, your account is ready. Explore places and save favorites.` : 'Your account is ready.'
    );
  } catch (e) {
    if (e.code === '42P01') console.warn('notifications: tables missing');
    else console.warn('notifyWelcome:', e.message);
    return null;
  }
}

async function invalidateMeCache(userId) {
  try {
    await invalidate(ME_KEY(String(userId)));
  } catch (_) {
    /* redis optional */
  }
}

module.exports = {
  isTypeEnabled,
  insertNotification,
  notifyLogin,
  notifyWelcome,
  LIST_KEY,
  ME_KEY,
  invalidateMeCache,
};

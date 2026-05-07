const { createClient } = require('redis');
require('dotenv').config();

const redisClient = createClient({ url: process.env.REDIS_URL });

redisClient.on('error', (err) => console.error('Redis error:', err.message));

// Connect once at startup
(async () => {
  await redisClient.connect();
  console.log('Redis connected');
})();

// Helper: get cached JSON or fetch+store it
async function getOrCache(key, ttlSeconds, fetchFn) {
  const cached = await redisClient.get(key);
  if (cached) return JSON.parse(cached);

  const fresh = await fetchFn();
  await redisClient.setEx(key, ttlSeconds, JSON.stringify(fresh));
  return fresh;
}

// Invalidate a specific key (e.g., after favorites change)
async function invalidate(key) {
  await redisClient.del(key);
}

module.exports = { redisClient, getOrCache, invalidate };

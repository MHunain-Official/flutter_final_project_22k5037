# Setup Guide — Smart Travel Companion

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Flutter | ≥ 3.24 | https://flutter.dev/docs/get-started/install |
| Node.js | ≥ 18 | https://nodejs.org |
| PostgreSQL | ≥ 14 | https://www.postgresql.org/download |
| Redis | ≥ 6 | https://redis.io/docs/install |

---

## 1. Database Setup

Start PostgreSQL, then run:

```bash
psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE travel_companion;"

psql -U postgres -h 127.0.0.1 -d travel_companion -c "
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name         TEXT NOT NULL,
  email        TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  avatar_url   TEXT,
  created_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS favorites (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id            INTEGER NOT NULL,
  place_title         TEXT NOT NULL,
  place_thumbnail_url TEXT,
  place_url           TEXT,
  added_at            TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, place_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
"
```

---

## 2. Backend Server

```bash
cd server
npm install
```

Edit `server/.env` if your PostgreSQL password differs:

```
PORT=3000
PG_HOST=127.0.0.1
PG_PORT=5432
PG_USER=postgres
PG_PASSWORD=karachi@123
PG_DATABASE=travel_companion
REDIS_URL=redis://127.0.0.1:6379
JWT_SECRET=super_secret_jwt_key_change_me
```

Start the server:

```bash
node server.js
# or with auto-restart:
npx nodemon server.js
```

Verify: `curl http://localhost:3000/health` → `{"status":"ok"}`

---

## 3. Flutter App

Install dependencies:

```bash
flutter pub get
```

### Running on an Android Emulator

The emulator reaches your host machine via the special address `10.0.2.2`.  
`ApiEndpoints.baseUrl` in `lib/core/constants/api_endpoints.dart` is already set to `http://10.0.2.2:3000`.

```bash
flutter run
```

### Running on a Physical Device

Change `baseUrl` to your machine's local IP address (e.g. `http://192.168.1.5:3000`).

### Building a Release APK

```bash
flutter build apk --release
```

---

## 4. Running Tests

```bash
flutter test
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `Connection refused` on emulator | Ensure the backend server is running and `baseUrl` is `http://10.0.2.2:3000` |
| `password authentication failed` | Verify `PG_PASSWORD` in `server/.env` matches your PostgreSQL password |
| Redis `ECONNREFUSED` | Start Redis: `sudo systemctl start redis` or `redis-server` |
| `flutter pub get` fails | Run `flutter doctor` and follow the reported fixes |

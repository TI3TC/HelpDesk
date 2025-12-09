const express = require('express');
const cookieParser = require('cookie-parser');
const { createRemoteJWKSet, jwtVerify } = require('jose');
const { nanoid } = require('nanoid');

const PORT = process.env.PORT || 4010; // <<< porta nova

// seus GUIDs
const TENANT_ID = process.env.MS_TENANT_ID || 'a2f44e6b-598b-4d56-8e01-c63c72e21c10';
const CLIENT_ID = process.env.MS_CLIENT_ID || 'd6881117-d053-4933-a5e2-b13532f2af95';

const app = express();
app.use(express.json());
app.use(cookieParser());

const sessions = new Map();

const jwks = createRemoteJWKSet(new URL(`https://login.microsoftonline.com/${TENANT_ID}/discovery/v2.0/keys`));
const expectedIssuer = `https://login.microsoftonline.com/${TENANT_ID}/v2.0`;

app.get('/health', (_, res) => res.json({ ok: true }));

app.post('/auth/microsoft', async (req, res) => {
  try {
    const { idToken } = req.body || {};
    if (!idToken) return res.status(400).json({ error: 'idToken ausente' });

    const { payload } = await jwtVerify(idToken, jwks, {
      issuer: expectedIssuer,
      audience: CLIENT_ID,
    });

    const user = {
      sub: payload.sub,
      name: payload.name,
      email: payload.preferred_username || payload.email,
      oid: payload.oid,
      tid: payload.tid,
    };

    const sid = nanoid();
    sessions.set(sid, { user, createdAt: Date.now() });

    res.cookie('sid', sid, {
      httpOnly: true,
      sameSite: 'lax',
      secure: true,
      path: '/',
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    res.json({ ok: true, user });
  } catch (e) {
    console.error('auth error:', e);
    res.status(401).json({ error: 'token inválido' });
  }
});

app.get('/auth/me', (req, res) => {
  const sid = req.cookies.sid;
  if (!sid || !sessions.has(sid)) return res.status(401).json({ authenticated: false });
  res.json({ authenticated: true, user: sessions.get(sid).user });
});

app.post('/auth/logout', (req, res) => {
  const sid = req.cookies.sid;
  if (sid) sessions.delete(sid);
  res.clearCookie('sid', { path: '/' });
  res.json({ ok: true });
});

app.use((req, res) => res.status(404).json({ error: 'not_found' }));

app.listen(PORT, () => console.log('SSO API listening on', PORT));

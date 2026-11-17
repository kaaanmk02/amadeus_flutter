import express from 'express';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

const app = express();
app.use(helmet());
app.use(express.json({ limit: '8mb' }));
app.use(rateLimit({ windowMs: 60_000, limit: 30, standardHeaders: true, legacyHeaders: false }));
const PORT = Number(process.env.PORT || 8080);
const UPSTREAM = process.env.UPSTREAM_URL;
const API_KEY = process.env.UPSTREAM_API_KEY;
const PROXY_TOKEN = process.env.AMADEUS_PROXY_TOKEN;
if (!UPSTREAM || !API_KEY || !PROXY_TOKEN) throw new Error('UPSTREAM_URL, UPSTREAM_API_KEY and AMADEUS_PROXY_TOKEN are required');

app.get('/health', (_req, res) => res.json({ ok: true }));
app.post('/v1/chat/completions', async (req, res) => {
  if (req.header('x-amadeus-proxy-token') !== PROXY_TOKEN) return res.status(401).json({ error: 'Unauthorized' });
  try {
    const target = new URL('/v1/chat/completions', UPSTREAM);
    const upstream = await fetch(target, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'authorization': `Bearer ${API_KEY}`, 'accept': req.header('accept') || 'application/json' },
      body: JSON.stringify(req.body),
      signal: AbortSignal.timeout(130_000),
    });
    res.status(upstream.status);
    const contentType = upstream.headers.get('content-type');
    if (contentType) res.setHeader('content-type', contentType);
    if (!upstream.body) return res.end();
    upstream.body.pipeTo(new WritableStream({
      write(chunk) { res.write(Buffer.from(chunk)); },
      close() { res.end(); },
      abort() { res.end(); },
    })).catch(() => res.end());
  } catch (error) {
    res.status(502).json({ error: 'Upstream request failed' });
  }
});
app.listen(PORT, '0.0.0.0', () => console.log(`Amadeus proxy listening on ${PORT}`));

'use strict';

const http = require('http');

const port = Number(process.env.PORT) || 5005;
const timeoutMs = 5000;

const req = http.get(
  {
    hostname: '127.0.0.1',
    port,
    path: '/health',
    timeout: timeoutMs,
  },
  (res) => {
    let body = '';
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
      body += chunk;
    });
    res.on('end', () => {
      if (res.statusCode !== 200) {
        process.exit(1);
      }
      try {
        const parsed = JSON.parse(body);
        process.exit(parsed && parsed.status === 'healthy' ? 0 : 1);
      } catch {
        process.exit(1);
      }
    });
  }
);

req.on('timeout', () => {
  req.destroy();
  process.exit(1);
});

req.on('error', () => {
  process.exit(1);
});

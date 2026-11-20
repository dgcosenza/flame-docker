'use strict';

const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('fs');
const os = require('os');
const path = require('path');

const initDockerSecrets = require('../utils/init/initDockerSecrets');
const { initializeSecret, resolveSecretPath } = require('../utils/secret');

test('loadEnvFileSecrets loads PASSWORD from PASSWORD_FILE without exposing value', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'flame-pwfile-'));
  const pwFile = path.join(dir, 'password');
  const prevPw = process.env.PASSWORD;
  const prevFile = process.env.PASSWORD_FILE;
  try {
    fs.writeFileSync(pwFile, 'from-password-file\n', { mode: 0o600 });
    process.env.PASSWORD = 'old-env-pw';
    process.env.PASSWORD_FILE = pwFile;
    initDockerSecrets.loadEnvFileSecrets(['PASSWORD_FILE']);
    assert.strictEqual(process.env.PASSWORD, 'from-password-file');
  } finally {
    if (prevPw === undefined) delete process.env.PASSWORD;
    else process.env.PASSWORD = prevPw;
    if (prevFile === undefined) delete process.env.PASSWORD_FILE;
    else process.env.PASSWORD_FILE = prevFile;
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test('initializeSecret prefers existing data/.secret over data/secret.key', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'flame-dotsecret-'));
  const prevSecret = process.env.SECRET;
  try {
    delete process.env.SECRET;
    fs.writeFileSync(path.join(dir, '.secret'), 'upstream-dot-secret\n', {
      mode: 0o600,
    });
    fs.writeFileSync(path.join(dir, 'secret.key'), 'revamped-secret-key\n', {
      mode: 0o600,
    });
    assert.strictEqual(resolveSecretPath(dir), path.join(dir, '.secret'));
    initializeSecret(dir);
    assert.strictEqual(process.env.SECRET, 'upstream-dot-secret');
  } finally {
    if (prevSecret === undefined) delete process.env.SECRET;
    else process.env.SECRET = prevSecret;
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test('initializeSecret falls back to existing data/secret.key when .secret is absent', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'flame-secretkey-'));
  const prevSecret = process.env.SECRET;
  try {
    delete process.env.SECRET;
    fs.writeFileSync(path.join(dir, 'secret.key'), 'revamped-only-secret\n', {
      mode: 0o600,
    });
    assert.strictEqual(resolveSecretPath(dir), path.join(dir, 'secret.key'));
    initializeSecret(dir);
    assert.strictEqual(process.env.SECRET, 'revamped-only-secret');
  } finally {
    if (prevSecret === undefined) delete process.env.SECRET;
    else process.env.SECRET = prevSecret;
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

test('initializeSecret creates data/.secret with mode 0600 on fresh install', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'flame-newsecret-'));
  const prevSecret = process.env.SECRET;
  try {
    delete process.env.SECRET;
    initializeSecret(dir);
    const created = path.join(dir, '.secret');
    assert.ok(fs.existsSync(created));
    const stat = fs.statSync(created);
    assert.strictEqual(stat.mode & 0o777, 0o600);
    assert.strictEqual(process.env.SECRET.length, 128);
  } finally {
    if (prevSecret === undefined) delete process.env.SECRET;
    else process.env.SECRET = prevSecret;
    fs.rmSync(dir, { recursive: true, force: true });
  }
});

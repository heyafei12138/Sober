import fs from "node:fs/promises";
import path from "node:path";
import sharp from "/Users/mac/.codex/skills/appstore-preview/node_modules/sharp/lib/index.js";

const W = 1242;
const H = 2688;
const root = path.resolve("appstore-previews");
const source = path.join(root, "source");
const out = path.join(root, "output");

const panels = [
  {
    file: "01-today-top.png",
    out: "01-daily-step.png",
    title: "每天一步，安静回到神面前",
    body: "经文、祷告与小行动，放进同一个清晨。",
    accent: "#3F7556",
    bg1: "#FFF6E8",
    bg2: "#EEF8EF",
    screenY: 640,
    screenW: 820,
  },
  {
    file: "02-today-prayer.png",
    out: "02-scripture-today.png",
    title: "一句经文，陪你走今天",
    body: "慢慢读，带着盼望开始下一步。",
    accent: "#D66C60",
    bg1: "#FFF3ED",
    bg2: "#F0F8EE",
    screenY: 600,
    screenW: 820,
  },
  {
    file: "05-anxious.png",
    out: "03-mood-prayer.png",
    title: "按下此刻的心情",
    body: "焦虑、疲惫、孤单，都有合适的经文与祷告。",
    accent: "#2F6248",
    bg1: "#FFF9F1",
    bg2: "#EEF5EC",
    screenY: 625,
    screenW: 820,
  },
  {
    file: "03-journey.png",
    out: "04-journey-rhythm.png",
    title: "看见你的灵修节奏",
    body: "安静日、祷告与进度，一周都清楚。",
    accent: "#527A5B",
    bg1: "#F5FBF3",
    bg2: "#EEF8F5",
    screenY: 600,
    screenW: 820,
  },
  {
    file: "04-saved.png",
    out: "05-save-return.png",
    title: "把值得回来的内容收好",
    body: "经文、祷告、反思与主题，随时再读。",
    accent: "#3F7556",
    bg1: "#F7FBF5",
    bg2: "#FFF7EC",
    screenY: 595,
    screenW: 820,
  },
  {
    file: "01-today-top.png",
    out: "06-start-in-one-minute.png",
    title: "一分钟开始今天的平静",
    body: "打开 GracePath，读一句话，走一个小步骤。",
    accent: "#234C35",
    bg1: "#FFF4E4",
    bg2: "#EBF6EE",
    screenY: 655,
    screenW: 795,
  },
];

function esc(s) {
  return s.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
}

function wrapText(text, maxChars) {
  const chunks = [];
  let current = "";
  for (const char of text) {
    if (current.length >= maxChars && /[，。,. ]/.test(char)) {
      chunks.push(current.trim());
      current = "";
      continue;
    }
    current += char;
    if (current.length >= maxChars) {
      chunks.push(current.trim());
      current = "";
    }
  }
  if (current.trim()) chunks.push(current.trim());
  return chunks;
}

function textSvg(panel, index) {
  const titleLines = wrapText(panel.title, 12);
  const bodyLines = wrapText(panel.body, 19);
  const titleSpans = titleLines
    .map((line, i) => `<tspan x="96" dy="${i === 0 ? 0 : 86}">${esc(line)}</tspan>`)
    .join("");
  const bodySpans = bodyLines
    .map((line, i) => `<tspan x="98" dy="${i === 0 ? 0 : 46}">${esc(line)}</tspan>`)
    .join("");
  const bodyY = 216 + Math.max(0, titleLines.length - 1) * 86;

  return Buffer.from(`
<svg width="${W}" height="${H}" viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="${panel.bg1}"/>
      <stop offset="1" stop-color="${panel.bg2}"/>
    </linearGradient>
    <radialGradient id="glow" cx="50%" cy="36%" r="62%">
      <stop offset="0" stop-color="${panel.accent}" stop-opacity=".17"/>
      <stop offset="1" stop-color="${panel.accent}" stop-opacity="0"/>
    </radialGradient>
    <filter id="softShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="34" stdDeviation="34" flood-color="#183927" flood-opacity=".18"/>
    </filter>
  </defs>
  <rect width="${W}" height="${H}" fill="url(#bg)"/>
  <rect width="${W}" height="${H}" fill="url(#glow)"/>
  <g transform="translate(96 118)">
    <rect x="0" y="0" width="156" height="52" rx="26" fill="#FFFFFF" opacity=".78"/>
    <text x="78" y="35" text-anchor="middle"
      font-family="PingFang SC, Hiragino Sans GB, Arial, sans-serif"
      font-size="24" font-weight="700" fill="${panel.accent}" letter-spacing="1.5">GRACEPATH</text>
  </g>
  <text x="96" y="250"
    font-family="PingFang SC, Hiragino Sans GB, Arial, sans-serif"
    font-size="66" font-weight="800" fill="#16241C" letter-spacing="0">${titleSpans}</text>
  <text x="98" y="${bodyY + 94}"
    font-family="PingFang SC, Hiragino Sans GB, Arial, sans-serif"
    font-size="38" font-weight="500" fill="#5D6B62" letter-spacing="0">${bodySpans}</text>
  <g filter="url(#softShadow)">
    <rect x="176" y="${panel.screenY - 26}" width="${panel.screenW + 50}" height="${Math.round(panel.screenW * 2622 / 1206) + 52}" rx="82" fill="#FFFFFF" opacity=".9"/>
  </g>
  <circle cx="1096" cy="216" r="48" fill="${panel.accent}" opacity=".13"/>
  <text x="1096" y="229" text-anchor="middle"
    font-family="PingFang SC, Hiragino Sans GB, Arial, sans-serif"
    font-size="31" font-weight="800" fill="${panel.accent}">${String(index + 1).padStart(2, "0")}</text>
</svg>`);
}

async function roundedImage(input, width) {
  const height = Math.round(width * 2622 / 1206);
  const resized = await sharp(input).resize(width, height).png().toBuffer();
  const mask = Buffer.from(`
<svg width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" xmlns="http://www.w3.org/2000/svg">
  <rect width="${width}" height="${height}" rx="64" ry="64" fill="#fff"/>
</svg>`);
  return {
    input: await sharp(resized).composite([{ input: mask, blend: "dest-in" }]).png().toBuffer(),
    width,
    height,
  };
}

await fs.mkdir(out, { recursive: true });

for (const [index, panel] of panels.entries()) {
  const screenshot = await roundedImage(path.join(source, panel.file), panel.screenW);
  const x = Math.round((W - screenshot.width) / 2);
  const top = panel.screenY;
  await sharp({
    create: {
      width: W,
      height: H,
      channels: 4,
      background: "#ffffff",
    },
  })
    .composite([
      { input: textSvg(panel, index), left: 0, top: 0 },
      { input: screenshot.input, left: x, top },
    ])
    .png()
    .toFile(path.join(out, panel.out));
}

console.log(`Generated ${panels.length} previews in ${out}`);

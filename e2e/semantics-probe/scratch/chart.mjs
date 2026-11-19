import { chromium } from '@playwright/test';
import fs from 'node:fs';
import { PNG } from 'pngjs';
const diff=(a,b)=>{const x=PNG.sync.read(a),y=PNG.sync.read(b);let n=0;for(let i=0;i<x.data.length;i+=4){if(Math.abs(x.data[i]-y.data[i])+Math.abs(x.data[i+1]-y.data[i+1])+Math.abs(x.data[i+2]-y.data[i+2])>48)n++}return +(n/(x.width*x.height)).toFixed(4)};
const c = JSON.parse(fs.readFileSync('.coords/D1a__390x844.json','utf8')); const k=Object.keys(c).filter(x=>!x.startsWith('memo'));
const ctr=b=>[b.x+b.width/2,b.y+b.height/2];
const b = await chromium.launch();
for (const [mode,port] of [['on',8081],['off',8082],['on',8081],['off',8082]]) {
  const ctx = await b.newContext({ viewport:{width:390,height:844}, deviceScaleFactor:1, locale:'es' }); const p = await ctx.newPage();
  await p.goto(`http://127.0.0.1:${port}/market/instrument/ECOPETROL-CO`); await p.waitForURL(/onboarding/); await p.waitForTimeout(1200);
  for (const key of k.slice(0,3)) { await p.mouse.click(...ctr(c[key])); await p.waitForTimeout(900); }
  await p.waitForURL(/instrument/); await p.waitForTimeout(1500);
  const box=c[k[3]]; const clip={x:box.x,y:box.y,width:box.width,height:box.height};
  await p.mouse.move(5,5); await p.waitForTimeout(500);
  const base=await p.screenshot({clip}); const out=[];
  for (const fx of [0.3,0.6,0.8]) { await p.mouse.move(box.x+box.width*fx, box.y+box.height/2, {steps:5}); await p.waitForTimeout(500); out.push(diff(base, await p.screenshot({clip}))); }
  await p.mouse.down(); await p.waitForTimeout(400); const down=diff(base, await p.screenshot({clip})); await p.mouse.up();
  await p.screenshot({path:`scratch/chart-${mode}.png`});
  console.log(mode,'hover',out,'apretado',down, k.slice(0,4));
  await ctx.close();
}
await b.close();

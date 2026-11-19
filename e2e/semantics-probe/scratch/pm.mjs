import { chromium } from '@playwright/test';
const b = await chromium.launch();
const ctx = await b.newContext({ viewport:{width:390,height:844}, deviceScaleFactor:1, locale:'es' });
const p = await ctx.newPage();
await p.goto('http://127.0.0.1:8082/'); await p.waitForURL(/onboarding/); await p.waitForTimeout(1200);
await p.mouse.click(195, 0); // placeholder? no: usar coords de skip
const c = JSON.parse((await import('node:fs')).readFileSync('.coords/A1__390x844.json','utf8'));
const k = Object.keys(c); console.log(k);
const ctr = b=>[b.x+b.width/2,b.y+b.height/2];
await p.mouse.click(...ctr(c[k[0]])); await p.waitForURL(/login/); await p.waitForTimeout(1000);
await p.mouse.click(...ctr(c[k[1]])); await p.keyboard.type('hola@x.co',{delay:30});
await p.evaluate(()=>document.querySelector('flt-semantics-placeholder').click());
for (const w of [100,300,1000,2000]) { await p.waitForTimeout(w); console.log(w, await p.evaluate(()=>({n:document.querySelectorAll('flt-semantics').length, ids:[...document.querySelectorAll('[flt-semantics-identifier]')].length, inputs:[...document.querySelectorAll('flt-semantics input')].map(i=>i.getAttribute('aria-label')+'='+i.value), ae: document.activeElement.outerHTML.slice(0,200)}))); }
await b.close();

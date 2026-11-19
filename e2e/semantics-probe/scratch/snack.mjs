import { chromium } from '@playwright/test';
const b = await chromium.launch();
const S = id => `[flt-semantics-identifier="${id}"]`;
const ctx = await b.newContext({ viewport:{width:390,height:844}, deviceScaleFactor:1, locale:'es' });
const p = await ctx.newPage();
await p.goto('http://127.0.0.1:8081/wallet');
await p.locator(S('onboarding_skip_button')).click();
await p.locator(S('auth_login_demo_button')).click(); await p.locator(S('auth_login_submit_button')).click();
await p.locator(S('wallet_cop_deposit_button')).click();
await p.locator(S('wallet_deposit_suggested_item_1000000')).click();
await p.waitForTimeout(500);
await p.locator(S('wallet_deposit_submit_button')).click();
const t0 = Date.now();
let last='';
while (Date.now()-t0 < 8000) {
  const s = await p.evaluate(() => { const ids=[...document.querySelectorAll('[flt-semantics-identifier]')].map(e=>e.getAttribute('flt-semantics-identifier')); const sn=[...document.querySelectorAll('flt-semantics')].filter(e=>/dep[oó]sit|Listo|acredit/i.test((e.getAttribute('aria-label')||'')+ (e.children.length?'':e.textContent))).map(e=>e.outerHTML.slice(0,260)); return JSON.stringify({url:location.pathname, n:ids.length, snack: ids.filter(i=>/snack/.test(i)), views: ids.filter(i=>/_view$/.test(i)), sn}); });
  if (s!==last) { console.log(Date.now()-t0, s.slice(0,1500)); last=s; }
  await p.waitForTimeout(100);
}
await p.screenshot({path:'scratch/snack.png'});
await b.close();

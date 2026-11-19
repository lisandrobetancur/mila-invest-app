import { chromium } from '@playwright/test';
const b = await chromium.launch();
console.log('chromium', b.version());
const ae = () => { let el=document.activeElement; while(el&&el.shadowRoot&&el.shadowRoot.activeElement) el=el.shadowRoot.activeElement; return el? el.outerHTML.slice(0,400):null; };
const skeleton = () => { const out=[]; const walk=(n,d)=>{ if(d>5) return; for(const c of n.children){ if(['SCRIPT','STYLE','FLT-SEMANTICS'].includes(c.tagName)) continue; out.push('  '.repeat(d)+c.tagName.toLowerCase()+(c.shadowRoot?' #shadow':'')+' '+[...c.attributes].map(a=>a.name+'='+a.value.slice(0,40)).join(' ').slice(0,160)); walk(c,d+1); if(c.shadowRoot) walk(c.shadowRoot,d+1);} }; walk(document.body,0); return out.join('\n'); };
const coords = {};
for (const [mode, port] of [['on',8081],['off',8082]]) {
  const ctx = await b.newContext({ viewport:{width:390,height:844}, deviceScaleFactor:1, locale:'es' });
  const p = await ctx.newPage();
  p.on('console', m => m.type()==='error' && console.log('  [console]', m.text().slice(0,200)));
  const t0=Date.now();
  await p.goto(`http://127.0.0.1:${port}/`);
  await p.waitForURL(/onboarding/);
  console.log(`\n===== ${mode} ===== onboarding url in`, Date.now()-t0,'ms');
  await p.waitForTimeout(1500);
  if (mode==='on') {
    const bx = await p.locator('[flt-semantics-identifier="onboarding_skip_button"]').boundingBox(); coords.skip=bx;
  }
  await p.mouse.click(coords.skip.x+coords.skip.width/2, coords.skip.y+coords.skip.height/2);
  await p.waitForURL(/login/); await p.waitForTimeout(1500);
  console.log('url', p.url());
  console.log('SKELETON\n'+await p.evaluate(skeleton));
  console.log('ACTIVE at load:', await p.evaluate(ae));
  if (mode==='on') {
    for (const id of ['auth_login_email_field','auth_login_password_field','auth_login_password_toggle','auth_login_submit_button','auth_login_demo_button']) {
      const l = p.locator(`[flt-semantics-identifier="${id}"]`);
      coords[id] = await l.boundingBox();
      console.log(id, JSON.stringify(coords[id]), '\n   ', (await l.evaluate(e=>e.outerHTML)).slice(0,700));
    }
    console.log('email parent chain:', await p.locator('[flt-semantics-identifier="auth_login_email_field"]').evaluate(e=>{const o=[];let n=e;while(n&&n.tagName!=='BODY'){o.push(n.tagName.toLowerCase()+'#'+(n.id||'')+'['+(n.getAttribute('flt-semantics-identifier')||'')+'] pe='+getComputedStyle(n).pointerEvents);n=n.parentElement;}return o.join(' < ');}));
  }
  await p.screenshot({path:`scratch/login-${mode}.png`});
  const c = coords.auth_login_email_field;
  await p.mouse.click(c.x+c.width/2, c.y+c.height/2);
  for (const w of [0,50,200,500]) { await p.waitForTimeout(w); console.log(`ACTIVE +${w}ms after click email:`, await p.evaluate(ae)); }
  await p.keyboard.type('abc');
  console.log('ACTIVE after type:', await p.evaluate(ae));
  console.log('active value:', await p.evaluate(()=>{let el=document.activeElement; while(el&&el.shadowRoot&&el.shadowRoot.activeElement) el=el.shadowRoot.activeElement; return el&&el.value}));
  console.log('placeholder:', await p.evaluate(()=>{const e=document.querySelector('flt-semantics-placeholder'); return e? e.outerHTML.slice(0,300):null}), 'flt-semantics count', await p.evaluate(()=>document.querySelectorAll('flt-semantics').length));
  await ctx.close();
}
await b.close();

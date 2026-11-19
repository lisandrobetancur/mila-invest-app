import { chromium } from '@playwright/test';
const b = await chromium.launch();
const S = id => `[flt-semantics-identifier="${id}"]`;
const dump = async (p, label) => {
  const r = await p.evaluate(() => {
    const ids = [...document.querySelectorAll('[flt-semantics-identifier]')].map(e => { const r=e.getBoundingClientRect(); return `${e.getAttribute('flt-semantics-identifier')}{${e.getAttribute('role')||''}${e.hasAttribute('flt-tappable')?',tap':''},pe=${getComputedStyle(e).pointerEvents[0]},${Math.round(r.x)},${Math.round(r.y)},${Math.round(r.width)}x${Math.round(r.height)}}`; });
    const sc = [...document.querySelectorAll('flt-semantics-scroll-overflow')].map(o => { const s=o.parentElement; const r=s.getBoundingClientRect(); return `scroll[#${s.id} id=${s.getAttribute('flt-semantics-identifier')} top=${s.scrollTop} h=${s.scrollHeight} ch=${s.clientHeight} ov=${getComputedStyle(s).overflowY} pe=${getComputedStyle(s).pointerEvents} rect=${Math.round(r.x)},${Math.round(r.y)},${Math.round(r.width)}x${Math.round(r.height)} anc=${s.closest('[flt-semantics-identifier]')?.getAttribute('flt-semantics-identifier')}]`; });
    return { ids, sc };
  });
  console.log(`\n## ${label} url=${new URL(p.url()).pathname}\n` + r.ids.join(' ') + '\n' + r.sc.join('\n'));
};
const open = async (route, vp={width:390,height:844}) => {
  const ctx = await b.newContext({ viewport:vp, deviceScaleFactor:1, locale:'es' });
  const p = await ctx.newPage();
  await p.goto('http://127.0.0.1:8081'+route);
  await p.locator(S('onboarding_skip_button')).click();
  await p.locator(S('auth_login_demo_button')).waitFor();
  return p;
};
const login = async p => { await p.locator(S('auth_login_demo_button')).click(); await p.locator(S('auth_login_submit_button')).click(); await p.locator(S('nav_shell_view')).waitFor(); await p.waitForTimeout(1200); };
let p = await open('/market'); await login(p); await dump(p,'market 390');
await p.locator(S('market_list_search_field')).click(); await p.keyboard.type('eco',{delay:50}); await p.waitForTimeout(800); await dump(p,'market con texto');
p = await open('/home'); await login(p); await dump(p,'home 390');
await p.locator(S('dashboard_home_settings_icon_button')).click(); await p.waitForTimeout(1000); await dump(p,'settings');
await p.locator(S('settings_logout_button')).scrollIntoViewIfNeeded(); await p.locator(S('settings_logout_button')).click(); await p.waitForTimeout(1000); await dump(p,'settings + dialog');
p = await open('/activity'); await login(p); await dump(p,'activity 390');
p = await open('/register', {width:390,height:600}); await p.locator(S('auth_login_register_link')).click(); await p.waitForTimeout(1000); await dump(p,'register 390x600');
await p.locator(S('auth_register_country_co_chip')).click(); await p.waitForTimeout(600); await dump(p,'register + CO');
p = await open('/market/instrument/ECOPETROL-CO'); await login(p); await dump(p,'detalle 390');
await p.locator(S('market_detail_buy_button')).click(); await p.waitForTimeout(1200); await dump(p,'ticket 390x844');
p = await open('/market/instrument/ECOPETROL-CO',{width:1280,height:800}); await login(p); await p.locator(S('market_detail_buy_button')).click(); await p.waitForTimeout(1200); await dump(p,'ticket 1280');
p = await open('/wallet'); await login(p); await dump(p,'wallet'); await p.locator(S('wallet_cop_deposit_button')).click(); await p.waitForTimeout(1200); await dump(p,'deposito');
await p.locator(S('wallet_deposit_suggested_item_1000000')).click(); await p.locator(S('wallet_deposit_submit_button')).click(); await p.locator(S('wallet_deposit_success_snackbar')).waitFor(); await dump(p,'snackbar');
const t0=Date.now(); await p.locator(S('wallet_deposit_success_snackbar')).waitFor({state:'detached'}); console.log('snackbar dura ms', Date.now()-t0);
await b.close();

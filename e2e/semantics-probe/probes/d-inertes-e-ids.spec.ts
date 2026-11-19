/**
 * D · P7 (nodos inertes) y P8 (ids que no llegan al DOM).
 *
 * D1: lo que hace Playwright, sin `force`, sobre nodos que no son tappables.
 *     Al lado de cada intento por locator (solo ON) va el mismo gesto con
 *     mouse/táctil real por coordenadas, en los dos modos, para saber si la
 *     app responde a ese gesto con y sin árbol.
 * D2: recorre las vistas y estados alcanzables con la semilla demo y junta
 *     los `flt-semantics-identifier` que aparecen en el DOM (solo ON).
 */
import { expect, test, type Page } from '@playwright/test';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { Driver, diffRatio, ruta, sel } from '../lib/driver';

const intento = async (f: () => Promise<unknown>): Promise<string> => {
    try {
        await f();
        return 'éxito';
    } catch (e) {
        const m = String((e as Error).message).replace(/\u001b\[\d+m/g, '');
        const pista = [...new Set(m.split('\n').map((x) => x.trim().replace(/^- /, '')).filter((x) => /intercepts pointer events|not visible|not stable|outside of the viewport|waiting for element to be/.test(x)))];
        return `ERROR: ${m.split('\n')[0]}${pista.length ? ' | ' + pista.slice(0, 3).join(' | ') : ''}`.slice(0, 500);
    }
};

test('D1a hover y click sobre el gráfico del detalle', async ({ page }, info) => {
    const d = new Driver(page, info, 'D1a');
    await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
    const caja = await d.box('market_detail_chart');
    const clip = { x: caja.x, y: caja.y, width: caja.width, height: caja.height };
    let hoverLocator: string | undefined;
    let clickLocator: string | undefined;
    if (d.on) {
        hoverLocator = await intento(() => d.loc('market_detail_chart').hover({ timeout: 5000 }));
        await page.mouse.move(5, 5);
        clickLocator = await intento(() => d.loc('market_detail_chart').click({ timeout: 5000 }));
        await page.mouse.move(5, 5);
        await page.waitForTimeout(300);
    }
    await page.mouse.move(5, 5);
    await d.quieta(3000);
    const base = await page.screenshot({ clip });
    const p = { x: caja.x + caja.width * 0.6, y: caja.y + caja.height / 2 };
    await page.mouse.move(p.x, p.y);
    await page.waitForTimeout(400);
    const conHoverReal = diffRatio(base, await page.screenshot({ clip }));
    await page.mouse.down();
    await page.waitForTimeout(400);
    const conBotonApretado = diffRatio(base, await page.screenshot({ clip }));
    await page.mouse.up();
    const apagado = await d.sigueApagado();
    await d.registrar({ hoverLocator, clickLocator, graficoCambiaConHoverReal: conHoverReal, graficoCambiaConBotonApretado: conBotonApretado, apagado });
    if (!d.on) expect(apagado).toBe(true);
});

test('D1b click sobre un texto con id (dashboard_home_total_text)', async ({ page }, info) => {
    test.skip(info.project.name !== 'on', 'no aplica en OFF: no hay nodo que accionar');
    const d = new Driver(page, info, 'D1b');
    await d.abrirConSesion('/home');
    const estilo = await d.loc('dashboard_home_total_text').evaluate((e) => ({ pe: getComputedStyle(e).pointerEvents, role: e.getAttribute('role'), tappable: e.hasAttribute('flt-tappable') }));
    const click = await intento(() => d.loc('dashboard_home_total_text').click({ timeout: 5000 }));
    const hover = await intento(() => d.loc('dashboard_home_total_text').hover({ timeout: 5000 }));
    await d.registrar({ estilo, click, hover, url: ruta(page) });
});

test.describe('táctil', () => {
    test.use({ hasTouch: true });
    test('D1c pull-to-refresh en /home (arrastre táctil desde arriba)', async ({ page }, info) => {
        const d = new Driver(page, info, 'D1c');
        await d.abrirConSesion('/home');
        const caja = await d.box('dashboard_home_greeting_text');
        const x = Math.round(caja.x + caja.width / 2);
        const y0 = Math.round(caja.y + caja.height / 2);
        let dragLocator: string | undefined;
        if (d.on) {
            // Lo que haría una suite: arrastrar el nodo con id. Sin force.
            dragLocator = await intento(() => d.loc('dashboard_home_greeting_text').dragTo(d.loc('dashboard_home_gainers_title_text'), { timeout: 5000 }));
            await page.waitForTimeout(1500);
        }
        const base = await d.quieta(4000);
        const cdp = await page.context().newCDPSession(page);
        const toque = (type: string, y: number) => cdp.send('Input.dispatchTouchEvent', { type: type as 'touchStart', touchPoints: type === 'touchEnd' ? [] : [{ x, y, id: 1 }] });
        await toque('touchStart', y0);
        for (let dy = 20; dy <= 260; dy += 20) { await toque('touchMove', y0 + dy); await page.waitForTimeout(16); }
        await page.waitForTimeout(250);
        const sostenido = await page.screenshot();
        const cambiaAlArrastrar = diffRatio(base, sostenido);
        let estadosTrasSoltar: string[] = [];
        await toque('touchEnd', y0 + 260);
        if (d.on) {
            const visto = new Set<string>();
            const fin = Date.now() + 2500;
            while (Date.now() < fin) {
                for (const i of await page.evaluate(() => [...document.querySelectorAll('[flt-semantics-identifier^="dashboard_home_state_"]')].map((e) => e.getAttribute('flt-semantics-identifier')!))) visto.add(i);
                await page.waitForTimeout(40);
            }
            estadosTrasSoltar = [...visto];
        } else {
            await page.waitForTimeout(2500);
        }
        await info.attach('pull-sostenido', { body: sostenido, contentType: 'image/png' });
        fs.writeFileSync(path.resolve(__dirname, '..', '.coords', `D1c__pull__${d.mode}.png`), sostenido);
        const apagado = await d.sigueApagado();
        await d.registrar({ dragLocator, cambiaAlArrastrar, estadosTrasSoltar, apagado });
        if (!d.on) expect(apagado).toBe(true);
    });
});

// ---------------------------------------------------------------- D2

test('D2 ids presentes en el DOM, vista por vista', async ({ page }, info) => {
    test.skip(info.project.name !== 'on' || info.repeatEachIndex > 0, 'inventario: solo ON, una pasada');
    test.setTimeout(600_000);
    const vistos: Record<string, string[]> = {};
    const fallos: string[] = [];
    const L = (id: string) => page.locator(sel(id)).first();
    const ids = () => page.evaluate(() => [...document.querySelectorAll('[flt-semantics-identifier]')].map((e) => e.getAttribute('flt-semantics-identifier')!));
    const juntar = async (estado: string, scrollear = true) => {
        await page.waitForTimeout(700);
        const set = new Set(await ids());
        if (scrollear) {
            const v = page.viewportSize()!;
            await page.mouse.move(v.width / 2, v.height / 2);
            let quietos = 0;
            for (let i = 0; i < 60 && quietos < 4; i++) {
                await page.mouse.wheel(0, 250);
                await page.waitForTimeout(250);
                const antes = set.size;
                for (const x of await ids()) set.add(x);
                quietos = set.size === antes ? quietos + 1 : 0;
            }
            await page.mouse.wheel(0, -20000);
            await page.waitForTimeout(400);
        }
        vistos[estado] = [...new Set([...(vistos[estado] ?? []), ...set])].sort();
    };
    const paso = async (nombre: string, f: () => Promise<void>) => {
        try { await f(); } catch (e) { fallos.push(`${nombre}: ${String((e as Error).message).split('\n')[0]}`); }
    };
    const click = (id: string) => L(id).click({ timeout: 8000 });
    const teclear = async (id: string, texto: string) => { await click(id); await page.waitForTimeout(500); await page.keyboard.press('ControlOrMeta+A'); await page.keyboard.type(texto, { delay: 50 }); await page.waitForTimeout(300); };

    await page.goto('/');
    await paso('onboarding', async () => {
        await L('onboarding_view').waitFor();
        await juntar('onboarding paso 1', false);
        await click('onboarding_next_button'); await juntar('onboarding paso 2', false);
        await click('onboarding_next_button'); await juntar('onboarding paso 3', false);
        await click('onboarding_start_button');
    });
    await paso('login', async () => {
        await L('auth_login_view').waitFor();
        await juntar('login', false);
        await click('auth_login_submit_button'); await juntar('login con errores de campo', false);
        await teclear('auth_login_email_field', 'demo@milainvest.app');
        await teclear('auth_login_password_field', 'Mala12345');
        await click('auth_login_submit_button'); await juntar('login con credenciales incorrectas', false);
    });
    await paso('registro', async () => {
        await click('auth_login_register_link');
        await L('auth_register_view').waitFor();
        await juntar('registro');
        await L('auth_register_submit_button').scrollIntoViewIfNeeded();
        await click('auth_register_submit_button'); await juntar('registro con errores');
        for (const c of ['co', 'mx', 'pe']) { await click(`auth_register_country_${c}_chip`); await juntar(`registro país ${c}`); }
        await click('auth_register_back_icon_button');
    });
    await paso('home', async () => {
        await L('auth_login_view').waitFor();
        await click('auth_login_demo_button'); await click('auth_login_submit_button');
        await L('dashboard_home_view').waitFor();
        await juntar('inicio');
    });
    await paso('mercado', async () => {
        await click('nav_market_tab'); await L('market_list_view').waitFor(); await juntar('mercado');
        await teclear('market_list_search_field', 'eco'); await juntar('mercado con búsqueda', false);
        await teclear('market_list_search_field', 'zzzz'); await page.waitForTimeout(800); await juntar('mercado sin resultados', false);
        await click('market_list_clear_filters_button'); await page.waitForTimeout(600);
    });
    await paso('detalle', async () => {
        await click('market_list_instrument_item_ECOPETROL-CO'); await L('market_detail_view').waitFor(); await juntar('detalle de instrumento');
    });
    await paso('ticket', async () => {
        await click('market_detail_buy_button'); await L('orders_ticket_view').waitFor(); await juntar('ticket', false);
        await teclear('orders_ticket_quantity_field', '99999999'); await page.waitForTimeout(800); await juntar('ticket sin saldo', false);
        await teclear('orders_ticket_quantity_field', '1'); await page.waitForTimeout(800);
        await click('orders_ticket_review_button'); await L('orders_confirm_view').waitFor(); await juntar('confirmación', false);
        await click('orders_confirm_submit_button'); await L('orders_result_view').waitFor(); await juntar('resultado', false);
        await click('orders_result_done_button');
    });
    await paso('detalle → vender', async () => {
        await click('market_detail_sell_button'); await L('orders_ticket_view').waitFor(); await juntar('ticket de venta', false);
        await click('orders_ticket_close_icon_button');
    });
    await paso('portafolio', async () => { await click('market_detail_back_icon_button').catch(() => undefined); await click('nav_portfolio_tab'); await L('portfolio_overview_view').waitFor(); await juntar('portafolio'); });
    await paso('actividad', async () => {
        await click('nav_activity_tab'); await L('transactions_list_view').waitFor(); await juntar('actividad · movimientos');
        await click('transactions_list_type_sell_chip'); await click('transactions_list_range_7d_chip'); await page.waitForTimeout(600); await juntar('actividad · filtrada', false);
        await click('transactions_list_type_all_chip'); await click('transactions_list_range_all_chip');
        await click('transactions_list_orders_tab'); await L('orders_history_view').waitFor(); await juntar('actividad · órdenes');
        const primera = page.locator('[flt-semantics-identifier^="orders_history_item_"][flt-tappable]').first();
        await primera.click({ timeout: 8000 }); await L('orders_detail_view').waitFor(); await juntar('detalle de orden');
        await click('orders_detail_back_icon_button');
    });
    await paso('billetera', async () => {
        await click('nav_home_tab'); await click('dashboard_home_wallet_icon_button'); await L('wallet_accounts_view').waitFor(); await juntar('billetera');
        await click('wallet_cop_deposit_button'); await L('wallet_deposit_view').waitFor(); await juntar('depósito', false);
        await click('wallet_deposit_submit_button'); await juntar('depósito con monto vacío', false);
        await click('wallet_deposit_suggested_item_1000000'); await page.waitForTimeout(500);
        await click('wallet_deposit_submit_button'); await L('wallet_deposit_success_snackbar').waitFor({ timeout: 8000 }); await juntar('billetera con snackbar', false);
        await click('wallet_accounts_back_icon_button');
    });
    await paso('ajustes', async () => {
        await click('dashboard_home_settings_icon_button'); await L('settings_view').waitFor(); await juntar('ajustes');
        await click('settings_logout_button'); await L('settings_logout_dialog').waitFor(); await juntar('ajustes · diálogo de cerrar sesión', false);
        await click('settings_logout_cancel_button');
    });
    await paso('no encontrado (con sesión, sin recargar)', async () => {
        await page.evaluate(() => { history.pushState({}, '', '/esta-ruta-no-existe'); window.dispatchEvent(new PopStateEvent('popstate', { state: {} })); });
        await page.waitForTimeout(1500); await juntar(`ruta desconocida con sesión (${ruta(page)})`, false);
    });
    await paso('no encontrado', async () => {
        await page.goto('/esta-ruta-no-existe'); await page.waitForTimeout(2500); await juntar(`ruta desconocida (${ruta(page)})`, false);
    });
    await paso('rail 1280', async () => {
        await page.setViewportSize({ width: 1280, height: 800 });
        await page.goto('/home'); await L('auth_login_view').waitFor();
        await click('auth_login_demo_button'); await click('auth_login_submit_button'); await L('dashboard_home_view').waitFor();
        await juntar('inicio a 1280×800');
    });
    fs.mkdirSync(path.resolve(__dirname, '..', 'results'), { recursive: true });
    fs.writeFileSync(path.resolve(__dirname, '..', 'results', 'D2.json'), JSON.stringify({ vistos, fallos }, null, 1));
    expect(fallos, 'pasos del recorrido que no se pudieron dar').toEqual([]);
});

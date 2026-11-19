/**
 * E · Cerrar con X, tabs y flecha atrás.
 *
 * No estaba en el pedido original: son los otros tres tipos de control de
 * navegación de la app. Para cada uno, en los dos modos y en los dos layouts
 * (390×844: barra inferior y modales como bottom sheet; 1280×800: rail y
 * modales como diálogo):
 *   - si el control hace lo que tiene que hacer (a dónde va la URL);
 *   - cuánto tarda (ms entre el `pointerup` y el cambio de URL, medidos
 *     dentro de la página);
 *   - dónde queda `document.activeElement`;
 *   - que la pantalla final sea la misma en ON y en OFF (captura).
 * El gesto es el mismo en los dos modos: mouse real en el centro del control.
 * En ON se agrega, aparte, `locator.click()`, que es lo que usa una suite.
 */
import { expect, test, type Page } from '@playwright/test';
import { Driver, ruta } from '../lib/driver';

const VIEWPORTS = [
    { width: 390, height: 844 },
    { width: 1280, height: 800 },
];

/** Anota en la página el último `pointerup` y el primer cambio de URL posterior. */
async function cronometro(page: Page): Promise<void> {
    await page.addInitScript(() => {
        const w = window as unknown as { __up: number | null; __nav: number | null; __via: string | null };
        w.__up = null; w.__nav = null; w.__via = null;
        const marca = (via: string) => { if (w.__up !== null && w.__nav === null) { w.__nav = performance.now(); w.__via = via; } };
        window.addEventListener('pointerup', () => { w.__up = performance.now(); w.__nav = null; w.__via = null; }, true);
        window.addEventListener('popstate', () => marca('popstate'), true);
        for (const m of ['pushState', 'replaceState'] as const) {
            const orig = history[m];
            history[m] = function (this: History, ...a: Parameters<History['pushState']>) {
                const antes = location.pathname + location.search;
                const r = orig.apply(this, a);
                if (location.pathname + location.search !== antes) marca(m);
                return r;
            } as History['pushState'];
        }
    });
}

const leerCrono = (page: Page) =>
    page.evaluate(() => {
        const w = window as unknown as { __up: number | null; __nav: number | null; __via: string | null };
        return { ms: w.__up !== null && w.__nav !== null ? Math.round((w.__nav - w.__up) * 10) / 10 : null, via: w.__via };
    });

interface Toque { id: string; url: string; ms: number | null; via: string | null; foco: string; entrega: string }

/** Acciona [id] y espera a que la URL cumpla [espera] (hasta 5 s; si no, se registra igual). */
async function accionar(d: Driver, id: string, espera: RegExp, entrega: 'mouse' | 'locator'): Promise<Toque> {
    if (entrega === 'locator') {
        await d.center(id); // deja la coordenada para OFF y mantiene la numeración de pasos
        await d.loc(id).click({ timeout: 5000 });
    } else {
        await d.tap(id);
    }
    await d.esperarUrl(espera, 5000).catch(() => undefined);
    await d.page.waitForTimeout(250);
    return { id, url: ruta(d.page), ...(await leerCrono(d.page)), foco: await d.foco(), entrega };
}

async function cerrar(d: Driver, datos: Record<string, unknown>, esperado: Record<string, unknown>) {
    const apagado = await d.sigueApagado();
    await d.compararLayout('final');
    await d.registrar({ ...datos, apagado });
    if (!d.on) expect(apagado, 'el árbol se encendió: corrida OFF descartada').toBe(true);
    for (const [k, v] of Object.entries(esperado)) expect.soft(datos[k], k).toEqual(v);
}

for (const vp of VIEWPORTS) {
    const t = `${vp.width}×${vp.height}`;
    test.describe(t, () => {
        test.use({ viewport: vp });

        for (const entrega of ['mouse', 'locator'] as const) {
            const soloOn = () => test.skip(entrega === 'locator' && test.info().project.name !== 'on', 'locator.click() solo existe en ON');
            const sufijo = entrega === 'locator' ? ' · locator.click()' : '';

            test(`E1 cerrar el ticket con la X${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E1${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
                await d.tap('market_detail_buy_button');
                await d.esperarUrl(/\/orders\/ticket\//);
                await d.compararLayout('ticket-abierto');
                const x = await accionar(d, 'orders_ticket_close_icon_button', /\/market\/instrument\/ECOPETROL-CO$/, entrega);
                const ticketEnElDom = d.on ? await d.loc('orders_ticket_view').count() : null;
                // Después de cerrar, lo de abajo tiene que volver a responder.
                const reabre = await accionar(d, 'market_detail_buy_button', /\/orders\/ticket\//, 'mouse');
                await cerrar(d, { x, ticketEnElDom, reabre, urlTrasLaX: x.url, urlAlReabrir: reabre.url }, { urlTrasLaX: '/market/instrument/ECOPETROL-CO', urlAlReabrir: '/orders/ticket/ECOPETROL-CO/buy' });
            });

            test(`E2 cerrar el depósito con la X${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E2${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/wallet');
                await d.tap('wallet_cop_deposit_button');
                await d.esperarUrl(/\/wallet\/deposit\//);
                await d.compararLayout('deposito-abierto');
                const x = await accionar(d, 'wallet_deposit_close_icon_button', /\/wallet$/, entrega);
                const depositoEnElDom = d.on ? await d.loc('wallet_deposit_view').count() : null;
                const reabre = await accionar(d, 'wallet_mxn_deposit_button', /\/wallet\/deposit\/MXN/, 'mouse');
                await cerrar(d, { x, depositoEnElDom, reabre, urlTrasLaX: x.url, urlAlReabrir: reabre.url }, { urlTrasLaX: '/wallet', urlAlReabrir: '/wallet/deposit/MXN' });
            });

            test(`E3 tabs del shell: mercado → portafolio → actividad → inicio${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E3${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/home');
                await d.compararLayout('inicio');
                const toques: Toque[] = [];
                for (const [id, re] of [
                    ['nav_market_tab', /^\/market$/],
                    ['nav_portfolio_tab', /^\/portfolio$/],
                    ['nav_activity_tab', /^\/activity$/],
                    ['nav_home_tab', /^\/home$/],
                ] as const) toques.push(await accionar(d, id, re, entrega));
                await cerrar(d, { toques, urls: toques.map((x) => x.url) }, { urls: ['/market', '/portfolio', '/activity', '/home'] });
            });

            test(`E4 tabs de Actividad: órdenes ↔ movimientos${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E4${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/activity');
                const toques: Toque[] = [];
                toques.push(await accionar(d, 'transactions_list_orders_tab', /^\/activity\/orders$/, entrega));
                toques.push(await accionar(d, 'orders_history_movements_tab', /^\/activity$/, entrega));
                toques.push(await accionar(d, 'transactions_list_orders_tab', /^\/activity\/orders$/, entrega));
                await cerrar(d, { toques, urls: toques.map((x) => x.url) }, { urls: ['/activity/orders', '/activity', '/activity/orders'] });
            });

            test(`E5 flecha atrás: ajustes → inicio${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E5${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/home');
                await d.tap('dashboard_home_settings_icon_button');
                await d.esperarUrl(/\/settings/);
                const atras = await accionar(d, 'settings_back_icon_button', /^\/home$/, entrega);
                await cerrar(d, { atras, url: atras.url }, { url: '/home' });
            });

            test(`E6 flecha atrás: registro → login${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E6${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrir('/register');
                await d.tap('auth_login_register_link');
                await d.esperarUrl(/\/register/);
                const atras = await accionar(d, 'auth_register_back_icon_button', /^\/login$/, entrega);
                await cerrar(d, { atras, url: atras.url }, { url: '/login' });
            });

            test(`E7 flecha atrás: detalle de instrumento → mercado${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E7${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/market');
                await d.tap('market_list_instrument_item_ECOPETROL-CO');
                await d.esperarUrl(/\/market\/instrument\/ECOPETROL-CO/);
                const atras = await accionar(d, 'market_detail_back_icon_button', /^\/market$/, entrega);
                await cerrar(d, { atras, url: atras.url }, { url: '/market' });
            });

            test(`E8 flecha atrás: billetera → inicio${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E8${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/home');
                await d.tap('dashboard_home_wallet_icon_button');
                await d.esperarUrl(/\/wallet/);
                const atras = await accionar(d, 'wallet_accounts_back_icon_button', /^\/home$/, entrega);
                await cerrar(d, { atras, url: atras.url }, { url: '/home' });
            });

            test(`E9 flecha atrás: confirmación → ticket (misma URL)${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E9${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
                await d.tap('market_detail_buy_button');
                await d.esperarUrl(/\/orders\/ticket\//);
                await d.tap('orders_ticket_review_button');
                await d.compararLayout('confirmacion');
                const atras = await accionar(d, 'orders_confirm_back_icon_button', /\/orders\/ticket\//, entrega);
                // Ticket y confirmación comparten URL: en ON se distinguen por la
                // raíz de vista; en OFF, por la captura final contra la de ON.
                const vista = d.on ? ((await d.loc('orders_ticket_view').count()) ? 'ticket' : (await d.loc('orders_confirm_view').count()) ? 'confirmación' : 'otra') : null;
                await cerrar(d, { atras, vista, url: atras.url }, d.on ? { vista: 'ticket' } : {});
            });

            test(`E10 flecha atrás: detalle de orden → órdenes${sufijo}`, async ({ page }, info) => {
                soloOn();
                const d = new Driver(page, info, `E10${entrega === 'locator' ? 'L' : ''}`);
                await cronometro(page);
                await d.abrirConSesion('/activity/orders');
                const primero = await d.memo('primera-orden', async () =>
                    page.locator('[flt-semantics-identifier^="orders_history_item_"][flt-tappable]').first().getAttribute('flt-semantics-identifier') as Promise<string>);
                await d.tap(primero);
                await d.esperarUrl(/\/activity\/orders\/.+/);
                const urlDetalle = ruta(page);
                const atras = await accionar(d, 'orders_detail_back_icon_button', /^\/activity\/orders$/, entrega);
                await cerrar(d, { primero, urlDetalle, atras, url: atras.url }, { url: '/activity/orders' });
            });
        }

        test('E11 botón atrás del navegador con un modal abierto (ticket)', async ({ page }, info) => {
            const d = new Driver(page, info, 'E11');
            await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
            await d.tap('market_detail_buy_button');
            await d.esperarUrl(/\/orders\/ticket\//);
            await d.quieta(3000);
            await page.goBack({ waitUntil: 'commit' }).catch(() => undefined);
            await d.esperarUrl(/\/market\/instrument\/ECOPETROL-CO$/, 5000).catch(() => undefined);
            await page.waitForTimeout(300);
            const url = ruta(page);
            const ticketEnElDom = d.on ? await d.loc('orders_ticket_view').count() : null;
            const reabre = await accionar(d, 'market_detail_buy_button', /\/orders\/ticket\//, 'mouse');
            await cerrar(d, { url, ticketEnElDom, foco: await d.foco(), reabre, urlAlReabrir: reabre.url }, { url: '/market/instrument/ECOPETROL-CO', urlAlReabrir: '/orders/ticket/ECOPETROL-CO/buy' });
        });
    });
}

/**
 * B · Scroll (P4, P6).
 *
 * B1–B8: 10 × wheel(0, 100) con 150 ms entre pasos, con el puntero partiendo
 * desde cada tipo de hijo. Offset por paso:
 *   - en los dos modos, desplazamiento del contenido entre capturas
 *     consecutivas dentro del rectángulo de la zona scrollable;
 *   - en ON, además, `scrollTop` del scrollable del árbol (el padre de
 *     `flt-semantics-scroll-overflow`).
 * Salto = un paso que se aparta más de 50 px de los 100 pedidos.
 */
import { expect, test, type Page } from '@playwright/test';
import { Driver, desplazamiento, ruta, sel, type Box } from '../lib/driver';

const scrollTop = (page: Page, dentroDe: string) =>
    page.evaluate((s) => {
        const raiz = document.querySelector(s);
        const o = (raiz ?? document).querySelector('flt-semantics-scroll-overflow');
        return o && o.parentElement ? o.parentElement.scrollTop : null;
    }, sel(dentroDe));

const rectScroll = (page: Page, dentroDe: string) =>
    page.evaluate((s) => {
        const raiz = document.querySelector(s);
        const o = (raiz ?? document).querySelector('flt-semantics-scroll-overflow');
        if (!o || !o.parentElement) return null;
        const r = o.parentElement.getBoundingClientRect();
        return { x: r.x, y: r.y, width: r.width, height: r.height, max: o.parentElement.scrollHeight - o.parentElement.clientHeight };
    }, sel(dentroDe)) as Promise<(Box & { max: number }) | null>;

async function rueda(d: Driver, vista: string, sobre: string, extra: Record<string, unknown> = {}) {
    const page = d.page;
    const zona = await d.memo(`zona:${vista}`, async () => (await rectScroll(page, vista))!);
    const p = await d.center(sobre);
    await d.compararLayout('antes');
    await page.mouse.move(p.x, p.y);
    await page.waitForTimeout(150);
    let previa = await page.screenshot();
    const pasos: Array<{ dy: number; err: number; top: number | null }> = [];
    const top0 = d.on ? await scrollTop(page, vista) : null;
    for (let i = 0; i < 10; i++) {
        await page.mouse.wheel(0, 100);
        await page.waitForTimeout(150);
        const actual = await page.screenshot();
        const m = desplazamiento(previa, actual, zona);
        pasos.push({ dy: m.dy, err: Math.round(m.err * 100) / 100, top: d.on ? await scrollTop(page, vista) : null });
        previa = actual;
    }
    const dys = pasos.map((x) => x.dy);
    const tops = pasos.map((x) => x.top);
    const total = dys.reduce((a, b) => a + b, 0);
    // Un paso corto seguido solo de ceros es el final del contenido, no un
    // salto; y si nada se movió en los 10 pasos, la zona no scrollea desde ahí.
    const saltos = dys
        .map((dy, i) => ({ i: i + 1, dy }))
        .filter((x, i) => Math.abs(x.dy - 100) > 50 && !(x.dy >= 0 && x.dy < 100 && dys.slice(i + 1).every((v) => v === 0)));
    const noScrollea = total === 0;
    const apagado = await d.sigueApagado();
    await d.registrar({ sobre, punto: p, zona, top0, dys, tops, total, saltos, noScrollea, url: ruta(page), apagado, ...extra });
    if (!d.on) expect(apagado, 'el árbol se encendió: corrida OFF descartada').toBe(true);
    expect(saltos, 'pasos que se apartan más de 50 px de los 100 pedidos').toEqual([]);
}

const MERCADO: Array<[string, string]> = [
    ['B1 /market · sobre un ítem', 'market_list_instrument_item_ECOPETROL-CO'],
    ['B2 /market · sobre el campo de búsqueda', 'market_list_search_field'],
    ['B3 /market · sobre un chip', 'market_list_country_co_chip'],
    ['B4 /market · sobre un texto no interactivo (estado de mercado, dentro de la lista)', 'market_list_status_co_text'],
    ['B4b /market · sobre la barra del título (fuera de la lista)', 'market_list_simulated_text'],
];
for (const [titulo, sobre] of MERCADO) {
    test(titulo, async ({ page }, info) => {
        const d = new Driver(page, info, titulo.split(' ')[0]);
        await d.abrirConSesion('/market');
        await rueda(d, 'market_list_view', sobre);
    });
}

test.describe('390×600', () => {
    test.use({ viewport: { width: 390, height: 600 } });
    for (const [titulo, sobre] of [
        ['B5 /register · sobre el campo nombre', 'auth_register_name_field'],
        ['B5b /register · sobre un texto no interactivo', 'auth_register_requirement_length_text'],
    ]) {
        test(titulo, async ({ page }, info) => {
            const d = new Driver(page, info, titulo.split(' ')[0]);
            await d.abrir('/register');
            await d.tap('auth_login_register_link');
            await d.esperarUrl(/\/register/);
            await d.tap('auth_register_country_co_chip');
            await rueda(d, 'auth_register_view', sobre);
        });
    }
    test('B8 ticket abierto · sobre el campo cantidad', async ({ page }, info) => {
        const d = new Driver(page, info, 'B8');
        await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
        await d.tap('market_detail_buy_button');
        await d.esperarUrl(/\/orders\/ticket\//);
        await rueda(d, 'orders_ticket_view', 'orders_ticket_quantity_field');
    });
});

test('B6 /home · sobre un ítem de "los que más se mueven"', async ({ page }, info) => {
    const d = new Driver(page, info, 'B6');
    await d.abrirConSesion('/home');
    await rueda(d, 'dashboard_home_view', 'dashboard_mover_item_ECOPETROL-CO');
});

test('B7 /activity · sobre un movimiento', async ({ page }, info) => {
    const d = new Driver(page, info, 'B7');
    await d.abrirConSesion('/activity');
    await rueda(d, 'transactions_list_view', 'transactions_list_item_txn_000016');
});

// ---------- P6 ----------

test('B9 latencia del tap sobre un ítem', async ({ page }, info) => {
    const d = new Driver(page, info, 'B9');
    await page.addInitScript(() => {
        const w = window as unknown as { __up: number | null; __nav: number | null };
        w.__up = null;
        w.__nav = null;
        window.addEventListener('pointerup', () => { w.__up = performance.now(); }, true);
        for (const m of ['pushState', 'replaceState'] as const) {
            const orig = history[m];
            history[m] = function (this: History, ...args: Parameters<History['pushState']>) {
                if (w.__up !== null && w.__nav === null && String(args[2] ?? '').includes('/instrument/')) w.__nav = performance.now();
                return orig.apply(this, args);
            } as History['pushState'];
        }
    });
    await d.abrirConSesion('/market');
    const p = await d.center('market_list_instrument_item_ECOPETROL-CO');
    await page.mouse.move(p.x, p.y);
    await page.waitForTimeout(300);
    await page.evaluate(() => { (window as unknown as { __up: null }).__up = null; });
    await page.mouse.down();
    await page.mouse.up();
    await d.esperarUrl(/\/market\/instrument\/ECOPETROL-CO/, 5000).catch(() => undefined);
    const t = await page.evaluate(() => {
        const w = window as unknown as { __up: number | null; __nav: number | null };
        return { up: w.__up, nav: w.__nav };
    });
    const ms = t.up !== null && t.nav !== null ? Math.round((t.nav - t.up) * 10) / 10 : null;
    const apagado = await d.sigueApagado();
    await d.registrar({ msUpANavegacion: ms, url: ruta(page), apagado });
    if (!d.on) expect(apagado).toBe(true);
    expect(ruta(page)).toBe('/market/instrument/ECOPETROL-CO');
});

test.describe('táctil', () => {
    test.use({ hasTouch: true });
    for (const [titulo, sobre] of [
        ['B10 arrastre táctil que empieza sobre un ítem', 'market_list_instrument_item_ISA-CO'],
        ['B10b arrastre táctil que empieza sobre un texto no interactivo', 'market_list_status_pe_text'],
    ]) {
        test(titulo, async ({ page }, info) => {
            const d = new Driver(page, info, titulo.split(' ')[0]);
            await d.abrirConSesion('/market');
            const zona = await d.memo('zona', async () => (await rectScroll(page, 'market_list_view'))!);
            const p = await d.center(sobre);
            const cdp = await page.context().newCDPSession(page);
            const toque = (type: string, y: number) =>
                cdp.send('Input.dispatchTouchEvent', {
                    type: type as 'touchStart',
                    touchPoints: type === 'touchEnd' ? [] : [{ x: Math.round(p.x), y: Math.round(y), id: 1 }],
                });
            let previa = await page.screenshot();
            const t0 = Date.now();
            await toque('touchStart', p.y);
            const pasos: Array<{ t: number; dedo: number; lista: number }> = [];
            let acumulado = 0;
            // 300 px hacia arriba, de a 15 px; una captura por paso (el gesto
            // queda lento, pero igual de lento en los dos modos).
            for (let dedo = 15; dedo <= 300; dedo += 15) {
                await toque('touchMove', p.y - dedo);
                const actual = await page.screenshot();
                acumulado += desplazamiento(previa, actual, zona, 120).dy;
                pasos.push({ t: Date.now() - t0, dedo, lista: acumulado });
                previa = actual;
            }
            await toque('touchEnd', p.y - 300);
            await page.waitForTimeout(700);
            const final = await page.screenshot();
            acumulado += desplazamiento(previa, final, zona, 300).dy;
            const primero = pasos.find((x) => x.lista !== 0) ?? null;
            const apagado = await d.sigueApagado();
            await d.registrar({
                sobre,
                primerMovimiento: primero,
                retencionPx: primero ? primero.dedo - primero.lista : null,
                listaAlSoltar: pasos[pasos.length - 1].lista,
                listaFinal: acumulado,
                msDelGesto: pasos[pasos.length - 1].t,
                pasos,
                url: ruta(page),
                abrioDetalle: /\/instrument\//.test(ruta(page)),
                apagado,
            });
            if (!d.on) expect(apagado).toBe(true);
            expect(ruta(page), 'un arrastre no debe abrir el detalle').toBe('/market');
        });
    }
});

/**
 * F · Sondas dirigidas a los issues de flutter/flutter que los casos A–D no
 * tocan de lleno. Cada test nombra el issue que busca.
 *
 *   F1  #195812 (P1)  click sin eventos de puntero sobre el <input> → ¿tap a un ancestro?
 *   F2  #195291 (P2)  click dentro del propio campo enfocado → ¿se corta el tipeo?
 *   F4  #194549 (P4)  scroll largo que cruza la carga perezosa, y scroll pedido por el DOM
 *   F6  #124191 / ClickDebouncer (P6)  ráfaga de taps → ¿se pierde alguno?
 */
import { expect, test, type Page } from '@playwright/test';
import { Driver, desplazamiento, ruta, sel, type Box } from '../lib/driver';

const soloOn = () => test.skip(test.info().project.name !== 'on', 'no aplica en OFF: no hay nodo que accionar');
const vistas = (page: Page) =>
    page.evaluate(() => [...document.querySelectorAll('[flt-semantics-identifier$="_view"]')].map((e) => e.getAttribute('flt-semantics-identifier')!).sort().join(','));

// ---------------------------------------------------------------- F1 · P1

const PANTALLAS_CON_CAMPOS: Array<[string, (d: Driver) => Promise<void>, string[]]> = [
    ['login', async (d) => { await d.abrir('/login'); }, ['auth_login_email_field', 'auth_login_password_field']],
    ['registro', async (d) => { await d.abrir('/register'); await d.tap('auth_login_register_link'); await d.esperarUrl(/\/register/); await d.tap('auth_register_country_co_chip'); },
        ['auth_register_name_field', 'auth_register_email_field', 'auth_register_document_field', 'auth_register_password_field']],
    ['mercado', async (d) => { await d.abrirConSesion('/market'); }, ['market_list_search_field']],
    ['ticket', async (d) => { await d.abrirConSesion('/market/instrument/ECOPETROL-CO'); await d.tap('market_detail_buy_button'); await d.esperarUrl(/\/orders\/ticket\//); }, ['orders_ticket_quantity_field']],
    ['depósito', async (d) => { await d.abrirConSesion('/wallet'); await d.tap('wallet_cop_deposit_button'); await d.esperarUrl(/\/wallet\/deposit\//); }, ['wallet_deposit_amount_field']],
];

for (const [nombre, preparar, campos] of PANTALLAS_CON_CAMPOS) {
    for (const como of ['el.click()', 'dispatchEvent(click)'] as const) {
        test(`F1 #195812 · ${nombre} · ${como} sobre cada <input>`, async ({ page }, info) => {
            soloOn();
            const d = new Driver(page, info, 'F1');
            await preparar(d);
            await d.quieta(3000);
            const porCampo: Record<string, unknown> = {};
            let huboEfecto = false;
            for (const campo of campos) {
                const input = d.loc(campo).locator('input, textarea').first();
                const ancestrosTappables = await d.loc(campo).evaluate((n) => {
                    const out: string[] = [];
                    for (let a = n.parentElement; a && a.tagName.toLowerCase() === 'flt-semantics'; a = a.parentElement) {
                        if (a.hasAttribute('flt-tappable')) out.push(a.getAttribute('flt-semantics-identifier') ?? a.id);
                    }
                    return out;
                });
                const antes = { url: ruta(page), vistas: await vistas(page), ids: await page.locator('[flt-semantics-identifier]').count() };
                await input.evaluate((el, c) => {
                    if (c === 'el.click()') (el as HTMLElement).click();
                    else el.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true, composed: true }));
                }, como);
                await page.waitForTimeout(500);
                const despues = { url: ruta(page), vistas: await vistas(page), ids: await page.locator('[flt-semantics-identifier]').count() };
                const efecto = antes.url !== despues.url || antes.vistas !== despues.vistas;
                huboEfecto ||= efecto;
                porCampo[campo] = { ancestrosTappables, efecto, antes, despues, foco: await d.foco() };
                if (efecto) break;
            }
            await d.registrar({ pantalla: nombre, entrega: como, porCampo, huboEfecto });
            expect(huboEfecto, 'un click sobre el <input> no debía accionar nada más').toBe(false);
        });
    }
}

// ---------------------------------------------------------------- F2 · P2

const CAMPOS_F2: Array<[string, (d: Driver) => Promise<void>, string, string, string, string]> = [
    // nombre, preparación, campo, primero, después, esperado
    ['login · correo', async (d) => { await d.abrir('/login'); }, 'auth_login_email_field', 'ab', 'c', 'abc'],
    ['mercado · búsqueda', async (d) => { await d.abrirConSesion('/market'); }, 'market_list_search_field', 'ec', 'o', 'eco'],
    ['depósito · monto', async (d) => { await d.abrirConSesion('/wallet'); await d.tap('wallet_cop_deposit_button'); await d.esperarUrl(/\/wallet\/deposit\//); }, 'wallet_deposit_amount_field', '25', '7', '257'],
];
for (const [nombre, preparar, campo, primero, despues, esperado] of CAMPOS_F2) {
    for (const entrega of ['mouse', 'locator'] as const) {
        test(`F2 #195291 · ${nombre} · segundo click dentro del mismo campo (${entrega})`, async ({ page }, info) => {
            test.skip(entrega === 'locator' && info.project.name !== 'on', 'locator.click() solo existe en ON');
            const d = new Driver(page, info, `F2${entrega === 'locator' ? 'L' : ''}`);
            await preparar(d);
            const caja = await d.box(campo);
            // Click a la derecha del texto y lejos del ícono de sufijo: el cursor queda al final.
            const p = { x: caja.x + caja.width * 0.6, y: caja.y + caja.height / 2 };
            await page.mouse.click(p.x, p.y);
            await page.waitForTimeout(500);
            await page.keyboard.type(primero, { delay: 50 });
            const antes = { campo: await d.leer(campo), foco: await d.foco() };
            if (entrega === 'locator') await d.loc(campo).click({ timeout: 5000, position: { x: caja.width * 0.6, y: caja.height / 2 } });
            else await page.mouse.click(p.x, p.y);
            await page.waitForTimeout(300);
            const trasClick = { campo: await d.leer(campo), foco: await d.foco() };
            await page.keyboard.type(despues, { delay: 50 });
            await page.waitForTimeout(300);
            const final = { campo: await d.leer(campo), foco: await d.foco() };
            const apagado = await d.sigueApagado();
            await d.compararLayout('final');
            await d.registrar({ donde: nombre, antes, trasClick, final, apagado });
            if (!d.on) expect(apagado).toBe(true);
            expect(/^\d+$/.test(esperado) ? (final.campo ?? '').replace(/\D/g, '') : final.campo, 'lo tecleado después del segundo click').toBe(esperado);
        });
    }
}

// ---------------------------------------------------------------- F4 · P4

const leerScroll = (page: Page, dentroDe: string) =>
    page.evaluate((s) => {
        const o = (document.querySelector(s) ?? document).querySelector('flt-semantics-scroll-overflow');
        const e = o?.parentElement;
        return e ? { top: e.scrollTop, max: e.scrollHeight - e.clientHeight } : null;
    }, sel(dentroDe));

test('F4a #194549 · /market: 30 pasos de rueda cruzando la carga perezosa, y vuelta', async ({ page }, info) => {
    const d = new Driver(page, info, 'F4a');
    await d.abrirConSesion('/market');
    const zona = await d.memo('zona', async () => page.evaluate((s) => {
        const r = document.querySelector(s)!.querySelector('flt-semantics-scroll-overflow')!.parentElement!.getBoundingClientRect();
        return { x: r.x, y: r.y, width: r.width, height: r.height };
    }, sel('market_list_view'))) as Box;
    const p = await d.center('market_list_instrument_item_ECOPETROL-CO');
    await page.mouse.move(p.x, p.y);
    await page.waitForTimeout(150);
    let previa = await page.screenshot();
    const baja: number[] = [];
    const sube: number[] = [];
    const tops: Array<number | null> = [];
    const maxs: Array<number | null> = [];
    for (const [paso, lista] of [[100, baja], [-100, sube]] as const) {
        for (let i = 0; i < 30; i++) {
            await page.mouse.wheel(0, paso);
            await page.waitForTimeout(150);
            const actual = await page.screenshot();
            lista.push(desplazamiento(previa, actual, zona).dy);
            if (d.on) { const s = await leerScroll(page, 'market_list_view'); tops.push(s?.top ?? null); maxs.push(s?.max ?? null); }
            previa = actual;
        }
    }
    // En ON, el scrollTop del árbol tiene que acompañar a lo que se movió en pantalla.
    let acumulado = 0;
    const desfases: Array<{ i: number; pantalla: number; arbol: number | null }> = [];
    [...baja, ...sube].forEach((dy, i) => {
        acumulado += dy;
        if (d.on && tops[i] !== null && Math.abs((tops[i] as number) - acumulado) > 2) desfases.push({ i: i + 1, pantalla: acumulado, arbol: tops[i] });
    });
    const finDeLista = (l: number[], i: number) => l.slice(i + 1).every((v) => v === 0);
    const saltos = [
        ...baja.map((dy, i) => ({ fase: 'baja', i: i + 1, dy })).filter((x, i) => Math.abs(x.dy - 100) > 50 && !(x.dy >= 0 && finDeLista(baja, i))),
        ...sube.map((dy, i) => ({ fase: 'sube', i: i + 1, dy })).filter((x, i) => Math.abs(x.dy + 100) > 50 && !(x.dy <= 0 && finDeLista(sube, i))),
    ];
    const apagado = await d.sigueApagado();
    await d.registrar({ baja, sube, totalBaja: baja.reduce((a, b) => a + b, 0), totalSube: sube.reduce((a, b) => a + b, 0), tops, maxs: [...new Set(maxs)], desfases, saltos, apagado });
    if (!d.on) expect(apagado).toBe(true);
    expect.soft(desfases, 'scrollTop del árbol vs. lo que se movió en pantalla').toEqual([]);
    expect(saltos, 'pasos que se apartan más de 50 px de los 100 pedidos').toEqual([]);
});

test('F4b #194549 · /market: scroll pedido por el DOM hasta un ítem lejano (scrollIntoViewIfNeeded)', async ({ page }, info) => {
    soloOn();
    const d = new Driver(page, info, 'F4b');
    await d.abrirConSesion('/market');
    await d.quieta(3000);
    const objetivo = 'market_list_instrument_item_BAP-PE';
    const antes = { scroll: await leerScroll(page, 'market_list_view'), caja: await d.loc(objetivo).boundingBox().catch(() => null) };
    const foto0 = await page.screenshot();
    let error: string | null = null;
    await d.loc(objetivo).scrollIntoViewIfNeeded({ timeout: 5000 }).catch((e) => { error = String((e as Error).message).split('\n')[0]; });
    await page.waitForTimeout(600);
    const foto1 = await page.screenshot();
    const zona = await page.evaluate((s) => {
        const r = document.querySelector(s)!.querySelector('flt-semantics-scroll-overflow')!.parentElement!.getBoundingClientRect();
        return { x: r.x, y: r.y, width: r.width, height: r.height };
    }, sel('market_list_view'));
    const enPantalla = desplazamiento(foto0, foto1, zona, 700);
    const despues = { scroll: await leerScroll(page, 'market_list_view'), caja: await d.loc(objetivo).boundingBox().catch(() => null) };
    const v = page.viewportSize()!;
    const visible = !!despues.caja && despues.caja.y >= zona.y - 1 && despues.caja.y + despues.caja.height <= zona.y + zona.height + 1 && despues.caja.y < v.height;
    const pedido = (despues.scroll?.top ?? 0) - (antes.scroll?.top ?? 0);
    // Después, un click normal sobre ese ítem tiene que abrir ESE ítem.
    await d.loc(objetivo).click({ timeout: 5000 }).catch((e) => { error = (error ? error + ' | ' : '') + String((e as Error).message).split('\n')[0]; });
    await d.esperarUrl(/\/market\/instrument\//, 4000).catch(() => undefined);
    await d.registrar({ objetivo, antes, despues, scrollTopSeMovio: pedido, pantallaSeMovio: enPantalla.dy, errEncaje: Math.round(enPantalla.err * 100) / 100, visible, error, urlTrasElClick: ruta(page) });
    expect.soft(Math.abs(pedido - enPantalla.dy), 'el árbol y la pantalla tienen que moverse lo mismo').toBeLessThanOrEqual(2);
    expect.soft(visible, 'el ítem tenía que quedar a la vista').toBe(true);
    expect(ruta(page)).toBe('/market/instrument/BAP-PE');
});

// ---------------------------------------------------------------- F6 · P6

for (const [nombre, entreTaps] of [['30 ms entre taps', 30], ['250 ms entre taps', 250]] as const) {
    test(`F6 #124191 / ClickDebouncer · 10 taps seguidos en el stepper "+" (${nombre})`, async ({ page }, info) => {
        const d = new Driver(page, info, `F6-${entreTaps}`);
        await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
        await d.tap('market_detail_buy_button');
        await d.esperarUrl(/\/orders\/ticket\//);
        const p = await d.center('orders_ticket_quantity_increase_stepper');
        await page.mouse.move(p.x, p.y);
        const t0 = Date.now();
        for (let i = 0; i < 10; i++) {
            await page.mouse.down();
            await page.mouse.up();
            await page.waitForTimeout(entreTaps);
        }
        const msRafaga = Date.now() - t0;
        await page.waitForTimeout(800);
        // La cantidad se lee igual en los dos modos: enfocando el campo.
        await d.tap('orders_ticket_quantity_field');
        await page.waitForTimeout(400);
        const cantidad = await d.leer('orders_ticket_quantity_field');
        const apagado = await d.sigueApagado();
        await d.compararLayout('final');
        await d.registrar({ entreTaps, msRafaga, cantidad, tapsRegistrados: cantidad === null ? null : Number(cantidad) - 1, url: ruta(page), apagado });
        if (!d.on) expect(apagado).toBe(true);
        expect(cantidad, 'cantidad inicial 1 + 10 taps').toBe('11');
    });
}

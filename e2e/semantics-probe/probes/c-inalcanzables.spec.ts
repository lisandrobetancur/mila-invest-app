/**
 * C · P5 — aserción invertida. Solo ON (en OFF no hay nodo que accionar).
 *
 * Se intenta accionar algo que el usuario NO puede alcanzar. El test pasa
 * solo si el intento no produjo efecto. Si el tap funciona, queda rojo: ese
 * rojo es el hallazgo y se reporta tal cual.
 *
 * Tres formas de entrega, por separado:
 *   click        → locator.click()
 *   force        → locator.click({ force: true })
 *   evaluate     → locator.evaluate(el => el.click())
 *
 * Las tres llevan un techo de 5 s: si el nodo no existe o Playwright no logra
 * accionarlo, el error se registra y el caso sigue.
 */
import { expect, test, type Locator, type Page } from '@playwright/test';
import { Driver, activeElement, ruta, sel } from '../lib/driver';

const ENTREGAS = ['click', 'force', 'evaluate'] as const;
type Entrega = (typeof ENTREGAS)[number];

async function entregar(l: Locator, como: Entrega): Promise<string> {
    try {
        if (como === 'click') await l.click({ timeout: 5000 });
        else if (como === 'force') await l.click({ force: true, timeout: 5000 });
        else await l.evaluate((el) => (el as HTMLElement).click(), undefined, { timeout: 5000 });
        return 'entregado sin error';
    } catch (e) {
        const m = String((e as Error).message);
        const pista = m.split('\n').filter((x) => /intercepts|outside of the viewport|not visible|not stable|waiting for|Timeout|detached|scrolling into view/.test(x));
        return `ERROR: ${m.split('\n')[0]}${pista.length ? ' | ' + [...new Set(pista.map((x) => x.trim().replace(/^- /, '')))].slice(0, 4).join(' | ') : ''}`.slice(0, 600);
    }
}

const ids = (page: Page) =>
    page.evaluate(() => [...document.querySelectorAll('[flt-semantics-identifier]')].map((e) => e.getAttribute('flt-semantics-identifier')!));

const soloOn = () => test.skip(test.info().project.name !== 'on', 'no aplica en OFF: no hay nodo que accionar');

for (const como of ENTREGAS) {
    test.describe(`C1 fuera del viewport · ${como}`, () => {
        test(`auth_register_submit_button`, async ({ page }, info) => {
            soloOn();
            const d = new Driver(page, info, 'C1');
            await d.abrir('/register');
            await d.tap('auth_login_register_link');
            await d.esperarUrl(/\/register/);
            const boton = d.loc('auth_register_submit_button');
            // Achicar el alto hasta que el botón quede entero fuera del viewport.
            let alto = 844;
            let caja = await boton.boundingBox();
            for (const h of [844, 700, 600, 560, 520, 480, 440, 400]) {
                alto = h;
                await page.setViewportSize({ width: 390, height: h });
                await d.quieta(2000);
                caja = await boton.boundingBox();
                if (!caja || caja.y >= h) break;
            }
            const fuera = !caja || caja.y >= alto;
            const top = () => page.evaluate(() => document.querySelector('flt-semantics-scroll-overflow')?.parentElement?.scrollTop ?? null);
            const scrollAntes = await top();
            const existe = await boton.count();
            const resultado = await entregar(boton, como);
            await page.waitForTimeout(800);
            const scrollDespues = await top();
            const errores = (await ids(page)).filter((i) => /_error_text$/.test(i));
            const cajaDespues = await boton.boundingBox().catch(() => null);
            await d.registrar({ entrega: como, alto, caja, fuera, existe, resultado, scrollAntes, scrollDespues, cajaDespues, errores });
            expect(fuera, 'el botón tenía que quedar fuera del viewport').toBe(true);
            expect(errores, 'el tap sobre un botón fuera del viewport no debía validar el formulario').toEqual([]);
        });
    });

    for (const [caso, vp, objetivos] of [
        ['C2', { width: 390, height: 844 }, ['market_detail_sell_button', 'nav_market_tab']],
        ['C3', { width: 1280, height: 800 }, ['nav_market_tab', 'nav_home_tab']],
    ] as const) {
        test.describe(`${caso} debajo del ticket (${vp.width}×${vp.height}) · ${como}`, () => {
            test.use({ viewport: vp });
            for (const objetivo of objetivos) {
                test(objetivo, async ({ page }, info) => {
                    soloOn();
                    const d = new Driver(page, info, caso);
                    await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
                    const cajaSinModal = await d.loc(objetivo).boundingBox();
                    await d.tap('market_detail_buy_button');
                    await d.loc('orders_ticket_view').waitFor();
                    await d.quieta(3000);
                    const url0 = ruta(page);
                    const presentes = await ids(page);
                    const existe = await d.loc(objetivo).count();
                    const resultado = await entregar(d.loc(objetivo), como);
                    await page.waitForTimeout(800);
                    const ticketSigue = (await d.loc('orders_ticket_view').count()) > 0;
                    await d.registrar({ entrega: como, objetivo, existe, cajaSinModal, resultado, ticketSigue, url0, url: ruta(page), idsConModal: presentes, fueraDelModal: presentes.filter((i) => !/^orders_/.test(i)) });
                    expect(ticketSigue, 'el ticket tenía que seguir abierto').toBe(true);
                    expect(ruta(page)).toBe(url0);
                });
            }
        });
    }

    test.describe(`C4 debajo del diálogo de cerrar sesión · ${como}`, () => {
        test('settings_theme_dark_segment', async ({ page }, info) => {
            soloOn();
            const d = new Driver(page, info, 'C4');
            await d.abrirConSesion('/home');
            await d.tap('dashboard_home_settings_icon_button');
            await d.esperarUrl(/\/settings/);
            const cajaSinModal = await d.loc('settings_theme_dark_segment').boundingBox();
            await d.tap('settings_logout_button');
            await d.loc('settings_logout_dialog').waitFor();
            const antes = await d.quieta(3000);
            const presentes = await ids(page);
            const existe = await d.loc('settings_theme_dark_segment').count();
            const resultado = await entregar(d.loc('settings_theme_dark_segment'), como);
            await page.waitForTimeout(800);
            const despues = await d.quieta(3000);
            const { diffRatio } = await import('../lib/driver');
            const cambioDePantalla = diffRatio(antes, despues);
            const dialogoSigue = (await d.loc('settings_logout_dialog').count()) > 0;
            await d.registrar({ entrega: como, existe, cajaSinModal, resultado, dialogoSigue, cambioDePantalla, url: ruta(page), idsConModal: presentes, fueraDelModal: presentes.filter((i) => !/^settings_logout_/.test(i)) });
            expect(dialogoSigue, 'el diálogo tenía que seguir abierto').toBe(true);
            expect(cambioDePantalla, 'el tema no tenía que cambiar').toBeLessThan(0.01);
        });
    });

    test.describe(`C5 debajo del snackbar del depósito · ${como}`, () => {
        test('el tappable que se solape', async ({ page }, info) => {
            soloOn();
            const d = new Driver(page, info, 'C5');
            await d.abrirConSesion('/wallet');
            await d.tap('wallet_cop_deposit_button');
            await d.esperarUrl(/\/wallet\/deposit\//);
            await d.tap('wallet_deposit_suggested_item_1000000');
            await d.tap('wallet_deposit_submit_button');
            const t0 = Date.now();
            await d.loc('wallet_deposit_success_snackbar').waitFor({ timeout: 10_000 });
            await page.waitForTimeout(400);
            const info0 = await page.evaluate((s) => {
                const sb = document.querySelector(s)!.getBoundingClientRect();
                const corta = (r: DOMRect) => r.left < sb.right && r.right > sb.left && r.top < sb.bottom && r.bottom > sb.top;
                const todos = [...document.querySelectorAll('[flt-tappable][flt-semantics-identifier]')].map((e) => {
                    const r = e.getBoundingClientRect();
                    return { id: e.getAttribute('flt-semantics-identifier')!, r: [r.x, r.y, r.width, r.height].map(Math.round), solapa: corta(r) };
                });
                return { snackbar: [sb.x, sb.y, sb.width, sb.height].map(Math.round), tappables: todos };
            }, sel('wallet_deposit_success_snackbar'));
            const solapados = info0.tappables.filter((t) => t.solapa).map((t) => t.id);
            const url0 = ruta(page);
            const ids0 = await ids(page);
            let resultado = 'ningún tappable con id se solapa con el snackbar';
            let snackbarVisibleAlEntregar: boolean | null = null;
            if (solapados.length) {
                snackbarVisibleAlEntregar = (await d.loc('wallet_deposit_success_snackbar').count()) > 0;
                resultado = await entregar(d.loc(solapados[0]), como);
            }
            const msDesdeElSnackbar = Date.now() - t0;
            await page.waitForTimeout(800);
            const ids1 = await ids(page);
            const vistas = (l: string[]) => l.filter((i) => /_view$/.test(i)).sort().join(',');
            const efecto = ruta(page) !== url0 || vistas(ids0) !== vistas(ids1);
            await d.registrar({ entrega: como, ...info0, solapados, objetivo: solapados[0] ?? null, snackbarVisibleAlEntregar, msDesdeElSnackbar, resultado, url0, url: ruta(page), vistasAntes: vistas(ids0), vistasDespues: vistas(ids1), efecto });
            expect(efecto, 'la acción del control tapado por el snackbar no debía ocurrir').toBe(false);
        });
    });
}

// C6 es directo, no invertido: el toggle debe actuar y el campo no recibir el click.
test('C6 superposición: mouse real en el centro del toggle de contraseña', async ({ page }, info) => {
    const d = new Driver(page, info, 'C6');
    await d.abrir('/login');
    await d.tap('auth_login_password_field');
    await page.waitForTimeout(500);
    await page.keyboard.type('abc', { delay: 50 });
    const antes = await activeElement(page);
    const campo = await d.box('auth_login_password_field');
    const p = await d.center('auth_login_password_toggle');
    const fotoAntes = await page.screenshot({ clip: { x: campo.x, y: campo.y, width: campo.width - 60, height: campo.height } });
    await page.mouse.click(p.x, p.y);
    await page.waitForTimeout(400);
    const despues = await activeElement(page);
    const fotoDespues = await page.screenshot({ clip: { x: campo.x, y: campo.y, width: campo.width - 60, height: campo.height } });
    const { diffRatio } = await import('../lib/driver');
    const textoCambioEnPantalla = diffRatio(fotoAntes, fotoDespues) > 0;
    const tipoDelInput = d.on ? await d.loc('auth_login_password_field').locator('input').getAttribute('type') : null;
    const apagado = await d.sigueApagado();
    await d.compararLayout('final');
    await d.registrar({ focoAntes: antes, focoDespues: despues, tipoDelInput, textoCambioEnPantalla, apagado });
    if (!d.on) expect(apagado).toBe(true);
    if (d.on) expect(tipoDelInput, 'el toggle debía mostrar la contraseña').toBe('text');
    expect(textoCambioEnPantalla, 'el toggle debía actuar (el texto del campo cambia en pantalla)').toBe(true);
});

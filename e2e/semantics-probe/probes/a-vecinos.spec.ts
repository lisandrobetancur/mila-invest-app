/**
 * A6–A10 · Foco (P2): campo enfocado con texto a medio escribir → click en el
 * control vecino → seguir tecleando. Se registra `activeElement` antes y
 * después, y si lo tecleado entra al campo.
 *
 * Entre el click al campo y la primera tecla se esperan 500 ms y se teclea a
 * 50 ms por tecla: así lo que se mide acá es el foco (P2) y no la pérdida de
 * las primeras teclas (P3), que se mide en a-campos.
 */
import { expect, test } from '@playwright/test';
import { Driver, ruta } from '../lib/driver';

const TECLA = { delay: 50 };

interface Paso { campo: string | null; foco: string }

async function vecino(d: Driver, campo: string, previo: string, vecinoId: string, extra: string[] = ['x']) {
    const page = d.page;
    await d.tap(campo);
    await page.waitForTimeout(500);
    await page.keyboard.type(previo, TECLA);
    const antes: Paso = { campo: await d.leer(campo), foco: await d.foco() };
    const tipoAntes = d.on ? await d.loc(campo).locator('input').getAttribute('type') : undefined;
    await d.tap(vecinoId, { espera: false });
    await page.waitForTimeout(300);
    const trasClick: Paso = { campo: await d.leer(campo), foco: await d.foco() };
    const tipoDespues = d.on ? await d.loc(campo).locator('input').getAttribute('type').catch(() => null) : undefined;
    const tecleado: Record<string, Paso> = {};
    for (const t of extra) {
        await page.keyboard.type(t, TECLA);
        await page.waitForTimeout(200);
        tecleado[t] = { campo: await d.leer(campo), foco: await d.foco() };
    }
    const apagado = await d.sigueApagado();
    await d.compararLayout('final');
    await d.registrar({ campo, vecino: vecinoId, previo, antes, tipoAntes, trasClick, tipoDespues, tecleado, url: ruta(page), apagado });
    if (!d.on) expect(apagado, 'el árbol se encendió: corrida OFF descartada').toBe(true);
}

test('A6 login: contraseña → toggle', async ({ page }, info) => {
    const d = new Driver(page, info, 'A6');
    await d.abrir('/login');
    await vecino(d, 'auth_login_password_field', 'abc', 'auth_login_password_toggle');
});

test('A7 registro: contraseña → toggle', async ({ page }, info) => {
    const d = new Driver(page, info, 'A7');
    await d.abrir('/register');
    await d.tap('auth_login_register_link');
    await d.esperarUrl(/\/register/);
    await vecino(d, 'auth_register_password_field', 'abc', 'auth_register_password_toggle');
});

test('A8 búsqueda → botón limpiar', async ({ page }, info) => {
    const d = new Driver(page, info, 'A8');
    await d.abrirConSesion('/market');
    await d.tap('market_list_search_field');
    await page.waitForTimeout(500);
    await page.keyboard.type('eco', TECLA);
    await d.esperarUrl(/q=eco/);
    const antes = { campo: await d.leer('market_list_search_field'), foco: await d.foco() };
    await d.tap('market_list_search_clear_icon_button');
    await page.waitForTimeout(300);
    const trasClick = { campo: await d.leer('market_list_search_field'), foco: await d.foco(), url: ruta(page) };
    await page.keyboard.type('x', TECLA);
    await page.waitForTimeout(800);
    const trasX = { campo: await d.leer('market_list_search_field'), foco: await d.foco(), url: ruta(page) };
    const apagado = await d.sigueApagado();
    await d.compararLayout('final');
    await d.registrar({ antes, trasClick, trasX, apagado });
    if (!d.on) expect(apagado).toBe(true);
});

for (const cual of ['increase', 'decrease'] as const) {
    test(`A9 ticket: cantidad → stepper ${cual}`, async ({ page }, info) => {
        const d = new Driver(page, info, `A9-${cual}`);
        await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
        await d.tap('market_detail_buy_button');
        await d.esperarUrl(/\/orders\/ticket\//);
        // `x` no es un dígito: el campo podría filtrarla en cualquier modo, así
        // que después se teclea también `7`.
        await vecino(d, 'orders_ticket_quantity_field', '5', `orders_ticket_quantity_${cual}_stepper`, ['x', '7']);
    });
}

test('A10 depósito: monto → sugerido 1.000.000', async ({ page }, info) => {
    const d = new Driver(page, info, 'A10');
    await d.abrirConSesion('/wallet');
    await d.tap('wallet_cop_deposit_button');
    await d.esperarUrl(/\/wallet\/deposit\//);
    await vecino(d, 'wallet_deposit_amount_field', '25', 'wallet_deposit_suggested_item_1000000', ['x', '7']);
});

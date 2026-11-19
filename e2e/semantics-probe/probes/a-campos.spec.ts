/**
 * A · Campos de texto (P3, P2).
 *
 * Cada caso se repite con 0/50/100/250/500 ms entre el click y la primera
 * tecla, y con `keyboard.type` a 0 y 50 ms por tecla. Las esperas son el dato
 * que se mide: no son arreglos.
 */
import { expect, test } from '@playwright/test';
import { Driver, ruta } from '../lib/driver';

const GAPS = [0, 50, 100, 250, 500];
const DELAYS = [0, 50];
const EMAIL = 'demo@milainvest.app';
const PASS = 'Demo1234!';

for (const gap of GAPS) for (const delay of DELAYS) {
    const v = `gap=${gap} delay=${delay}`;

    test(`A1 login · ${v}`, async ({ page }, info) => {
        const d = new Driver(page, info, 'A1');
        await d.abrir('/login');
        await d.compararLayout('login');
        await d.tap('auth_login_email_field');
        const focoTrasClick = await d.foco();
        await page.waitForTimeout(gap);
        await page.keyboard.type(EMAIL, { delay });
        const email = await d.leer('auth_login_email_field');
        const focoTrasEmail = await d.foco();
        await page.keyboard.press('Enter');
        await page.keyboard.type(PASS, { delay });
        const focoTrasPass = await d.foco();
        const pass = await d.leer('auth_login_password_field');
        const emailFinal = d.on ? await d.leer('auth_login_email_field') : undefined;
        await page.keyboard.press('Enter');
        await d.esperarUrl(/\/home/, 5000).catch(() => undefined);
        const apagado = await d.sigueApagado();
        await d.registrar({ gap, delay, email, emailFinal, pass, focoTrasClick, focoTrasEmail, focoTrasPass, url: ruta(page), apagado });
        if (!d.on) expect(apagado, 'el árbol se encendió: corrida OFF descartada').toBe(true);
        expect.soft(email).toBe(EMAIL);
        expect.soft(pass).toBe(PASS);
        expect(ruta(page)).toBe('/home');
    });

  for (const gapEnter of [false, true]) {
    if (gapEnter && gap === 0) continue;
    test(`A2 registro · ${v}${gapEnter ? ' · gap también tras cada Enter' : ''}`, async ({ page }, info) => {
        const d = new Driver(page, info, 'A2');
        const datos = { name: 'Ana Prueba', email: 'ana.prueba@example.com', document: '1020304050', password: 'Clave1234' };
        await d.abrir('/register');
        await d.tap('auth_login_register_link');
        await d.esperarUrl(/\/register/);
        await d.compararLayout('register');
        await d.tap('auth_register_country_co_chip');
        await d.tap('auth_register_name_field');
        const focos: string[] = [await d.foco()];
        const leido: Record<string, string | null> = {};
        const focosTrasEnter: string[] = [];
        await page.waitForTimeout(gap);
        const campos = ['name', 'email', 'document', 'password'] as const;
        for (const c of campos) {
            await page.keyboard.type(datos[c], { delay });
            // OFF: lo único legible es el input con foco, sea del campo que sea.
            leido[c] = d.on ? null : await d.leer(`auth_register_${c}_field`);
            focos.push(await d.foco());
            if (c !== 'password') {
                await page.keyboard.press('Enter');
                focosTrasEnter.push(await d.foco());
                if (gapEnter) await page.waitForTimeout(gap);
            }
        }
        const apagado = await d.sigueApagado();
        // ON: valor de cada campo por su id. OFF: solo se puede leer el input
        // con foco, así que el dato es lo que había en el input enfocado al
        // terminar de teclear cada campo (la lectura post-mortem no trae valores).
        const final: Record<string, string | null> = {};
        for (const c of campos) final[c] = d.on ? await d.valorDe(`auth_register_${c}_field`) : leido[c];
        await d.compararLayout('registro-final');
        await d.registrar({ gap, delay, gapEnter, final, focos, focosTrasEnter, url: ruta(page), apagado });
        if (!d.on) expect(apagado, 'el árbol se encendió: corrida OFF descartada').toBe(true);
        for (const c of campos) expect.soft(final[c], c).toBe(datos[c]);
    });
  }

    test(`A3 búsqueda · ${v}`, async ({ page }, info) => {
        const d = new Driver(page, info, 'A3');
        await d.abrirConSesion('/market');
        await d.compararLayout('market');
        await d.tap('market_list_search_field');
        const focoTrasClick = await d.foco();
        await page.waitForTimeout(gap);
        await page.keyboard.type('eco', { delay });
        const lecturas: Record<string, unknown> = {};
        const t0 = Date.now();
        for (const t of [0, 400, 1000]) {
            await page.waitForTimeout(Math.max(0, t - (Date.now() - t0)));
            lecturas[`+${t}`] = { campo: await d.leer('market_list_search_field'), url: ruta(page), foco: await d.foco() };
        }
        const apagado = await d.sigueApagado();
        await d.registrar({ gap, delay, focoTrasClick, lecturas, apagado });
        if (!d.on) expect(apagado).toBe(true);
        expect.soft((lecturas['+1000'] as { campo: string }).campo).toBe('eco');
        expect(ruta(page)).toBe('/market?q=eco');
    });

    test(`A3b búsqueda con pausa (control) · ${v}`, async ({ page }, info) => {
        const d = new Driver(page, info, 'A3b');
        await d.abrirConSesion('/market');
        await d.tap('market_list_search_field');
        await page.waitForTimeout(gap);
        await page.keyboard.type('grupo ', { delay });
        const antesDeLaPausa = await d.leer('market_list_search_field');
        await page.waitForTimeout(500);
        const trasLaPausa = await d.leer('market_list_search_field');
        const urlTrasLaPausa = ruta(page);
        await page.keyboard.type('aval', { delay });
        const alTerminar = await d.leer('market_list_search_field');
        await page.waitForTimeout(1000);
        const final = await d.leer('market_list_search_field');
        const apagado = await d.sigueApagado();
        await d.registrar({ gap, delay, antesDeLaPausa, trasLaPausa, urlTrasLaPausa, alTerminar, final, foco: await d.foco(), url: ruta(page), apagado });
        if (!d.on) expect(apagado).toBe(true);
        expect(final).toBe('grupo aval');
    });

    test(`A4 depósito · ${v}`, async ({ page }, info) => {
        const d = new Driver(page, info, 'A4');
        await d.abrirConSesion('/wallet');
        await d.tap('wallet_cop_deposit_button');
        await d.esperarUrl(/\/wallet\/deposit\//);
        const msHastaElClick = await d.tapYa('wallet_deposit_amount_field');
        const focoTrasClick = await d.foco();
        await page.waitForTimeout(gap);
        await page.keyboard.type('250000', { delay });
        const alTerminar = await d.leer('wallet_deposit_amount_field');
        const focoAlTerminar = await d.foco();
        await page.waitForTimeout(600);
        const final = await d.leer('wallet_deposit_amount_field');
        const apagado = await d.sigueApagado();
        await d.compararLayout('deposito-con-monto');
        await d.registrar({ gap, delay, msHastaElClick, focoTrasClick, alTerminar, focoAlTerminar, final, foco: await d.foco(), url: ruta(page), apagado });
        if (!d.on) expect(apagado).toBe(true);
        expect((final ?? '').replace(/\D/g, '')).toBe('250000');
    });

    test(`A5 ticket · ${v}`, async ({ page }, info) => {
        const d = new Driver(page, info, 'A5');
        await d.abrirConSesion('/market/instrument/ECOPETROL-CO');
        await d.tap('market_detail_buy_button');
        await d.esperarUrl(/\/orders\/ticket\//);
        const msHastaElClick = await d.tapYa('orders_ticket_quantity_field');
        const focoTrasClick = await d.foco();
        const antes = await d.leer('orders_ticket_quantity_field');
        await page.waitForTimeout(gap);
        await page.keyboard.press('ControlOrMeta+A');
        await page.keyboard.type('12', { delay });
        const alTerminar = await d.leer('orders_ticket_quantity_field');
        const focoAlTerminar = await d.foco();
        await page.waitForTimeout(600);
        const final = await d.leer('orders_ticket_quantity_field');
        const apagado = await d.sigueApagado();
        await d.compararLayout('ticket-con-cantidad');
        await d.registrar({ gap, delay, msHastaElClick, focoTrasClick, antes, alTerminar, focoAlTerminar, final, foco: await d.foco(), url: ruta(page), apagado });
        if (!d.on) expect(apagado).toBe(true);
        expect(final).toBe('12');
    });
}

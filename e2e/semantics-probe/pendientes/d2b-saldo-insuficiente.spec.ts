/**
 * D2b · Completa el inventario de D2: el aviso de saldo insuficiente del
 * ticket. En D2 se tecleó una cantidad mayor al máximo (1.000.000) y salió el
 * error de validación del campo en lugar del aviso. Acá la cantidad es válida
 * pero cuesta más que el saldo. Solo ON, una pasada.
 */
import { expect, test } from '@playwright/test';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { sel } from '../lib/driver';

test('D2b ids del ticket con saldo insuficiente', async ({ page }, info) => {
    test.skip(info.project.name !== 'on' || info.repeatEachIndex > 0, 'inventario: solo ON, una pasada');
    const L = (id: string) => page.locator(sel(id)).first();
    await page.goto('/market/instrument/ECOPETROL-CO');
    await L('onboarding_skip_button').click();
    await L('auth_login_demo_button').click();
    await L('auth_login_submit_button').click();
    await L('market_detail_buy_button').click();
    await L('orders_ticket_view').waitFor();
    const porCantidad: Record<string, string[]> = {};
    for (const cantidad of ['5000', '100000', '900000']) {
        await L('orders_ticket_quantity_field').click();
        await page.waitForTimeout(500);
        await page.keyboard.press('ControlOrMeta+A');
        await page.keyboard.type(cantidad, { delay: 50 });
        await page.waitForTimeout(1500);
        porCantidad[cantidad] = await page.evaluate(() => [...document.querySelectorAll('[flt-semantics-identifier]')].map((e) => e.getAttribute('flt-semantics-identifier')!));
    }
    const dir = process.env.PROBE_RESULTS ? path.resolve(__dirname, '..', process.env.PROBE_RESULTS) : path.resolve(__dirname, '..', 'results');
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'D2b.json'), JSON.stringify(porCantidad, null, 1));
    const todos = new Set(Object.values(porCantidad).flat());
    expect.soft([...todos]).toContain('orders_ticket_low_balance_text');
    expect.soft([...todos]).toContain('orders_ticket_deposit_button');
});

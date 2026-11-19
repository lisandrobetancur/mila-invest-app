/**
 * Driver común a los dos modos.
 *
 * ON : localiza por `[flt-semantics-identifier]`, toma el centro del
 *      boundingBox y acciona con `page.mouse` (el mismo gesto físico que OFF).
 *      Guarda cada coordenada en `.coords/`.
 * OFF: no hay ids. Usa las coordenadas que dejó la corrida ON del mismo caso,
 *      viewport y paso. Nunca toca `flt-semantics-placeholder`.
 */
import { expect, type Locator, type Page, type TestInfo } from '@playwright/test';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { PNG } from 'pngjs';

export type Mode = 'on' | 'off';
export interface Point { x: number; y: number }
export interface Box { x: number; y: number; width: number; height: number }

const ROOT = path.resolve(__dirname, '..');
const COORDS = path.join(ROOT, '.coords');
const RESULTS = process.env.PROBE_RESULTS ? path.resolve(ROOT, process.env.PROBE_RESULTS) : path.join(ROOT, 'results');

export const sel = (id: string): string => `[flt-semantics-identifier="${id}"]`;

/** Diferencia entre dos PNG del mismo tamaño: fracción de píxeles distintos. */
export function diffRatio(a: Buffer, b: Buffer): number {
    const pa = PNG.sync.read(a);
    const pb = PNG.sync.read(b);
    if (pa.width !== pb.width || pa.height !== pb.height) return 1;
    let distintos = 0;
    for (let i = 0; i < pa.data.length; i += 4) {
        const d =
            Math.abs(pa.data[i] - pb.data[i]) +
            Math.abs(pa.data[i + 1] - pb.data[i + 1]) +
            Math.abs(pa.data[i + 2] - pb.data[i + 2]);
        if (d > 48) distintos++;
    }
    return distintos / (pa.width * pa.height);
}

/** `document.activeElement`, bajando por shadow roots. */
export async function activeElement(page: Page): Promise<Record<string, unknown>> {
    return page.evaluate(() => {
        let el: Element | null = document.activeElement;
        while (el && (el as HTMLElement).shadowRoot && (el as HTMLElement).shadowRoot!.activeElement) {
            el = (el as HTMLElement).shadowRoot!.activeElement;
        }
        if (!el) return { tag: null };
        const input = el as HTMLInputElement;
        const host = el.closest('[flt-semantics-identifier]');
        return {
            tag: el.tagName.toLowerCase(),
            cls: el.getAttribute('class') ?? '',
            type: el.getAttribute('type'),
            value: 'value' in input ? input.value : undefined,
            sel: 'selectionStart' in input ? [input.selectionStart, input.selectionEnd] : undefined,
            id: host ? host.getAttribute('flt-semantics-identifier') : null,
        };
    });
}

export class Driver {
    readonly mode: Mode;
    readonly vp: string;
    private paso = 0;
    private pendientes: Array<[string, string]> = [];
    private coords: Record<string, Box> = {};
    private readonly coordsFile: string;
    /** Capturas ON/OFF comparadas en este test: clave → fracción distinta. */
    readonly layout: Record<string, number> = {};

    constructor(readonly page: Page, readonly info: TestInfo, readonly caso: string) {
        this.mode = info.project.name as Mode;
        const v = page.viewportSize()!;
        this.vp = `${v.width}x${v.height}`;
        const slug = `${caso}__${this.vp}`.replace(/[^\w.-]+/g, '_');
        this.coordsFile = path.join(COORDS, `${slug}.json`);
        if (this.mode === 'off') {
            if (!fs.existsSync(this.coordsFile)) {
                throw new Error(`Faltan coordenadas ON para ${slug}: correr antes el proyecto "on".`);
            }
            this.coords = JSON.parse(fs.readFileSync(this.coordsFile, 'utf8'));
        }
    }

    get on(): boolean { return this.mode === 'on'; }
    loc(id: string): Locator { return this.page.locator(sel(id)); }

    private persist(): void {
        fs.mkdirSync(COORDS, { recursive: true });
        const previas = fs.existsSync(this.coordsFile) ? JSON.parse(fs.readFileSync(this.coordsFile, 'utf8')) : {};
        fs.writeFileSync(this.coordsFile, JSON.stringify({ ...previas, ...this.coords }, null, 1));
    }

    /** Espera a que la pantalla deje de cambiar (dos capturas iguales seguidas). */
    async quieta(maxMs = 8000): Promise<Buffer> {
        const fin = Date.now() + maxMs;
        let previa = await this.page.screenshot();
        for (;;) {
            await this.page.waitForTimeout(120);
            const actual = await this.page.screenshot();
            if (diffRatio(previa, actual) === 0 || Date.now() > fin) return actual;
            previa = actual;
        }
    }

    /**
     * Caja de un objetivo. ON: la mide (esperando a que sea visible) y la
     * guarda. OFF: la lee de lo que dejó ON para el mismo paso.
     */
    async box(id: string, opts: { espera?: boolean } = {}): Promise<Box> {
        const clave = `${this.paso++}:${id}`;
        if (this.on) {
            const l = this.loc(id).first();
            await l.waitFor({ state: 'visible', timeout: 15_000 });
            if (opts.espera !== false) await this.quieta(3000);
            const b = await l.boundingBox();
            if (!b) throw new Error(`Sin boundingBox: ${id}`);
            this.coords[clave] = b;
            this.persist();
            return b;
        }
        const b = this.coords[clave];
        if (!b) throw new Error(`Sin coordenadas ON para el paso ${clave}`);
        if (opts.espera !== false) await this.quieta(3000);
        return b;
    }

    async center(id: string, opts: { espera?: boolean } = {}): Promise<Point> {
        const b = await this.box(id, opts);
        return { x: b.x + b.width / 2, y: b.y + b.height / 2 };
    }

    /** Click de mouse real en el centro del objetivo. */
    async tap(id: string, opts: { espera?: boolean } = {}): Promise<Point> {
        const p = await this.center(id, opts);
        await this.page.mouse.click(p.x, p.y);
        return p;
    }

    /**
     * "Apenas aparece": acciona el objetivo sin esperas propias.
     * ON : `locator.click()` de Playwright (espera a que el nodo exista y esté
     *      quieto, que es lo que hace una suite). La caja asentada se guarda
     *      al cerrar el test, para OFF.
     * OFF: no hay nodo que esperar; se espera a que la pantalla deje de
     *      cambiar y se hace click en la coordenada asentada de ON.
     * Devuelve los ms que pasaron hasta que el click salió.
     */
    async tapYa(id: string): Promise<number> {
        const clave = `${this.paso++}:${id}`;
        const t0 = Date.now();
        if (this.on) {
            await this.loc(id).first().click({ timeout: 15_000 });
            this.pendientes.push([clave, id]);
            return Date.now() - t0;
        }
        const b = this.coords[clave];
        if (!b) throw new Error(`Sin coordenadas ON para el paso ${clave}`);
        await this.quieta(5000);
        await this.page.mouse.click(b.x + b.width / 2, b.y + b.height / 2);
        return Date.now() - t0;
    }

    /** Dato que ON mide y OFF reutiliza (rectángulos de scroll, etc.). */
    async memo<T>(clave: string, medir: () => Promise<T>): Promise<T> {
        const k = `memo:${clave}`;
        if (this.on) {
            const v = await medir();
            (this.coords as Record<string, unknown>)[k] = v;
            this.persist();
            return v;
        }
        const v = (this.coords as Record<string, unknown>)[k];
        if (v === undefined) throw new Error(`Sin dato ON para ${k}`);
        return v as T;
    }

    /**
     * Compara la pantalla actual contra la que dejó ON en este punto.
     * ON la guarda; OFF la compara y devuelve la fracción de píxeles distintos.
     */
    async compararLayout(nombre: string): Promise<number> {
        const file = path.join(COORDS, `${this.caso}__${this.vp}__${nombre}.png`.replace(/[^\w.-]+/g, '_'));
        const shot = await this.quieta();
        if (this.on) {
            fs.writeFileSync(file, shot);
            this.layout[nombre] = 0;
            return 0;
        }
        const ratio = fs.existsSync(file) ? diffRatio(fs.readFileSync(file), shot) : 1;
        this.layout[nombre] = ratio;
        fs.writeFileSync(file.replace(/\.png$/, '.off.png'), shot);
        await this.info.attach(`layout-${nombre}-off`, { body: shot, contentType: 'image/png' });
        return ratio;
    }

    /** OFF: el árbol tiene que seguir apagado. Devuelve `true` si sigue OFF. */
    async sigueApagado(): Promise<boolean> {
        return this.page.evaluate(() => document.querySelector('flt-semantics') === null);
    }

    /** Enciende el árbol activando el placeholder. SOLO como último paso. */
    async postMortem(): Promise<void> {
        await this.page.evaluate(() => {
            const p = document.querySelector('flt-semantics-placeholder') as HTMLElement | null;
            p?.click();
        });
        await this.page.waitForSelector('flt-semantics', { state: 'attached', timeout: 5000 }).catch(() => undefined);
        await this.page.waitForTimeout(300);
    }

    /** Valor del `<input>` de un campo (ON, o post-mortem en OFF). */
    async valorDe(id: string): Promise<string | null> {
        return this.page.evaluate((s) => {
            const n = document.querySelector(s);
            if (!n) return null;
            const i = (n.matches('input,textarea') ? n : n.querySelector('input,textarea')) as HTMLInputElement | null;
            return i ? i.value : `[sin input] ${n.getAttribute('aria-label') ?? n.textContent ?? ''}`;
        }, sel(id));
    }

    /**
     * Texto de un campo sin encender el árbol. ON: el `<input>` del nodo.
     * OFF: el `value` del `<input class="flt-text-editing">` si tiene el foco;
     * si no lo tiene, no hay forma de leerlo con el árbol apagado → `null`.
     */
    async leer(id: string): Promise<string | null> {
        if (this.on) return this.valorDe(id);
        const a = await activeElement(this.page);
        return a.tag === 'input' || a.tag === 'textarea' ? (a.value as string) : null;
    }

    /** Resumen corto de `document.activeElement`. */
    async foco(): Promise<string> {
        const a = await activeElement(this.page);
        const cls = String(a.cls ?? '').split(' ')[0];
        return `${a.tag}${cls ? '.' + cls : ''}${a.type ? `[type=${a.type}]` : ''}${a.id ? `#${a.id}` : ''}`;
    }

    /** Deja una fila de medición en `results/<caso>.jsonl`. */
    async registrar(datos: Record<string, unknown>): Promise<void> {
        for (const [clave, id] of this.pendientes) {
            await this.quieta(3000);
            const b = await this.loc(id).first().boundingBox().catch(() => null);
            if (b) this.coords[clave] = b;
        }
        if (this.pendientes.length) this.persist();
        this.pendientes = [];
        fs.mkdirSync(RESULTS, { recursive: true });
        const fila = {
            caso: this.caso,
            test: this.info.title,
            mode: this.mode,
            vp: this.vp,
            rep: this.info.repeatEachIndex,
            layout: this.layout,
            ...datos,
        };
        fs.appendFileSync(path.join(RESULTS, `${this.caso.replace(/\d.*$/, '')}.jsonl`), JSON.stringify(fila) + '\n');
    }

    // ---------- navegación común (mismos gestos en ON y OFF) ----------

    /** `/ruta` con contexto nuevo: onboarding → saltar → login. */
    async abrir(ruta: string): Promise<void> {
        await this.page.goto(ruta);
        await this.esperarUrl(/\/onboarding/);
        await this.tap('onboarding_skip_button');
        await this.esperarUrl(/\/login/);
    }

    /** Entra con la cuenta demo sin teclear (botón demo + submit). */
    async loginDemo(destino: RegExp = /\/home/): Promise<void> {
        await this.tap('auth_login_demo_button');
        await this.tap('auth_login_submit_button');
        await this.esperarUrl(destino);
    }

    /** Abre una ruta protegida: queda estacionada y el login vuelve a ella. */
    async abrirConSesion(ruta: string): Promise<void> {
        await this.abrir(ruta);
        const esc = ruta.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        await this.loginDemo(new RegExp(esc + '($|\\?)'));
    }

    async esperarUrl(re: RegExp, timeout = 15_000): Promise<void> {
        await expect.poll(() => new URL(this.page.url()).pathname + new URL(this.page.url()).search, { timeout }).toMatch(re);
    }
}

export const ruta = (page: Page): string => {
    const u = new URL(page.url());
    return u.pathname + u.search;
};

/**
 * Cuánto se desplazó verticalmente el contenido entre dos capturas, mirando
 * solo la región [r]. Positivo = el contenido subió (scroll hacia abajo).
 * Devuelve también el error del mejor encaje (0 = encaje perfecto).
 */
export function desplazamiento(a: Buffer, b: Buffer, r: Box, max = 420): { dy: number; err: number } {
    const pa = PNG.sync.read(a);
    const pb = PNG.sync.read(b);
    const x0 = Math.max(0, Math.floor(r.x) + 8);
    const x1 = Math.min(pa.width, Math.floor(r.x + r.width) - 8);
    const y0 = Math.max(0, Math.floor(r.y) + 2);
    const y1 = Math.min(pa.height, Math.floor(r.y + r.height) - 2);
    let mejor = { dy: 0, err: Infinity };
    for (let s = -max; s <= max; s++) {
        let suma = 0;
        let n = 0;
        // fila y de b corresponde a la fila y+s de a
        for (let y = Math.max(y0, y0 - s); y < Math.min(y1, y1 - s); y += 3) {
            const ia = (y + s) * pa.width * 4;
            const ib = y * pb.width * 4;
            for (let x = x0; x < x1; x += 3) {
                suma += Math.abs(pa.data[ia + x * 4] - pb.data[ib + x * 4]) + Math.abs(pa.data[ia + x * 4 + 1] - pb.data[ib + x * 4 + 1]);
                n++;
            }
        }
        if (n < 400) continue;
        const err = suma / n;
        // ante empate, el desplazamiento más chico
        if (err < mejor.err - 1e-9 || (Math.abs(err - mejor.err) <= 1e-9 && Math.abs(s) < Math.abs(mejor.dy))) mejor = { dy: s, err };
    }
    return mejor;
}

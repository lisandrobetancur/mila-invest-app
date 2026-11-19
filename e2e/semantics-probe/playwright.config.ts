/**
 * Sondas de medición de semantics (no es una suite E2E).
 *
 * Dos proyectos idénticos salvo por el build que miran:
 *   on  → :8081  build con  --dart-define=ENABLE_SEMANTICS=true
 *   off → :8082  build sin el define
 *
 * `on` corre primero: deja en `.coords/` las coordenadas y capturas que `off`
 * necesita para accionar sin ids.
 */
import { defineConfig } from '@playwright/test';

const APP = '../../packages/apps/mila_invest_app/build';
const server = (port: number, dir: string) => ({
    command: `python3 ../../scripts/serve_web.py ${port} ${APP}/${dir}`,
    url: `http://127.0.0.1:${port}/`,
    reuseExistingServer: true,
    timeout: 30_000,
});

export default defineConfig({
    testDir: './probes',
    outputDir: './test-results',
    retries: 0,
    workers: 1,
    fullyParallel: false,
    repeatEach: 5,
    timeout: 60_000,
    reporter: [['line'], ['json', { outputFile: process.env.PW_JSON ?? 'results/last-run.json' }]],
    use: {
        browserName: 'chromium',
        trace: 'on',
        deviceScaleFactor: 1,
        locale: 'es',
        viewport: { width: 390, height: 844 },
    },
    projects: [
        { name: 'on', use: { baseURL: 'http://127.0.0.1:8081' }, metadata: { mode: 'on' } },
        { name: 'off', use: { baseURL: 'http://127.0.0.1:8082' }, metadata: { mode: 'off' } },
    ],
    webServer: [server(8081, 'web_sem_on'), server(8082, 'web_sem_off')],
});

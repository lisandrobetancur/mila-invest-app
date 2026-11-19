/** Mismo config, pero mirando `pendientes/`: sondas que todavía no entraron a la corrida principal. */
import base from './playwright.config';

export default { ...base, testDir: './pendientes' };

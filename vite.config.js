import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import dotenv from 'dotenv';
import dotenvExpand from 'dotenv-expand';

// Načítaj .env a expanduj premenné
dotenvExpand.expand(dotenv.config());

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    server: {
        host: '0.0.0.0',
        port: parseInt(process.env.VITE_PORT, 10) || 5173, // Zabezpečí, že je to číslo
        strictPort: true,
        hmr: {
            host: '0.0.0.0',
            port: parseInt(process.env.VITE_PORT, 10) || 5173
        }
    }
});

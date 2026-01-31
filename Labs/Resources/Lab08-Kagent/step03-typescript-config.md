````markdown
# Step 03: TypeScript Configuration

## Create tsconfig.json

Create a `tsconfig.json` file in the root of your project (not inside `src`):

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```
````

## Configuration Explanation

| Option                  | Description                        |
| ----------------------- | ---------------------------------- |
| `target: ES2022`        | Modern JavaScript output           |
| `module: commonjs`      | Node.js compatible module system   |
| `outDir: ./dist`        | Compiled output directory          |
| `rootDir: ./src`        | Source code directory              |
| `strict: true`          | Enable all strict type checks      |
| `esModuleInterop: true` | Better CommonJS/ESM interop        |
| `declaration: true`     | Generate .d.ts files               |
| `sourceMap: true`       | Generate source maps for debugging |

## Project Structure After This Step

```
k-agent-logs/
├── node_modules/
├── src/
│   └── index.ts
├── package.json
├── package-lock.json
└── tsconfig.json
```

## Verify Configuration

```bash
# Test TypeScript compilation (should succeed with empty file)
npm run build
```

```

```

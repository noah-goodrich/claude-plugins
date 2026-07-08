#!/usr/bin/env node
/**
 * capability-index -- scan a TypeScript domain directory and emit a capability index.
 *
 * Usage:
 *   node capability-index.mjs [target-dir] [--out-dir <dir>]
 *                             [--project-root <dir>]
 *                             [--surfaces <comma-sep-dirs>]
 *                             [--fork-threshold <n>]
 *
 *   target-dir        Path to a domain directory (default: ./src/lib/domain).
 *   --out-dir         Where to write capability-index.md + capability-index.json
 *                     (default: <target-dir>/../../../docs/capability-index).
 *   --project-root    Root of the project for resolving surface dirs and for relative
 *                     path display in fork output.  Defaults to 3 levels above target-dir
 *                     (correct for src/lib/domain).
 *   --surfaces        Comma-separated list of directories (relative to --project-root)
 *                     to scan for direct DB table references.  When provided, the tool
 *                     also emits a "fork alerts" section: tables referenced directly in
 *                     >= --fork-threshold surface files instead of via a canonical domain fn.
 *   --fork-threshold  Minimum number of surface files that must reference a table for it
 *                     to be flagged as a fork candidate (default: 3).
 *
 * No external dependencies. Tolerant of missing JSDoc. Works on any project
 * that follows the "pure domain function" pattern: exported functions in .ts
 * files with optional block JSDoc comments.
 *
 * Surface fork detection: scans for Supabase-style `.from('table_name')` references
 * across surface files (.ts and .tsx) and flags tables that appear in >= threshold
 * files.  This catches the "write-path fork" class -- a resolver duplicated across
 * surfaces that should instead call one canonical src/lib/domain function.
 */

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from "node:fs";
import { join, resolve, basename, relative } from "node:path";

// ---- CLI args ---------------------------------------------------------------
const args = process.argv.slice(2);
let targetDir = "./src/lib/domain";
let outDir = null;
let projectRoot = null;
let surfaceDirsArg = null;
let forkThreshold = 3;

for (let i = 0; i < args.length; i++) {
    if (args[i] === "--out-dir" && args[i + 1]) {
        outDir = args[++i];
    } else if (args[i] === "--project-root" && args[i + 1]) {
        projectRoot = args[++i];
    } else if (args[i] === "--surfaces" && args[i + 1]) {
        surfaceDirsArg = args[++i];
    } else if (args[i] === "--fork-threshold" && args[i + 1]) {
        forkThreshold = parseInt(args[++i], 10) || 3;
    } else if (!args[i].startsWith("-")) {
        targetDir = args[i];
    }
}
targetDir = resolve(targetDir);
if (!outDir) {
    // Default: 3 levels up from domain dir → docs/capability-index
    outDir = resolve(targetDir, "../../../docs/capability-index");
}
outDir = resolve(outDir);

if (!projectRoot) {
    // Default: 3 levels up from target-dir (src/lib/domain → project root)
    projectRoot = resolve(targetDir, "../../..");
}
projectRoot = resolve(projectRoot);

const surfaceDirs = surfaceDirsArg
    ? surfaceDirsArg.split(",").map((d) => d.trim()).filter(Boolean)
    : [];

// ---- Helpers ----------------------------------------------------------------

/** Return the first sentence from a raw JSDoc interior string. */
function firstSentence(raw) {
    const text = raw
        .replace(/\*\s*/g, " ")
        .replace(/\s+/g, " ")
        .trim();
    // Sentence ends at ". " or ".\n" or before @param/@returns
    const m = text.match(/^(.*?\.)\s/);
    if (m) return m[1].trim();
    return text.slice(0, 140).trim();
}

/** Normalize raw JSDoc interior: strip leading `*`, collapse whitespace. */
function normalizeDoc(raw) {
    return raw.replace(/\*\s*/g, " ").replace(/\s+/g, " ").trim();
}

/** Extract invariant notes from a module-level comment string. */
function extractInvariants(raw) {
    if (!raw) return [];
    const text = normalizeDoc(raw);
    const inv = [];
    if (/Pure\.\s*No I\/O/.test(text)) inv.push("Pure. No I/O.");
    const callerNote = text.match(/The CALLER is responsible for ([^.]+\.)/);
    if (callerNote) inv.push(`Caller must: ${callerNote[1].trim()}`);
    return inv;
}

/** Extract PWA + MCP caller paths from a module-level comment string. */
function extractSurfaces(raw) {
    if (!raw) return { pwa: null, mcp: null };
    // Matches: "PWA  (src/app/…)" or "PWA: `src/app/…`"
    const pwa = raw.match(/PWA\s*[:\(]\s*`?([^`\n,\)]+)`?/i);
    const mcp = raw.match(/MCP\s*[:\(]\s*`?([^`\n,\)]+)`?/i);
    return {
        pwa: pwa ? pwa[1].trim() : null,
        mcp: mcp ? mcp[1].trim() : null,
    };
}

/**
 * Parse one .ts file. Returns an array of capability objects, one per
 * exported function (with or without a JSDoc block).
 */
function parseFile(filePath) {
    const source = readFileSync(filePath, "utf8");
    const module = basename(filePath, ".ts");

    // Module-level block comment: first /** ... */ in the file.
    const moduleRaw = (source.match(/^\/\*\*([\s\S]*?)\*\//) || [])[1] ?? null;
    const invariants = extractInvariants(moduleRaw);
    const surfaces = extractSurfaces(moduleRaw);

    const capabilities = [];
    const foundNames = new Set();

    // Case 1: exported function with a preceding JSDoc block.
    // Pattern: /** ... */ <newline> export [async] function NAME(...)
    // Use ((?:[^*]|\*(?!\/))*) to match JSDoc content that terminates at the FIRST
    // closing */ — avoids bleeding the module comment into the first function's JSDoc.
    const withDoc =
        /\/\*\*((?:[^*]|\*(?!\/))*)\*\/\s*\nexport (?:async )?function (\w+)([^{]+)\{/g;
    let m;
    while ((m = withDoc.exec(source)) !== null) {
        const [, jsdocRaw, fnName, rest] = m;
        foundNames.add(fnName);
        capabilities.push({
            fn_name: fnName,
            signature: `export function ${fnName}${rest.trim().replace(/\s+/g, " ")}`,
            intent: firstSentence(jsdocRaw),
            module,
            invariants: [...invariants],
            caller_pwa: surfaces.pwa,
            caller_mcp: surfaces.mcp,
        });
    }

    // Case 2: exported function WITHOUT a JSDoc block (tolerant fallback).
    const noDoc = /^export (?:async )?function (\w+)([^{]+)\{/gm;
    while ((m = noDoc.exec(source)) !== null) {
        const [, fnName, rest] = m;
        if (!foundNames.has(fnName)) {
            capabilities.push({
                fn_name: fnName,
                signature: `export function ${fnName}${rest.trim().replace(/\s+/g, " ")}`,
                intent: "(no doc comment found)",
                module,
                invariants: [...invariants],
                caller_pwa: surfaces.pwa,
                caller_mcp: surfaces.mcp,
            });
        }
    }

    return capabilities;
}

// ---- Surface fork detection -------------------------------------------------

/**
 * Recursively collect .ts and .tsx files under a directory, excluding
 * test files, .d.ts files, node_modules, and hidden dirs.
 */
function collectSurfaceFiles(dir) {
    const results = [];
    let entries;
    try {
        entries = readdirSync(dir, { withFileTypes: true });
    } catch (_) {
        return results;
    }
    for (const entry of entries) {
        if (entry.name.startsWith(".") || entry.name === "node_modules") continue;
        const full = join(dir, entry.name);
        if (entry.isDirectory()) {
            results.push(...collectSurfaceFiles(full));
        } else if (entry.isFile()) {
            const name = entry.name;
            if (
                (name.endsWith(".ts") || name.endsWith(".tsx")) &&
                !name.endsWith(".test.ts") &&
                !name.endsWith(".test.tsx") &&
                !name.endsWith(".d.ts")
            ) {
                results.push(full);
            }
        }
    }
    return results;
}

/**
 * Extract all DB table references from a source string using two patterns:
 *
 *   1. Supabase client:  .from('table_name')  or  .from("table_name")
 *   2. Raw SQL strings:  FROM table_name / INTO table_name /
 *                        UPDATE table_name / JOIN table_name
 *      (case-insensitive; catches MCP tools that use pg/Postgres directly)
 *
 * Returns a Set of lowercase table name strings.
 */
function extractTableRefs(source) {
    const tables = new Set();

    // Pattern 1 — Supabase client
    const supaRe = /\.from\(['"]([a-z][a-z0-9_]*)['"]\)/g;
    let m;
    while ((m = supaRe.exec(source)) !== null) {
        tables.add(m[1]);
    }

    // Pattern 2 — raw SQL keywords followed by a snake_case table identifier.
    // Matches FROM / INTO / UPDATE / JOIN + an identifier that MUST contain at
    // least one underscore.  The underscore requirement filters out English prose
    // in comments and string literals (words like "the", "a", "list", "rows"
    // never appear as snake_case table names).  Short single-word table names
    // (lists, items, meals) are already caught by Pattern 1 (Supabase client).
    const sqlRe = /\b(?:FROM|INTO|UPDATE|JOIN)\s+([a-z][a-z0-9]*(?:_[a-z0-9]+)+)\b/gi;
    while ((m = sqlRe.exec(source)) !== null) {
        tables.add(m[1].toLowerCase());
    }

    return tables;
}

/**
 * Scan surface directories for direct DB table references.
 * Returns an array of fork alerts sorted by site count descending:
 *   { table: string, site_count: number, sites: string[] }
 * where sites are paths relative to projectRoot.
 *
 * A fork alert means the same table is queried directly in >= forkThreshold
 * surface files -- a signal that resolution logic is scattered rather than
 * routed through a canonical domain function.
 */
function scanForForks(surfaceDirList, projectRootPath, threshold) {
    const tableToFiles = new Map();

    for (const relDir of surfaceDirList) {
        const absDir = resolve(projectRootPath, relDir);
        const files = collectSurfaceFiles(absDir);
        for (const file of files) {
            let source;
            try {
                source = readFileSync(file, "utf8");
            } catch (_) {
                continue;
            }
            const tables = extractTableRefs(source);
            for (const table of tables) {
                if (!tableToFiles.has(table)) tableToFiles.set(table, new Set());
                tableToFiles.get(table).add(file);
            }
        }
    }

    const alerts = [];
    for (const [table, files] of tableToFiles) {
        if (files.size >= threshold) {
            const sites = [...files]
                .map((f) => relative(projectRootPath, f))
                .sort();
            alerts.push({ table, site_count: files.size, sites });
        }
    }
    alerts.sort((a, b) => b.site_count - a.site_count);
    return alerts;
}

// ---- Main -------------------------------------------------------------------

const files = readdirSync(targetDir)
    .filter((f) => f.endsWith(".ts") && !f.endsWith(".test.ts") && f !== "index.ts")
    .sort();

if (files.length === 0) {
    console.error(`No .ts files found in ${targetDir}`);
    process.exit(1);
}

const allCapabilities = [];
for (const file of files) {
    const caps = parseFile(join(targetDir, file));
    allCapabilities.push(...caps);
}

// Run surface fork detection if --surfaces was provided
const forkAlerts = surfaceDirs.length > 0
    ? scanForForks(surfaceDirs, projectRoot, forkThreshold)
    : [];

mkdirSync(outDir, { recursive: true });

// ---- JSON output ------------------------------------------------------------
// capability-index.json keeps the original flat-array format for backward compat.
const jsonPath = join(outDir, "capability-index.json");
writeFileSync(jsonPath, JSON.stringify(allCapabilities, null, 2) + "\n");

// fork-alerts.json is written only when --surfaces is provided.
let forkJsonPath = null;
if (surfaceDirs.length > 0) {
    const forkOut = {
        fork_alerts: forkAlerts,
        fork_scan_meta: {
            project_root: projectRoot,
            surface_dirs: surfaceDirs,
            fork_threshold: forkThreshold,
        },
    };
    forkJsonPath = join(outDir, "fork-alerts.json");
    writeFileSync(forkJsonPath, JSON.stringify(forkOut, null, 2) + "\n");
}

// ---- Markdown output --------------------------------------------------------
const mdLines = [
    `# Capability Index`,
    ``,
    `Generated from \`${targetDir}\`.`,
    `${allCapabilities.length} exported functions across ${files.length} modules.`,
    ``,
    `## Summary table`,
    ``,
    `| Function | Module | Intent | Invariants |`,
    `|---|---|---|---|`,
];
for (const cap of allCapabilities) {
    const intent = cap.intent.replace(/\|/g, "\\|");
    const inv = cap.invariants.join("; ").replace(/\|/g, "\\|") || "—";
    mdLines.push(`| \`${cap.fn_name}\` | \`${cap.module}\` | ${intent} | ${inv} |`);
}

// Detailed sections per function
mdLines.push(``, `---`, ``, `## Detail`);
for (const cap of allCapabilities) {
    mdLines.push(``, `### \`${cap.fn_name}\` (\`${cap.module}\`)`);
    mdLines.push(``, `**Signature**`, ``, `\`\`\`typescript`, cap.signature, `\`\`\``);
    mdLines.push(``, `**Intent:** ${cap.intent}`);
    if (cap.invariants.length > 0) {
        mdLines.push(``, `**Invariants:**`);
        for (const inv of cap.invariants) mdLines.push(`- ${inv}`);
    }
    const callerLines = [
        cap.caller_pwa ? `- PWA: \`${cap.caller_pwa}\`` : null,
        cap.caller_mcp ? `- MCP: \`${cap.caller_mcp}\`` : null,
    ].filter(Boolean);
    if (callerLines.length > 0) {
        mdLines.push(``, `**Callers:**`);
        mdLines.push(...callerLines);
    }
}

// Fork alerts section
if (surfaceDirs.length > 0) {
    mdLines.push(
        ``,
        `---`,
        ``,
        `## Fork Alerts`,
        ``,
        `Tables referenced directly in \`>= ${forkThreshold}\` surface files instead of via a`,
        `canonical \`src/lib/domain\` function. Each is a consolidation candidate.`,
        ``,
        `Surface dirs scanned (relative to project root \`${projectRoot}\`):`,
    );
    for (const d of surfaceDirs) mdLines.push(`- \`${d}\``);
    mdLines.push(``);

    if (forkAlerts.length === 0) {
        mdLines.push(`No fork candidates found (threshold: ${forkThreshold} sites).`);
    } else {
        mdLines.push(
            `| Table | Sites | Files |`,
            `|---|---|---|`,
        );
        for (const alert of forkAlerts) {
            const fileList = alert.sites.map((s) => `\`${s}\``).join(", ");
            mdLines.push(`| \`${alert.table}\` | ${alert.site_count} | ${fileList} |`);
        }
        mdLines.push(``);
        mdLines.push(`### Fork detail`);
        for (const alert of forkAlerts) {
            mdLines.push(``, `#### \`${alert.table}\` (${alert.site_count} sites)`);
            mdLines.push(``, `Direct \`.from('${alert.table}')\` references found in:`);
            for (const site of alert.sites) mdLines.push(`- \`${site}\``);
        }
    }
}

const mdPath = join(outDir, "capability-index.md");
writeFileSync(mdPath, mdLines.join("\n") + "\n");

// ---- Summary ----------------------------------------------------------------
console.log(`capability-index: ${allCapabilities.length} functions in ${files.length} modules`);
console.log(`  JSON: ${jsonPath}`);
console.log(`  MD:   ${mdPath}`);
if (surfaceDirs.length > 0) {
    console.log(`  Fork JSON: ${forkJsonPath}`);
    console.log(`  Fork alerts (threshold >= ${forkThreshold} sites): ${forkAlerts.length}`);
    for (const alert of forkAlerts) {
        console.log(`    [FORK] ${alert.table}  (${alert.site_count} sites)`);
        for (const site of alert.sites) {
            console.log(`      - ${site}`);
        }
    }
}

#!/usr/bin/env node
/**
 * capability-index -- scan a TypeScript domain directory and emit a capability index.
 *
 * Usage:
 *   node capability-index.mjs [target-dir] [--out-dir <dir>]
 *
 *   target-dir  Path to a domain directory (default: ./src/lib/domain).
 *   --out-dir   Where to write capability-index.md + capability-index.json
 *               (default: <target-dir>/../../../docs/capability-index).
 *
 * No external dependencies. Tolerant of missing JSDoc. Works on any project
 * that follows the "pure domain function" pattern: exported functions in .ts
 * files with optional block JSDoc comments.
 */

import { readFileSync, writeFileSync, mkdirSync, readdirSync } from "node:fs";
import { join, resolve, basename } from "node:path";

// ---- CLI args ---------------------------------------------------------------
const args = process.argv.slice(2);
let targetDir = "./src/lib/domain";
let outDir = null;
for (let i = 0; i < args.length; i++) {
    if (args[i] === "--out-dir" && args[i + 1]) {
        outDir = args[++i];
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

mkdirSync(outDir, { recursive: true });

// ---- JSON output ------------------------------------------------------------
const jsonPath = join(outDir, "capability-index.json");
writeFileSync(jsonPath, JSON.stringify(allCapabilities, null, 2) + "\n");

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

const mdPath = join(outDir, "capability-index.md");
writeFileSync(mdPath, mdLines.join("\n") + "\n");

// ---- Summary ----------------------------------------------------------------
console.log(`capability-index: ${allCapabilities.length} functions in ${files.length} modules`);
console.log(`  JSON: ${jsonPath}`);
console.log(`  MD:   ${mdPath}`);

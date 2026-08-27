#!/usr/bin/env python3
"""Corpus loading, provenance parsing, and rubric-term density for the ai-scoring evaluation set.

Three classes of document:

    human    noah-writing-voice/validation/2026-05-23-corpus/articles/*.md
             Published articles. Carry their own editorial frontmatter (title, url, date) and are
             never re-tagged, so the directory itself is the class label.

    generic  evals/corpus/**/*.md with `class: generic`
             Unprompted model prose.

    voiced   evals/corpus/**/*.md with `class: voiced`
             Claude drafting in Noah's voice with noah-voice loaded.

Generated documents carry the provenance block defined by the build contract. Every field is
required; a missing one is an error naming the file and the field, never a silent default.

Standard library only. No network.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path

HARNESS_DIR = Path(__file__).resolve().parent
EVALS_DIR = HARNESS_DIR.parent
REPO_ROOT = EVALS_DIR.parent

HUMAN_ARTICLES_DIR = (
    REPO_ROOT / "noah-writing-voice" / "validation" / "2026-05-23-corpus" / "articles"
)
OLD_FIXTURES_DIR = (
    REPO_ROOT / "noah-writing-voice" / "validation" / "2026-05-23-corpus" / "ai-samples"
)
SCORER_PATH = (
    REPO_ROOT
    / "noah-writing-voice"
    / "validation"
    / "2026-05-23-corpus"
    / "scripts"
    / "ai_score.py"
)
SKILL_PATH = REPO_ROOT / "noah-writing-voice" / "skills" / "ai-scoring" / "SKILL.md"
CORPUS_ROOT = EVALS_DIR / "corpus"
MANIFEST_PATH = CORPUS_ROOT / "manifest.json"

HUMAN_CLASS = "human"
NEGATIVE_CLASSES = ("generic", "voiced")
ALL_CLASSES = (HUMAN_CLASS,) + NEGATIVE_CLASSES

REQUIRED_FIELDS = (
    "class",
    "provider",
    "model",
    "generated",
    "target_words",
    "source_article",
    "prompt",
)
VALID_PROVIDERS = ("anthropic", "google", "cortex")

DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
FRONTMATTER_RE = re.compile(r"\A---\r?\n(.*?)\r?\n---[ \t]*\r?\n?", re.DOTALL)
CODE_FENCE_RE = re.compile(r"```.*?```", re.DOTALL)
WORD_RE = re.compile(r"\b\w+\b")


def rel_to_repo(path, root: Path = REPO_ROOT) -> str:
    """Repo-relative POSIX path, falling back to the absolute path when outside the repo."""
    resolved = Path(path).resolve()
    try:
        return resolved.relative_to(root.resolve()).as_posix()
    except ValueError:
        return resolved.as_posix()


class ProvenanceError(ValueError):
    """A document's provenance block is missing, malformed, or incomplete."""


class CorpusError(ValueError):
    """The corpus on disk cannot support the requested operation."""


@dataclass(frozen=True)
class Document:
    path: Path
    doc_class: str
    provider: str
    model: str
    generated: str
    target_words: int
    source_article: str
    prompt: str
    body: str

    @property
    def name(self) -> str:
        return self.path.name

    @property
    def word_count(self) -> int:
        return count_words(self.body)

    @property
    def stratum(self) -> str:
        return f"{self.doc_class}/{self.provider}"

    def rel_path(self, root: Path = REPO_ROOT) -> str:
        return rel_to_repo(self.path, root)


# ---------- text ----------


def normalize(text: str) -> str:
    """Fold typographic apostrophes and quotes so rubric terms match either encoding."""
    return text.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')


def strip_frontmatter(text: str) -> str:
    return FRONTMATTER_RE.sub("", text, count=1)


def body_text(text: str) -> str:
    return CODE_FENCE_RE.sub("", strip_frontmatter(text))


def count_words(text: str) -> int:
    return len(WORD_RE.findall(text))


# ---------- provenance ----------


def parse_frontmatter(raw: str, path: Path) -> tuple[dict, str]:
    """Parse the leading `---` block into a dict, returning (fields, body).

    Handles the flat `key: value` pairs and the one block scalar the contract uses (`prompt: |`).
    Block-scalar continuation lines are indented; a line at column zero ends the scalar.
    """
    match = FRONTMATTER_RE.match(raw)
    if match is None:
        raise ProvenanceError(
            f"{path}: no frontmatter block; expected a leading '---' line"
        )

    fields: dict = {}
    key: str | None = None
    block_lines: list[str] = []
    in_block = False

    for line in match.group(1).splitlines():
        if in_block:
            if not line.strip():
                block_lines.append("")
                continue
            if line[:1] in (" ", "\t"):
                block_lines.append(line)
                continue
            fields[key] = _dedent(block_lines)
            in_block = False
            block_lines = []
        if not line.strip():
            continue
        if ":" not in line:
            raise ProvenanceError(
                f"{path}: frontmatter line is not 'key: value': {line.strip()!r}"
            )
        key, _, value = line.partition(":")
        key = key.strip()
        value = value.strip()
        if value in ("|", "|-", ">", ">-"):
            in_block = True
            block_lines = []
            continue
        fields[key] = _unquote(value)

    if in_block:
        fields[key] = _dedent(block_lines)

    return fields, body_text(raw)


def _unquote(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def _dedent(lines: list[str]) -> str:
    indents = [len(ln) - len(ln.lstrip()) for ln in lines if ln.strip()]
    pad = min(indents) if indents else 0
    return "\n".join(ln[pad:] if ln.strip() else "" for ln in lines).strip("\n")


def load_generated_document(path: Path) -> Document:
    """Load one generated document, failing loudly on incomplete provenance."""
    raw = path.read_text(encoding="utf-8")
    fields, body = parse_frontmatter(raw, path)

    missing = [f for f in REQUIRED_FIELDS if not str(fields.get(f, "")).strip()]
    if missing:
        raise ProvenanceError(
            f"{path}: provenance incomplete, missing field(s): {', '.join(missing)}"
        )

    doc_class = fields["class"].strip()
    if doc_class not in NEGATIVE_CLASSES:
        raise ProvenanceError(
            f"{path}: field 'class' is {doc_class!r}; expected one of {', '.join(NEGATIVE_CLASSES)}"
        )

    provider = fields["provider"].strip()
    if provider not in VALID_PROVIDERS:
        raise ProvenanceError(
            f"{path}: field 'provider' is {provider!r}; expected one of {', '.join(VALID_PROVIDERS)}"
        )

    generated = fields["generated"].strip()
    if not DATE_RE.match(generated):
        raise ProvenanceError(
            f"{path}: field 'generated' is {generated!r}; expected YYYY-MM-DD"
        )

    try:
        target_words = int(str(fields["target_words"]).strip())
    except ValueError:
        raise ProvenanceError(
            f"{path}: field 'target_words' is {fields['target_words']!r}; expected an integer"
        ) from None

    return Document(
        path=path,
        doc_class=doc_class,
        provider=provider,
        model=fields["model"].strip(),
        generated=generated,
        target_words=target_words,
        source_article=fields["source_article"].strip(),
        prompt=fields["prompt"].strip(),
        body=body,
    )


def load_human_document(path: Path) -> Document:
    """Load a published article. Its editorial frontmatter is not provenance and is not required."""
    raw = path.read_text(encoding="utf-8")
    return Document(
        path=path,
        doc_class=HUMAN_CLASS,
        provider=HUMAN_CLASS,
        model=HUMAN_CLASS,
        generated="",
        target_words=0,
        source_article=path.name,
        prompt="",
        body=body_text(raw),
    )


# ---------- collections ----------


def human_documents(articles_dir: Path = HUMAN_ARTICLES_DIR) -> list[Document]:
    if not articles_dir.is_dir():
        return []
    return [load_human_document(p) for p in sorted(articles_dir.glob("*.md"))]


def generated_documents(corpus_root: Path = CORPUS_ROOT) -> list[Document]:
    if not corpus_root.is_dir():
        return []
    return [load_generated_document(p) for p in sorted(corpus_root.rglob("*.md"))]


def load_corpus(
    corpus_root: Path = CORPUS_ROOT, articles_dir: Path = HUMAN_ARTICLES_DIR
) -> dict:
    """Return {class: [Document]} for all three classes, including empty classes."""
    by_class: dict = {cls: [] for cls in ALL_CLASSES}
    by_class[HUMAN_CLASS] = human_documents(articles_dir)
    for doc in generated_documents(corpus_root):
        by_class[doc.doc_class].append(doc)
    return by_class


def require_classes(by_class: dict, classes=ALL_CLASSES) -> None:
    empty = [cls for cls in classes if not by_class.get(cls)]
    if empty:
        raise CorpusError(
            "corpus is missing document(s) for class(es): "
            + ", ".join(empty)
            + f"\nGenerated documents are read from {CORPUS_ROOT} (recursively);"
            + f" human articles from {HUMAN_ARTICLES_DIR}."
        )


def document_for_path(path: Path) -> Document:
    """Load a document by path, choosing the loader from its location."""
    resolved = Path(path).resolve()
    if resolved.is_relative_to(HUMAN_ARTICLES_DIR.resolve()):
        return load_human_document(resolved)
    return load_generated_document(resolved)


# ---------- rubric terms ----------

_RUBRIC_SECTIONS = {
    "transitions": "### 3. Generic Transitions",
    "banned_words": "### 8. Banned Words and Phrases",
}


def _section_bullets(skill_text: str, heading: str, path: Path) -> list[str]:
    start = skill_text.find(heading)
    if start < 0:
        raise CorpusError(
            f"{path}: rubric section {heading!r} not found; the term lists cannot be read"
        )
    tail = skill_text[start + len(heading) :]
    stop = tail.find("**Scoring:**")
    if stop >= 0:
        tail = tail[:stop]
    return [ln.strip()[2:] for ln in tail.splitlines() if ln.strip().startswith("- ")]


def rubric_terms(skill_path: Path = SKILL_PATH) -> dict:
    """Read the banned-word and banned-transition lists out of ai-scoring/SKILL.md.

    Parsed from the rubric prose rather than copied into code, so the contamination measure cannot
    drift from the rubric it is measuring against. Terms are the double-quoted strings in the
    'What to look for' bullets of categories 3 and 8; the em-dash bullet carries no quoted term and
    is deliberately not counted, since a punctuation mark is not a lexical lift from the list.
    """
    if not skill_path.is_file():
        raise CorpusError(
            f"{skill_path}: ai-scoring rubric not found; cannot read its term lists"
        )
    text = normalize(skill_path.read_text(encoding="utf-8"))

    out: dict = {}
    for name, heading in _RUBRIC_SECTIONS.items():
        terms = []
        for bullet in _section_bullets(text, heading, skill_path):
            for quoted in re.findall(r'"([^"]+)"', bullet):
                term = quoted.strip().strip(".,;:!?").strip().lower()
                if term:
                    terms.append(term)
        if not terms:
            raise CorpusError(
                f"{skill_path}: rubric section {heading!r} yielded no quoted terms"
            )
        out[name] = sorted(set(terms))
    out["all"] = sorted(set(out["transitions"]) | set(out["banned_words"]))
    return out


_TERM_PATTERN_CACHE: dict = {}


def _term_patterns(skill_path: Path) -> list:
    key = str(skill_path)
    if key not in _TERM_PATTERN_CACHE:
        _TERM_PATTERN_CACHE[key] = [
            (
                term,
                re.compile(
                    r"(?<!\w)" + re.escape(term).replace(r"\ ", r"\s+") + r"(?!\w)",
                    re.IGNORECASE,
                ),
            )
            for term in rubric_terms(skill_path)["all"]
        ]
    return _TERM_PATTERN_CACHE[key]


def rubric_term_hits(text: str, skill_path: Path = SKILL_PATH) -> dict:
    """Return {term: count} for every rubric term appearing in text."""
    haystack = normalize(text)
    hits = {}
    for term, pattern in _term_patterns(skill_path):
        n = len(pattern.findall(haystack))
        if n:
            hits[term] = n
    return hits


def rubric_term_density(text: str, skill_path: Path = SKILL_PATH) -> float:
    """Rubric-term hits per 100 words.

    The 2026-08-26 measurement quoted real writing at 0.00-0.55 and the retired fixtures at
    7.14-8.33, but it used a wider term list than the rubric prose carries, so this function
    does not reproduce those numbers and should not be compared against them. Run
    evaluate.py --contamination for poles measured by this same term list.
    """
    words = count_words(body_text(text))
    if words == 0:
        return 0.0
    return sum(rubric_term_hits(text, skill_path).values()) / words * 100.0


def main() -> int:
    import json

    by_class = load_corpus()
    summary = {
        cls: {
            "n": len(docs),
            "providers": sorted({d.provider for d in docs}),
            "word_counts": sorted(d.word_count for d in docs),
        }
        for cls, docs in by_class.items()
    }
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

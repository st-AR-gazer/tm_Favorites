import re
from pathlib import Path

PLUGINS_TXT = "plugins.txt"
OUTPUT_AS   = "auto_generated.as"


def ns_safe(pid: str) -> str:
    ns = re.sub(r"[^0-9A-Za-z_]", "_", pid)
    return "_" + ns if ns and ns[0].isdigit() else ns


def load_ids(path: str) -> list[str]:
    with open(path, encoding="utf-8") as f:
        return [ln.strip() for ln in f if ln.strip()]


def generate() -> None:
    ids = load_ids(PLUGINS_TXT)
    if not ids:
        raise SystemExit("plugins.txt is empty.")

    pairs = [(pid, ns_safe(pid)) for pid in ids]

    out: list[str] = [
        "// auto_generated.as",
        "//",
        "// Generated references for known plugins on the Openplanet site.",
        "",
    ]

    for pid, ns in pairs:
        out.append(f'namespace {ns} {{ import void RenderMenu() from "{pid}"; }}')
    out.append("")

    out.append("bool HasAutoRender(const string &in p)")
    out.append("{")
    for i, (pid, _) in enumerate(pairs):
        kw = "if" if i == 0 else "else if"
        out.append(f'    {kw} (p == "{pid}")')
        out.append("        return true;")
    out.append("    return false;")
    out.append("}")
    out.append("")

    out.append("void CallAutoRender(const string &in p)")
    out.append("{")
    for i, (pid, ns) in enumerate(pairs):
        kw = "if" if i == 0 else "else if"
        out.append(f'    {kw} (p == "{pid}") {{')
        out.append(f"        try {{ {ns}::RenderMenu(); }} catch {{}}")
        out.append("    }")
    out.append("}")
    out.append("")

    Path(OUTPUT_AS).write_text("\n".join(out), encoding="utf-8")
    print(f"Generated {OUTPUT_AS} with {len(ids)} plugins.")


if __name__ == "__main__":
    generate()

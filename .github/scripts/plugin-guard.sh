#!/usr/bin/env bash
# Release guard for plugin/ (the Claude directory tracks main; every push is a candidate version).
#   plugin-guard.sh structure        files and manifest are well formed
#   plugin-guard.sh version          plugin.json "version" was raised if anything under plugin/ changed
# Needs only bash, jq, node, git. Run from the repo root.
# `version` reads: EVENT_NAME (push|pull_request), BEFORE (push), PR_BASE_SHA (pull_request),
# DEFAULT_BRANCH, REF_NAME; compares plugin/ at HEAD with the base.
set -euo pipefail

P=plugin
MANIFEST=$P/.claude-plugin/plugin.json
ZERO=0000000000000000000000000000000000000000
fail=0
err() { echo "::error::$*"; fail=1; }

# Print one line per problem with a SKILL.md frontmatter (nothing when fine).
# Tolerates a leading BOM, CRLF, and trailing spaces on the '---' lines; needs a closing '---'.
frontmatter_problems() {
  node -e '
    let t = require("fs").readFileSync(process.argv[1], "utf8").replace(/^\uFEFF/, "").replace(/\r/g, "");
    const L = t.split("\n"), fence = /^---[ \t]*$/;
    if (!fence.test(L[0])) { console.log("no frontmatter (the file must start with ---)"); process.exit(0); }
    let end = -1;
    for (let i = 1; i < L.length; i++) if (fence.test(L[i])) { end = i; break; }
    if (end < 0) { console.log("frontmatter is not closed (no closing ---)"); process.exit(0); }
    const fm = L.slice(1, end);
    for (const key of ["name", "description"]) {
      const i = fm.findIndex(l => l.startsWith(key + ":"));
      let ok = false;
      if (i >= 0) {
        let v = fm[i].slice(key.length + 1).trim();
        v = v.replace(/^"(.*)"$/, "$1").replace(/^\x27(.*)\x27$/, "$1").trim();
        if (/^[>|][+-]?[0-9]?[+-]?$/.test(v)) {            // block scalar: needs indented text after it
          for (let j = i + 1; j < fm.length && (fm[j].trim() === "" || /^[ \t]/.test(fm[j])); j++)
            if (fm[j].trim() !== "") { ok = true; break; }
        } else ok = v !== "" && !/^(null|~)$/i.test(v);
      }
      if (!ok) console.log("frontmatter has no " + key + " (missing, empty, null, or an empty block scalar)");
    }' "$1"
}

structure() {
  local f icon n s line
  for f in "$MANIFEST" "$P/.mcp.json"; do
    if [ ! -f "$f" ]; then err "missing $f"; continue; fi
    jq -e . "$f" >/dev/null 2>&1 || err "$f is not valid JSON"
  done
  [ "$fail" = 0 ] || return 0   # later checks need parseable JSON

  [ -f "$P/LICENSE" ] || err "missing $P/LICENSE"
  if [ -f "$P/README.md" ]; then
    n=$(wc -w < "$P/README.md")
    [ "$n" -ge 40 ] || err "$P/README.md has $n words; it needs 40 or more"
  else
    err "missing $P/README.md"
  fi

  # servers live in .mcp.json; a second, unchecked set in the manifest is how a wrong url ships
  if jq -e 'has("mcpServers")' "$MANIFEST" >/dev/null; then
    err "$MANIFEST must not set \"mcpServers\"; the server lives in $P/.mcp.json"
  fi

  icon=$(jq -r 'if (.icon | type) == "string" then .icon else empty end' "$MANIFEST")
  if [ -z "$icon" ]; then err "$MANIFEST names no \"icon\" (a string path)"
  elif [[ "$icon" == /* || "$icon" == *..* || "$icon" == *\\* ]]; then
    err "the icon path '$icon' must be relative, inside plugin/ (no leading '/', '..' or backslash)"
  elif [ ! -f "$P/$icon" ]; then err "the icon $MANIFEST names ($icon) is missing at $P/$icon"
  elif [ ! -s "$P/$icon" ]; then err "the icon $P/$icon is empty"; fi

  n=0
  for f in "$P"/skills/*/; do
    [ -d "$f" ] || continue
    [ -f "${f}SKILL.md" ] || err "${f} has no SKILL.md"
  done
  for f in "$P"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    n=$((n+1))
    s=$(frontmatter_problems "$f")
    [ -z "$s" ] || while IFS= read -r line; do err "$f: $line"; done <<< "$s"
  done
  [ "$n" -ge 1 ] || err "no $P/skills/*/SKILL.md found"

  jq -e '(.mcpServers // {}) | length >= 1 and all(.[]; .url == "https://mcp.coil.trade/mcp")' \
    "$P/.mcp.json" >/dev/null || err "$P/.mcp.json: every server url must be exactly https://mcp.coil.trade/mcp"
}

# Echo the base commit to compare against, or "" when there is none (new plugin / nothing to compare).
resolve_base() {
  local base="" mb
  if [ "${EVENT_NAME:-}" = pull_request ]; then
    base=${PR_BASE_SHA:-}
  else
    base=${BEFORE:-$ZERO}
    if [ "$base" = "$ZERO" ] || ! git cat-file -e "$base^{commit}" 2>/dev/null; then
      # new branch, or a force push that dropped the old tip
      if [ "${REF_NAME:-}" = "${DEFAULT_BRANCH:-main}" ]; then
        base=$(git rev-parse --verify -q HEAD^ || true)      # empty on the first commit
      else
        base=$(git merge-base "origin/${DEFAULT_BRANCH:-main}" HEAD 2>/dev/null || true)
      fi
    fi
  fi
  printf '%s' "$base"
}

version_check() {
  local base changed new old base_json
  base=$(resolve_base)
  if [ -z "$base" ]; then
    changed=$(git ls-tree -r --name-only HEAD -- $P | sed -n 1p)   # first commit: everything is new
  else
    changed=$(git diff --name-only "$base"...HEAD -- $P)
  fi
  if [ -z "$changed" ]; then echo "nothing under $P/ changed; no version bump needed"; return 0; fi
  echo "changed under $P/ (base ${base:-none}):"; printf '%s\n' "$changed" | sed 's/^/  /'

  new=$(jq -r '.version // empty' "$MANIFEST" 2>/dev/null) || { err "$MANIFEST is not valid JSON"; return 0; }
  old=""
  # Skip the comparison only when the base has no plugin/ at all (first commit, or the plugin is being added).
  # If it has one, its manifest must be readable: a broken base would otherwise let any version through.
  if [ -n "$base" ] && [ -n "$(git ls-tree -r --name-only "$base" -- $P | sed -n 1p)" ]; then
    if ! base_json=$(git show "$base:$MANIFEST" 2>/dev/null); then
      err "the base commit ($base) has $P/ but no $MANIFEST, so the version cannot be compared. Fix the base manifest first."; return 0
    fi
    if ! old=$(printf '%s' "$base_json" | jq -er '.version | strings' 2>/dev/null) || [ -z "$old" ]; then
      err "the base commit ($base) has $MANIFEST but it is unparseable or has no string \"version\", so the version cannot be compared. Fix \"version\" in $MANIFEST on the base branch first."; return 0
    fi
  fi

  # exit 0: new > old (or no base plugin and new valid); 1: not greater; 2: new is not valid semver; 3: base version not valid semver
  set +e
  OLD="$old" NEW="$new" node -e '
    const re=/^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9]\d*|\d*[A-Za-z-][0-9A-Za-z-]*))*))?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$/;
    const p=v=>{const m=re.exec(v||"");return m&&{n:[+m[1],+m[2],+m[3]],pre:m[4]?m[4].split("."):[]}};
    const cmp=(a,b)=>{for(let i=0;i<3;i++)if(a.n[i]!==b.n[i])return a.n[i]<b.n[i]?-1:1;
      if(!a.pre.length||!b.pre.length)return a.pre.length===b.pre.length?0:a.pre.length?-1:1;
      for(let i=0;i<Math.max(a.pre.length,b.pre.length);i++){const x=a.pre[i],y=b.pre[i];
        if(x===undefined)return -1;if(y===undefined)return 1;if(x===y)continue;
        const xn=/^\d+$/.test(x),yn=/^\d+$/.test(y);
        if(xn&&yn)return +x<+y?-1:1;if(xn)return -1;if(yn)return 1;return x<y?-1:1}
      return 0};
    const n=p(process.env.NEW),o=process.env.OLD?p(process.env.OLD):null;
    if(!n)process.exit(2);
    if(process.env.OLD&&!o)process.exit(3);
    if(!o)process.exit(0);
    process.exit(cmp(n,o)>0?0:1)'
  local rc=$?
  set -e
  case $rc in
    0) echo "version ok: ${old:-(none)} -> $new" ;;
    1) err "Files under plugin/ changed but the version was not raised (base ${old}, now ${new}). Raise \"version\" in plugin/.claude-plugin/plugin.json to a semver greater than ${old}." ;;
    3) err "the base commit's \"version\" ('${old}') is not valid semver, so the version cannot be compared. Fix \"version\" in $MANIFEST on the base branch first." ;;
    *) err "plugin/.claude-plugin/plugin.json \"version\" is missing or not valid semver (got: '${new}'). Set \"version\" to a valid x.y.z, greater than the base's (${old:-none})." ;;
  esac
}

case "${1:-}" in
  structure) structure ;;
  version)   [ -f "$MANIFEST" ] || { err "missing $MANIFEST"; exit 1; }; version_check ;;
  *) echo "usage: $0 structure|version" >&2; exit 2 ;;
esac
exit $fail

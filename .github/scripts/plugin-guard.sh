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

structure() {
  local f icon n s
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

  icon=$(jq -r '.icon // empty' "$MANIFEST")
  if [ -z "$icon" ]; then err "$MANIFEST names no \"icon\""
  elif [ ! -f "$P/$icon" ]; then err "the icon $MANIFEST names ($icon) is missing at $P/$icon"; fi

  n=0
  for f in "$P"/skills/*/SKILL.md; do
    [ -f "$f" ] || continue
    n=$((n+1))
    # frontmatter = lines between the first two '---' lines; name and description must be non-empty
    s=$(awk 'NR==1 && $0!="---"{exit} NR>1 && $0=="---"{exit} NR>1{print}' "$f")
    printf '%s\n' "$s" | grep -Eq '^name:[[:space:]]*[^[:space:]]' || err "$f: frontmatter has no name"
    printf '%s\n' "$s" | grep -Eq '^description:[[:space:]]*[^[:space:]]' || err "$f: frontmatter has no description"
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
  local base changed new old
  base=$(resolve_base)
  if [ -z "$base" ]; then
    changed=$(git ls-tree -r --name-only HEAD -- $P | sed -n 1p)   # first commit: everything is new
  else
    changed=$(git diff --name-only "$base"...HEAD -- $P)
  fi
  if [ -z "$changed" ]; then echo "nothing under $P/ changed; no version bump needed"; return 0; fi
  echo "changed under $P/ (base ${base:-none}):"; printf '  %s\n' $changed

  new=$(jq -r '.version // empty' "$MANIFEST")
  old=""
  if [ -n "$base" ]; then old=$(git show "$base:$MANIFEST" 2>/dev/null | jq -r '.version // empty' 2>/dev/null || true); fi

  # exit 0: new > old (or old absent and new valid); 1: not greater; 2: new is not valid semver
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
    if(!o)process.exit(0);
    process.exit(cmp(n,o)>0?0:1)'
  local rc=$?
  set -e
  case $rc in
    0) echo "version ok: ${old:-(none)} -> $new" ;;
    1) err "Files under plugin/ changed but the version was not raised (base ${old}, now ${new}). Raise \"version\" in plugin/.claude-plugin/plugin.json to a semver greater than ${old}." ;;
    *) err "plugin/.claude-plugin/plugin.json \"version\" is missing or not valid semver (got: '${new}'). Set \"version\" to a valid x.y.z, greater than the base's (${old:-none})." ;;
  esac
}

case "${1:-}" in
  structure) structure ;;
  version)   [ -f "$MANIFEST" ] || { err "missing $MANIFEST"; exit 1; }; version_check ;;
  *) echo "usage: $0 structure|version" >&2; exit 2 ;;
esac
exit $fail

#!/bin/bash
# Split a rooted binary Newick tree at the root; print the smaller side.
# stdout: names only.  -o FILE: full report (stats + names).
set -euo pipefail

PROG=$(basename "${BASH_SOURCE[0]}")

usage() {
    cat >&2 <<EOF
Usage: $PROG [-o FILE] <tree.nwk>

Split a rooted binary Newick tree at the root and list the taxa of the
smaller side.

  stdout    taxon names on a single line, space separated, in tree order
  -o FILE   also write the full report (stats + names) to FILE
  -h        show this help
EOF
    exit "${1:-0}"
}

out=''
tree=''

while [[ $# -gt 0 ]]; do
    case $1 in
        -o)
            [[ $# -ge 2 ]] || { echo "$PROG: -o requires a file name" >&2; exit 2; }
            out=$2
            shift 2
            ;;
        -h|--help)
            usage 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "$PROG: unknown option: $1" >&2
            usage 2
            ;;
        *)
            [[ -z $tree ]] || { echo "$PROG: unexpected argument: $1" >&2; usage 2; }
            tree=$1
            shift
            ;;
    esac
done

while [[ $# -gt 0 ]]; do
    [[ -z $tree ]] || { echo "$PROG: unexpected argument: $1" >&2; usage 2; }
    tree=$1
    shift
done

[[ -n $tree ]] || usage 2
[[ -r $tree ]] || { echo "$PROG: cannot read file: $tree" >&2; exit 1; }

# Single pass over the Newick string: a comma at depth 1 separates the two
# root children; a label after '(' or ',' is a tip, after ')' an internal node.
run_awk() {
    awk -v outf="$2" '
    BEGIN { depth = 0; g = 1; n1 = 0; n2 = 0; ntop = 0; tok = ""; kind = "none"
            lab1 = ""; lab2 = ""; rootlab = "" }

    { buf = buf $0 }

    END {
        gsub(/[ \t\r\n]/, "", buf)
        sub(/^\[&[RU]\]/, "", buf)
        sub(/;.*$/, "", buf)

        if (substr(buf, 1, 1) != "(") {
            err("error: not a Newick tree (expected leading parenthesis)")
            exit 2
        }

        L = length(buf)
        for (i = 1; i <= L; i++) {
            c = substr(buf, i, 1)
            if (c == "(") { flush(); depth++; kind = "child"; continue }
            if (c == ")") { flush(); depth--; kind = "inner"; continue }
            if (c == ",") {
                flush()
                if (depth == 1) { ntop++; g = 2 }
                kind = "child"
                continue
            }
            if (c == ":") { flush(); kind = "num"; continue }
            tok = tok c
        }
        flush()

        if (ntop != 1) {
            err(sprintf("error: root has %d children, tree is not bifurcating", ntop + 1))
            exit 2
        }
        if (n1 == 0 || n2 == 0) {
            err("error: one side has no tips")
            exit 2
        }

        rep(sprintf("Total tips: %d", n1 + n2))
        rep(sprintf("Root label: %s", (rootlab == "" ? "(none)" : rootlab)))
        rep(sprintf("Branch 1: %d tips, crown label %s", n1, (lab1 == "" ? "(none)" : lab1)))
        rep(sprintf("Branch 2: %d tips, crown label %s", n2, (lab2 == "" ? "(none)" : lab2)))

        if (n1 < n2) {
            rep(sprintf("Smaller branch: 1 (%d tips, %.1f%% of total)", n1, 100 * n1 / (n1 + n2)))
            out(lined(n1, 1))
        } else if (n2 < n1) {
            rep(sprintf("Smaller branch: 2 (%d tips, %.1f%% of total)", n2, 100 * n2 / (n1 + n2)))
            out(lined(n2, 2))
        } else {
            rep(sprintf("Tie: %d vs %d tips, both sides listed", n1, n2))
            out("# branch1 " lined(n1, 1))
            out("# branch2 " lined(n2, 2))
        }
    }

    function rep(s) { if (outf != "") print s > outf }
    function err(s) { print s > "/dev/stderr" }
    function out(s) { print s; if (outf != "") print s > outf }

    function lined(n, side,   s, i) {
        s = ""
        for (i = 1; i <= n; i++)
            s = s (i > 1 ? " " : "") (side == 1 ? leaf1[i] : leaf2[i])
        return s
    }

    function flush() {
        if (tok == "") return
        if (kind == "child") {
            if (g == 1) leaf1[++n1] = tok
            else        leaf2[++n2] = tok
        } else if (kind == "inner") {
            if (depth == 0)      rootlab = tok
            else if (depth == 1) { if (g == 1) lab1 = tok; else lab2 = tok }
        }
        tok = ""
    }
    ' "$1"
}

if [[ -n $out ]]; then
    : > "$out"
    run_awk "$tree" "$out"
else
    run_awk "$tree" ""
fi
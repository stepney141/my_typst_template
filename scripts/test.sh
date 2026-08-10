#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v typst >/dev/null 2>&1; then
  echo "error: typst is required" >&2
  exit 1
fi

font_args=()
if [[ -n "${TYPST_TEST_FONT_PATH:-}" ]]; then
  font_args=(--font-path "$TYPST_TEST_FONT_PATH")
fi

if [[ -n "${TYPST_TEST_OUTPUT_DIR:-}" ]]; then
  output_dir="$TYPST_TEST_OUTPUT_DIR"
  mkdir -p "$output_dir"
  remove_output=false
else
  output_dir="$(mktemp -d /tmp/typst-template-test.XXXXXX)"
  remove_output=true
fi

cleanup() {
  if [[ "$remove_output" == true ]]; then
    rm -rf "$output_dir"
  fi
}
trap cleanup EXIT

mkdir -p "$output_dir/pdfs"

typst compile "リアペ・レポートサンプル/main.typ" "$output_dir/pdfs/report.pdf" \
  --root "$repo_root" --creation-timestamp 0 "${font_args[@]}"
typst compile "卒論・修論サンプル/main.typ" "$output_dir/pdfs/thesis.pdf" \
  --root "$repo_root" --creation-timestamp 0 "${font_args[@]}"

for fixture in tests/fixtures/*.typ; do
  name="$(basename "$fixture" .typ)"
  typst compile "$fixture" "$output_dir/pdfs/$name.pdf" \
    --root "$repo_root" --creation-timestamp 0 "${font_args[@]}"
done

echo "All Typst compile checks passed."

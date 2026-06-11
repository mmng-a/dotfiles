---
name: codex-image-gen
description: >-
  Generate or edit raster images (photos, illustrations, mascots/yuru-chara,
  product mockups, UI mockups, hero images, logos, textures, sprites, banners,
  infographics, cutouts) by delegating to the Codex CLI's built-in `imagegen`
  skill via `codex exec`. Use this whenever the user wants an AI-generated
  bitmap image and you are running in Claude Code without a native image tool —
  e.g. "画像を生成して", "マスコットを作って", "make an illustration / hero image /
  product shot / icon art", "generate a picture of ...", or "edit this image".
  Prefer this over hand-writing SVG/HTML/CSS placeholders when the user clearly
  wants a generated picture. Do NOT use it for vector/icon-system edits that
  belong in repo-native SVG, or when a dedicated image MCP tool is available.
---

# Codex Image Generation

> **Codex で実行している場合は、このスキルを使わないこと。** Codex はネイティブの
> 画像生成（組み込み `imagegen` / `image_gen` ツール、`~/.codex/skills/.system/imagegen`）
> を直接持っているため、`codex exec` を経由せずそれを使う。このスキルは、ネイティブの
> 画像生成手段を持たない **Claude Code 専用**の橋渡しである。

Claude Code has no native image-generation tool, but the locally installed
**Codex CLI** ships a built-in `imagegen` skill backed by an `image_gen` tool
(model `gpt-image-2`). This skill drives that capability from Claude Code by
running `codex exec` non-interactively: you write the full image spec, Codex
generates the bitmap and copies it into the workspace, and you verify the
result by reading it back.

Why delegate instead of doing it directly: the `image_gen` tool lives inside
Codex's runtime, not in Claude Code. `codex exec` is the clean, scriptable
bridge — it runs one turn, uses the skill, saves the file, and prints the path.

## Prerequisites (check once, fail clearly)

- `codex` must be on `PATH`. Verify with `which codex`. If missing, tell the
  user to install the Codex CLI and stop — don't invent a fallback.
- The built-in `image_gen` tool does **not** require `OPENAI_API_KEY`. Never ask
  the user for a key for the normal path.

## Core workflow

1. **Pin down the spec.** Decide use case, subject, style, composition,
   palette, background, and any verbatim text. If the user was vague (e.g.
   "make a Tokyo mascot"), it is your job to make the creative decisions and
   write a concrete, detailed spec — a sharper prompt produces a better image.
   Only ask the user when a missing detail genuinely blocks success.

2. **Choose the output path.** Pick a destination inside the current
   workspace, e.g. `output/<name>.png`. Project-bound assets must end up in the
   repo, not left in Codex's cache.

3. **Run `codex exec`** with a prompt that (a) tells Codex to use its imagegen
   skill, (b) contains the full spec, and (c) instructs it to copy the final
   image to your chosen workspace path and report that path.

   ```bash
   codex exec -s workspace-write --skip-git-repo-check "imagegen スキルを使って画像を1枚生成してください。

   <full image spec — see template below>

   生成後、選んだ最終画像を必ずこのワークスペースの output/<name>.png にコピーし、最終的な保存パスを報告してください。" 2>&1 | tail -40
   ```

   - `-s workspace-write` lets Codex write the copied file into the repo.
   - `--skip-git-repo-check` avoids a prompt when run outside a clean repo root.
   - `| tail -40` trims Codex's verbose trace to the final summary; raise the
     number if you need to see what it did.
   - This call can take a minute or more — give the Bash tool a generous
     timeout (e.g. 600000 ms).

4. **Verify.** Use the Read tool on the saved path to view the image, and
   confirm subject, style, text accuracy, and any "avoid" constraints. If it's
   off, re-run with one targeted change rather than rewriting the whole prompt.

5. **Report** the saved workspace path, a one-line description of what was
   generated, and offer concrete follow-ups (variants, recolor, transparent
   background, different aspect ratio).

## Prompt spec template

Write the spec in the user's language (Japanese is fine). Include only the
lines that matter; omit the rest. Be concrete — name colors, framing, and mood.

```text
Use case: <photorealistic / product-mockup / ui-mockup / illustration / logo-brand / mascot / infographic ...>
Primary request: <the one-line goal>
Subject: <the main subject, described in detail>
Style/medium: <photo / flat vector illustration / 3D render / watercolor ...>
Composition/framing: <full-body / close-up / wide with negative space / centered ...>
Color palette: <key colors and accents>
Background: <plain white / scene / transparent-style ...>
Text (verbatim): "<exact text to render, letter-for-letter>"   # omit if none
Constraints: <must-keep items; e.g. single character, clean for merch>
Avoid: <no logos, no watermark, no extra characters ...>
```

For **edits** (modifying an existing image while preserving most of it), state
the invariants explicitly — "change only X; keep Y unchanged" — and repeat them
if you iterate. Built-in edits operate on images already in the conversation;
for a local file, mention its path and let Codex load it.

## Size and quality notes (gpt-image-2)

- Default is a square `1024x1024`. Specify a size in the prompt when you need
  another aspect ratio. Common sizes: `1024x1024` (square), `1536x1024`
  (landscape), `1024x1536` (portrait), `2048x2048` (2K square), `3840x2160`
  (4K landscape). Constraints: max edge ≤ 3840px, both edges multiples of 16,
  long:short ≤ 3:1.
- Use low quality for quick drafts, high/auto for final assets, dense text, or
  identity-sensitive work — say so in the prompt.

## Transparent backgrounds

The built-in path can't output true alpha directly. For a simple opaque
subject, ask for a flat solid `#00ff00` chroma-key background (use `#ff00ff`
for green subjects) and then key it out locally. For complex subjects (hair,
fur, glass, smoke, soft shadows) true transparency needs Codex's CLI fallback
with `gpt-image-1.5`, which **requires `OPENAI_API_KEY`** — confirm with the
user before going down that path.

## Worked example (Tokyo mascot)

```bash
codex exec -s workspace-write --skip-git-repo-check "imagegen スキルを使って画像を1枚生成してください。

Use case: mascot (ゆるキャラ)
Primary request: 東京をテーマにした、かわいいゆるキャラ風マスコットキャラクター
Subject: 丸みのある親しみやすい体型。頭に赤と白の東京タワー型の帽子。大きな瞳、ぷっくり頬、笑顔、片手を上げて手を振る全身ポーズ。桜の花を小さくワンポイント。
Style/medium: フラットで清潔感のあるベクター風イラスト、太めの輪郭線。
Composition/framing: 全身、中央配置、周囲に余白。
Color palette: 赤(#e8380d系)と白を基調、桜ピンクをアクセント。
Background: 真っ白な無地背景。
Avoid: 文字・ロゴ・透かしなし。キャラクターは1体のみ。

生成後、選んだ最終画像を必ずこのワークスペースの output/tokyo-mascot.png にコピーし、最終的な保存パスを報告してください。" 2>&1 | tail -40
```

Then `Read` `output/tokyo-mascot.png` to confirm before reporting.

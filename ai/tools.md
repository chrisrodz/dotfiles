# Tools Reference

Common tools expected on this setup. Use the repo-local helper if it exists.

## gh

GitHub CLI for PRs, issues, CI.

## committer

Selective commit helper. Location: `ai/scripts/committer` (symlinked to `~/.local/bin/committer`).

## docs-list

Lists docs and `read_when` hints. Location: `ai/scripts/docs-list.ts` (run via `bun` or `tsx`).

## trash

Safe delete CLI (`brew install trash`). Use instead of `rm` when possible.

## tmux

Use for long-running or interactive sessions.

## yt-dlp / ffmpeg

Required for `video-transcript-downloader` skill when subtitles or media downloads are needed.

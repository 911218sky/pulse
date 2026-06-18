# Playback Resume Debug

## Observations

- User reports UI jumps to the saved position, then immediately returns to `0:00` and playback starts there.
- Saved position is read: otherwise the UI would not jump to the saved position first.
- `PlayerBloc` listens to `AudioRepository.positionStream`, which is currently raw `media_kit` `_player.stream.position`.
- `MusicPlayerAudioHandler.loadAudio()` sets `_position = initialPosition`, then opens media, then seeks.
- `MusicPlayerAudioHandler._init()` overwrites `_position` with every raw player position event, including delayed `0:00`.

## Hypotheses

### H1: Delayed raw `0:00` position event overwrites restored position (ROOT)

- Supports: exact symptom is saved position first, then `0:00`.
- Supports: `play()` uses `_position` as `resumePosition`, so an overwritten `_position` can reopen/play from zero.
- Conflicts: local tests do not model raw delayed `0:00` yet.
- Test: after loading with saved position, emit `0:00`; BLoC should keep saved position.

### H2: `seek(initialPosition)` happens before media is fully ready

- Supports: media backends can ignore early seeks.
- Conflicts: UI does show saved position before the reset.
- Test: model a post-load zero event from player.

### H3: Last playback state and per-file position disagree

- Supports: there are two persistence paths.
- Conflicts: the visible jump proves the selected saved position exists.
- Test: existing per-file load test covers the selected saved position.

## Experiments

- Added regression test for delayed zero after saved-position load.
- Before the fix, the test failed with actual position `0:00`.
- After the fix, the test passes and keeps the saved position.

## Root Cause

`media_kit` can emit a delayed `0:00` position after loading/seeking to the saved position, and that event overwrote both UI state and the handler's resume position.

## Fix

Hold the saved resume position until the player reports that position or later, and re-seek to it before playback starts.

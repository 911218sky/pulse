# Playback Position Debug

## Observations

- User reports that playback does not remember the last position and the next playback starts from the beginning.
- User clarified a second symptom: the position is saved, but later pressing play does not continue from that saved position.
- User identified commit `e049dcf916e301863834bb9c46cdbc5e1a839117` as a version where resume worked correctly.
- Current `PlayerBloc` persists playback state in `_saveCurrentPlaybackState()`, but that function is only triggered by:
  - `PlayerSeekTo`
  - `PlayerPause`
  - `PlayerStop`
  - periodic auto-save while `state.isPlaying`
  - `close()`
- Current `PlaylistAudioSync.didChangeAppLifecycleState()` now sends `PlayerSaveState` on `inactive`, `paused`, and `detached`.
- Current `MusicPlayerAudioHandler.onTaskRemoved()` no longer stops/disposes the handler. It only calls `pause()` to keep Android notification controls alive.
- `PlayerBloc._onPlayingStateUpdated()` updates `playing/paused` state from the audio stream, but does not save playback state when playback becomes paused externally.
- External pause paths exist:
  - Android/media-session button events update the handler directly.
  - `onTaskRemoved()` pauses directly in the handler.
- Existing tests cover explicit seek and startup restore, but there is no test covering external `playing=false` updates while preserving the current position.
- `PlayerBloc._onPlay()` currently just calls `_audioRepository.play()` and never re-seeks to `state.position`.
- `MusicPlayerAudioHandler.play()` resumes from the handler's private `_position`, not from `PlayerBloc.state.position`.
- If the handler loses or resets its in-memory position but the bloc still knows the saved position, pressing play can start from zero.

## Hypotheses

### H1: External pause events do not persist the current playback position (ROOT HYPOTHESIS)
- Supports:
  - `PlayerPause` saves, but `_onPlayingStateUpdated(isPlaying: false)` does not.
  - `onTaskRemoved()` now pauses instead of stopping/disposing, so the old save-on-close path is less reliable.
  - This matches a user-visible symptom where playback later resumes from an older or zero position.
- Conflicts:
  - Periodic auto-save can still save progress if the app stays alive long enough.
- Test:
  - Add a bloc test that loads audio, advances position, emits `playing=false` from the audio stream, and expects the repository to save the current position.

### H2: Position is saved, but startup restore is not always triggered
- Supports:
  - Restore depends on `FileScannerSync` initial library load flow.
  - Runtime wiring can differ from bloc-only tests.
- Conflicts:
  - Existing restore tests pass and current code explicitly dispatches `PlayerRestoreFromLibrary`.
- Test:
  - Verify startup flow dispatches restore after initial library load and only when library files are available.

### H3: The saved position is cleared accidentally because the track is treated as completed
- Supports:
  - `_saveCurrentPlaybackState()` clears state when `position >= duration`.
  - Duration updates are asynchronous and could be stale.
- Conflicts:
  - User reports general restart-from-beginning behavior, not only near-track-end behavior.
- Test:
  - Reproduce with a mid-track position and confirm whether the repository is cleared or saved.

### H4: Manual play does not restore the known paused position (ROOT HYPOTHESIS)
- Supports:
  - `_onPlay()` does not call `seekTo(state.position)`.
  - `audio_handler.play()` relies on handler-local `_position`, which may differ from bloc state after restore or process recreation.
  - This matches the clarified symptom: saved position exists, but pressing play starts from the beginning.
- Conflicts:
  - If the handler still has the correct in-memory `_position`, pressing play can still work.
- Test:
  - Add a bloc test where playback is paused at a non-zero position, then `PlayerPlay` is dispatched and must re-seek to that stored position before playing.

## Experiments

### E1: Add a regression test for external pause persistence
- Change:
  - Add one test in `player_bloc_test.dart` covering `playing=false` after a position update.
- Expected if H1 is correct:
  - Test fails before the fix because the fake repository does not receive a saved position.
- Result:
  - Confirmed. The new test failed with `Actual: <null>` for the saved position after an external `playing=false` event.

### E2: Add a regression test for manual play after pause
- Change:
  - Add one test in `player_bloc_test.dart` that pauses at a non-zero position and then dispatches `PlayerPlay`.
- Expected if H4 is correct:
  - Test fails before the fix because `PlayerPlay` does not issue `seekTo()` for the stored position.
- Result:
  - Confirmed. The new test failed because the seek call list stayed empty when `PlayerPlay` ran after pausing at `0:00:47`.

## Root Cause

- Two gaps existed:
  - Playback position was not persisted when playback became paused through external audio-service events, because `PlayerBloc._onPlayingStateUpdated()` changed UI state to `paused` but never saved the current playback state.
  - Even when a paused position was known in bloc state, `PlayerBloc._onPlay()` did not seek back to that position before calling `play()`, so playback could restart from zero if the handler's in-memory position had drifted or reset.

## Fix

- Save the current playback state when `PlayerBloc` transitions from `playing` to `paused` through `PlayerPlayingStateUpdated(isPlaying: false)`.
- When `PlayerPlay` resumes from a paused state, seek to `state.position` first, then call `play()`.

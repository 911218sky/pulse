# Playback Position Debug

## Observations

- User reports that playback does not remember the last position and the next playback starts from the beginning.
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

## Experiments

### E1: Add a regression test for external pause persistence
- Change:
  - Add one test in `player_bloc_test.dart` covering `playing=false` after a position update.
- Expected if H1 is correct:
  - Test fails before the fix because the fake repository does not receive a saved position.
- Result:
  - Confirmed. The new test failed with `Actual: <null>` for the saved position after an external `playing=false` event.

## Root Cause

- Playback position was not persisted when playback became paused through external audio-service events, because `PlayerBloc._onPlayingStateUpdated()` changed UI state to `paused` but never saved the current playback state.

## Fix

- Save the current playback state when `PlayerBloc` transitions from `playing` to `paused` through `PlayerPlayingStateUpdated(isPlaying: false)`.

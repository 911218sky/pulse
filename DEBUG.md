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

## Observations - 2026-06-18 Follow-up

- User reported that playback state is saved, but pressing play after restore can still start from the beginning.
- A focused regression test with saved path `/music/./track-normalized.mp3` and library path `/music/track-normalized.mp3` timed out because restore never found the saved audio file.
- `PlayerBloc._onRestoreFromLibrary()` matched saved playback state by raw string equality: `file.path == lastState.audioFilePath`.
- The project already has `AudioPathUtils.canonicalize()` and repository guidance says audio path comparisons must use canonicalized paths.
- User also reported app updates sometimes cannot install, and downloaded APKs should be cached for retry instead of downloaded again.
- `UpdateFlowController.checkForUpdate()` deleted all downloaded installers before showing the update prompt.
- `UpdateDownloadService.openInstaller()` deleted downloaded installers five minutes after handing the file to the system installer.
- `UpdateDownloadService.download()` opened the network request before checking whether the same update asset already existed locally.

## Hypotheses - 2026-06-18 Follow-up

### H5: Restore misses the saved track when equivalent paths are formatted differently (ROOT HYPOTHESIS)
- Supports:
  - The failing test uses two equivalent paths that differ only by `./`.
  - Existing code compares paths using raw string equality.
  - The database migration canonicalizes playback paths, but older or external state can still contain non-canonical path text.
- Conflicts:
  - Exact path matches already work.
- Test:
  - Restore from library with equivalent but non-identical saved/library paths must load, seek, and play the saved track.

### H6: Update install retry redownloads because the app deletes or ignores cached installers (ROOT HYPOTHESIS)
- Supports:
  - Update check deletes installers before prompting.
  - Opening the installer schedules cleanup shortly after install handoff.
  - Download starts network I/O before checking the target cached file.
- Conflicts:
  - A retry can work if the network is still available and the server responds.
- Test:
  - Pre-create the expected installer file and inject an HTTP client that fails if used; download must return the cached file without network access.

### H7: Failed partial downloads could be mistaken as reusable installers
- Supports:
  - Download previously wrote directly to the final APK path.
  - A future cache-first check would treat any non-empty final file as reusable.
- Conflicts:
  - No direct user report of corrupt cached APKs yet.
- Test:
  - Simulate content length mismatch; service must throw and leave neither final installer nor partial download behind.

## Experiments - 2026-06-18 Follow-up

### E3: Normalized restore regression
- Change:
  - Added `restore from library matches saved track with normalized path`.
- Result:
  - Failed before the fix with a 30 second timeout because no playing state was emitted.
  - Passed after comparing restore candidates with `AudioPathUtils.canonicalize()`.

### E4: Cached installer regression
- Change:
  - Added `reuses a fully downloaded installer for the same update` with a fake HTTP client that throws on network access.
- Result:
  - Failed before the fix because `UpdateDownloadService.download()` called `getUrl()` before considering the cached file.
  - Passed after resolving the target installer file first and returning it when non-empty.

### E5: New version cleanup regression
- Change:
  - Added `clears older cached installers after a new update downloads`.
- Result:
  - Passed after moving cleanup to after a successful download while keeping the new installer.

### E6: Partial download regression
- Change:
  - Added `does not cache incomplete downloads as installers`.
- Result:
  - Passed after downloading to a `.download` temporary file, checking byte count, and renaming only after success.

## Root Cause - 2026-06-18 Follow-up

- Playback restore could silently skip a valid saved track because restore compared raw file paths instead of canonicalized paths.
- The update flow made install retry unreliable because it deleted cached installers during update checks and after installer handoff, while the downloader ignored an already cached installer until after opening a network connection.

## Fix - 2026-06-18 Follow-up

- Use `AudioPathUtils.canonicalize()` when matching saved playback state to scanned library files.
- Reuse an existing cached installer before network access when the same version and asset are already downloaded.
- Keep downloaded installers after handing them to Android so permission/install retries do not require a redownload.
- Remove update-check-time cleanup; old installers are cleared only after a newer installer successfully downloads.
- Write downloads to `.download` temporary files and promote them to installer cache only after the full content is received.

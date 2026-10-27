# One More Heist — Architecture

## 1. Purpose and scope

This document describes the source that exists today and a practical architecture for completing and extending One More Heist. It is guidance for implementation, not a claim that the proposed systems already exist and not a substitute for a later `MVP_SPEC.md`.

The intended loop is:

```text
Headquarters → begin heist → play room → earn unbanked cash
                                ↑                 ↓
                                └── continue ← decision
                                                  ↓
                                           cash out or fail
                                                  ↓
                                            run results
                                           /           \
                              retry: fresh session    headquarters
```

Cashout and failure end one run. Neither automatically ends the player's heist experience or forces a return to headquarters. Failure loses only the current run's unbanked cash. Later development adds persistent banked cash, upgrades, varied skill-based challenges, and empire progression without changing this separation.

Work proceeds with one coding agent, one small independently testable slice per task. Keep the existing services and session model; do not introduce a service framework, event bus, entity framework, matchmaking system, or separate places to complete the first playable loop.

## 2. Evidence and implementation status

Repository: `patricksullivan123411223344/one_more_heist`.

Source review date: October 27, 2026. All repository reads were pinned to the default branch `main` at commit [`d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf`](https://github.com/patricksullivan123411223344/one_more_heist/tree/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf), the latest main head observed during inspection. The complete recursive tree was inspected, including every source file, test, and configuration file. No `GAME_OVERVIEW.md`, existing architecture document, dependency manifest, CI workflow, or test-runner configuration appears in that tree. The referenced conversation's overview attachment was not available as readable content; the product direction above comes from the current request.

**Implemented** below means present in inspected source, not verified in a running Roblox Studio session. **Proposed** means an architectural decision or work still to implement. Function names in proposed sections are suggested contracts, not existing APIs.

### Current source inventory

| Source | Implemented behavior | Limit or gap |
| --- | --- | --- |
| [`src/server/main.server.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/server/main.server.luau) | Requires three modules; creates headquarters/heist platforms and entrance/exit parts with `ProximityPrompt`s; connects entrance to `StartHeist` and exit to `ExitHeist`; sends newly added players' characters to base after waiting for `HumanoidRootPart`. | No room challenge, reward, continue, cashout, failure, retry, disconnect, or death wiring. Existing players/characters are not explicitly initialized. World positions are hardcoded here. |
| [`src/services/HeistService.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/services/HeistService.luau) | Private `ActiveSessions` table keyed by `UserId`. `StartHeist` rejects an existing entry, constructs a session, stores it, and returns true. `EndHeist` removes an existing entry. | Start does not move the player. End does not settle, clean up a room, or move the player. Imported `Config` is unused. No public lookup or other gameplay operations. |
| [`src/systems/HeistSession.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/systems/HeistSession.luau) | Constructor, reward accumulation, room completion, continuation, cashout calculation, and failure cash clearing are defined. | Terminal-state bugs and incomplete guards described below. These methods are not wired into the server bootstrap's gameplay loop. |
| [`src/services/BaseService.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/services/BaseService.luau) | `SendToBase` returns early without a character; otherwise uses `PivotTo` with the configured base position. | No success/failure result contract, session coordination, or retry for a missing character. |
| [`src/systems/ExitSystem.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/systems/ExitSystem.luau) | `ExitHeist` logs and calls `BaseService.SendToBase`. | Does not call `EndHeist` or inspect run status. A moved player can retain an entry that prevents starting again. |
| [`src/shared/Config.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/shared/Config.luau) | Base spawn `(0,5,0)`, heist spawn `(150,5,0)`, and `NewRoom` position `(300,5,0)`. | Heist positions are not consumed by the current start flow. No difficulty or reward rules. |
| [`src/client/main.client.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/src/client/main.client.luau) | Prints an initialization message. | No UI, input controller, or RemoteEvent handling. |
| [`tests/heist_session.test.luau`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/tests/heist_session.test.luau) | Asserts a local addition helper returns `1500`. | Does not require or exercise `HeistSession`; its success would not validate session behavior. |

### Current session semantics and defects

The constructor sets `UserId`, `CurrentRoom = 1`, `UnbankedCash = 0`, `HeistStatus = "InProgress"`, and `RoomStatus = "InProgress"`.

- `AddReward(amount)` checks `HeistStatus == "InProgress"` and `amount > 0`. It does not enforce finite integer amounts, a room identity, or one reward per room.
- `CompleteRoom()` checks only `RoomStatus`, then sets it to `Completed` and sets `HeistStatus` to `CanCashOut`. It does not verify that the run is active.
- `ContinueHeist()` checks `CanCashOut`, increments the room index, and resets both statuses to `InProgress`.
- `CashOut()` checks `CanCashOut`, returns the current cash, and assigns **`self.Status = "Completed"`**, leaving `HeistStatus` unchanged. It neither clears cash nor records a settlement. Repeated calls can return the same amount and continuation remains possible.
- `HeistFail()` rejects `CanCashOut`, `Completed`, and `Failed` heist states and a completed room, clears cash, and assigns **`self.Status = "Failed"`**. It leaves `HeistStatus` and `RoomStatus` unchanged, allowing later operations that should be blocked.

Fix these invariants before connecting real rewards or payouts. There is no implemented banking or persistence to protect against duplicate credits today.

## 3. Boundaries, ownership, and dependency direction

### Proposed ownership using existing modules

| Boundary | Owner | Responsibility |
| --- | --- | --- |
| Composition and Roblox events | `main.server.luau` | Require modules, create prototype world, bind prompts/remotes and player lifecycle once, route requests into the service. Avoid embedding run rules in callbacks. |
| Player's heist orchestration | `HeistService` | Own registry, authorize actions, select the current session, coordinate challenge lifecycle, placement, terminal results, settlement, retry, and cleanup. |
| One run's rules | `HeistSession` | Own statuses, room index, unbanked cash, run identity, and valid transitions. Return explicit results. No Roblox instance creation, player movement, persistence, remotes, or service imports. |
| Headquarters placement | `BaseService` | Move a valid current character to headquarters and report placement outcome. Do not mutate money or decide run outcomes. |
| Return interaction adapter | `ExitSystem` | If retained, delegate return intent to `HeistService`; no independent session mutation or bypass of abandonment rules. Remove the wrapper later if it adds no value. |
| One physical challenge | Small server challenge module, added when needed | Create/reset its room, validate completion/failure, report one outcome, and release connections/instances. Do not bank cash or advance sessions directly. |
| Presentation | `main.client.luau`, split only as it grows | Display authoritative state, collect intent, animate feedback. Never determine rewards or final outcomes. |
| Shared definitions | `Shared.Config`, future small types/protocol module if needed | Public configuration, types, and message shapes. No mutable authoritative state or secrets. |
| Durable progression, later | Small player-data module/service | Load/save banked cash and owned upgrades, apply a run settlement once, expose authoritative purchase operations. Add only when persistence work begins. |

Proposed dependency direction:

```text
server bootstrap / ExitSystem adapter
                    ↓
               HeistService
              /     |      \
     HeistSession  challenge  BaseService
                    |
              Roblox world

HeistService → player-data boundary (later)
server/client → shared public definitions
client → request transport → server service → snapshot/result → client
```

The current `ExitSystem → BaseService` path exists but must stop bypassing lifecycle coordination. Avoid circular dependencies: `BaseService`, sessions, challenges, and future data code never call back into `HeistService`. A challenge reports an outcome through a supplied callback; the service decides what it means. Start with ordinary module calls and injected callbacks, not a global event bus.

## 4. Lifecycle and state model

### Proposed canonical run states

Keep the existing `HeistStatus` values and consistently write that field. Do not add a second `Status` field. `RoomStatus` remains `InProgress`, `Completed`, or `Failed`.

| Current heist status | Accepted event | Next heist / room status | Effect |
| --- | --- | --- | --- |
| No session, headquarters | Begin | `InProgress` / `InProgress` | Create a new run at room 1 with zero unbanked cash; prepare challenge and place character. |
| `InProgress` / `InProgress` | Valid room success | `CanCashOut` / `Completed` | Award the server-defined room reward once and expose continue/cashout. |
| `CanCashOut` / `Completed` | Continue | `InProgress` / `InProgress` | Increment room index once; prepare the next harder challenge. |
| `CanCashOut` / `Completed` | Cash out | `Completed` / `Completed` | Freeze payout, clear live unbanked cash, settle once, show results. |
| `InProgress` / `InProgress` | Valid challenge failure, death, or reset | `Failed` / `Failed` | Freeze loss summary, clear unbanked cash, pay zero, show results when connected. |
| Active run, including `CanCashOut` | Explicit abandon/return or disconnect | `Failed` / preserve completed room or mark active room failed | Forfeit unbanked cash; cleanup. Return moves to headquarters; disconnect has no UI or movement. |
| `Completed` or `Failed` | Retry after settlement resolves | New session: `InProgress` / `InProgress` | Dispose old run resources; create a different run identity with room 1 and zero cash. |
| `Completed` or `Failed` | Return after settlement resolves | No session, headquarters | Dispose old run resources and move to base. |

All other transitions reject with a reason and no mutation. In particular, cashout during an active challenge is invalid; success, reward, or continue after a terminal outcome is invalid. Normal challenge failure is accepted only during an active room. Abandonment must also work at a decision point, so it must not reuse the current `HeistFail()` guards unchanged.

Headquarters, run results, placement readiness, and data readiness are **player flow concerns**, not extra values mixed into `HeistStatus`. Results retain the terminal session and its immutable summary until retry or return. A small per-player busy/settlement flag is sufficient for asynchronous orchestration; avoid a second competing run state machine.

### Session invariants

1. At most one registered session per user. Every new attempt has a server-generated `RunId`; a retry never reopens an old session.
2. Room index is a positive integer. Unbanked cash is a finite nonnegative integer under a chosen server limit.
3. A room result is accepted once, only for the current run and current room attempt.
4. Reward and successful room completion form one authoritative operation. Do not leave `AddReward` and `CompleteRoom` separately callable by arbitrary input handlers. They may remain internal helpers, called without a yield between them.
5. Terminal state is irreversible. Cashout freezes its payout before any yielding operation. Failure cannot erase previously banked money.
6. Store an immutable terminal summary: run ID, outcome/reason, rooms completed, payout, and lost unbanked cash. Record loss before clearing the cash.
7. Invalid operations leave state unchanged. Expose snapshots rather than returning mutable registry tables to callers or clients.

Suggested service operations are `StartHeist`, `ContinueHeist`, `CashOut`, `FailHeist`, `RetryHeist`, `ReturnToBase`, and an internal room-result handler. Only `StartHeist` and `EndHeist` currently exist. Keep `EndHeist` as internal disposal or rename it when implementing this contract; deleting a registry entry is not settlement.

## 5. Registry and resource lifetime

Retain the private `ActiveSessions[userId]` ownership in `HeistService`. It can hold the terminal session while the player views results; the existing name need not trigger a separate results registry. Keep room handles, subscriptions, and placement/settlement flags alongside that session in a small service-owned record if needed, rather than placing Roblox objects into the pure rules object.

Every asynchronous callback captures `userId`, `RunId`, and a room-attempt token. Before mutating, compare those identities with the registry's current entry and confirm its status. A delayed success from room 1 or a prior retry must not affect the new room/run.

Starting rejects an existing entry, an unready character, or unavailable required player data. Reserve the entry before yielding for setup. If setup fails before play starts, clean partial resources, remove only that same entry, and recover to headquarters without inventing a gameplay loss. Continuing similarly closes the completed room's resources before installing the next attempt; technical setup failure should end as a technical abort with a clearly chosen compensation policy, not masquerade as player failure. For the prototype, restore access to cashout for the already earned amount if next-room setup fails before play begins.

Cleanup must be safe to call repeatedly: stop the challenge, disconnect callbacks, destroy only owned instances, invalidate attempt tokens, and remove the registry entry only if it still refers to that run. Do not let cleanup for run A remove run B after a retry.

## 6. Payouts, settlement, and player data

### Proposed prototype settlement

Distinguish **calculating a payout**, **crediting a balance**, and **saving a balance**. Current `CashOut()` only attempts the first and is defective; none of the three is a working end-to-end feature today.

For the initial local server prototype, keep an explicitly temporary banked balance in server memory, outside the run object. State clearly in the UI/testing notes that it resets on server loss or reconnect if not persisted. Avoid presenting a print statement or unbanked cash as a durable bank account.

Cashout processing order:

1. Validate player, run identity, decision state, and action eligibility.
2. Without yielding, transition `HeistStatus` to `Completed`, freeze the summary and payout, clear live unbanked cash, and claim settlement for this run.
3. Credit the authoritative balance through one settlement function keyed by `RunId`. A repeated request returns the same summary or `AlreadySettled`, never another credit.
4. Mark settlement resolved, publish the result, and enable retry/return. A technical failure remains pending with the same run ID; it must not reopen the run or generate a new payout.

Failure/abandonment use the same terminal-result path with payout zero. Two racing end requests cannot both win. A per-player busy guard plus synchronous state validation/claim is enough for the initial implementation; acquire it before any yield and release it on every error path. Avoid scattered credit operations in prompts, client handlers, or challenges.

### Later persistent settlement

Durable player data contains a schema version, banked cash, owned upgrades, and progression unlocks. Run state contains room progress, unbanked cash, run/attempt IDs, challenge resources, and terminal results. Do not save live run instances or restore an unfinished room as if it were a balance. Snapshot relevant upgrade effects when a run starts so purchases do not silently alter a running challenge.

When persistence is introduced, store the banked balance and settlement receipt together in one authoritative per-player update. Applying the same run ID again must return the prior result. A timeout may mean the write succeeded: retry that same operation/ID, never add cash blindly. A boolean on an in-memory session is insufficient across crashes or rejoins. Define receipt retention and profile/session ownership before pruning receipts or allowing overlapping server writers; do not claim permanent exactly-once behavior from a short-lived receipt list.

Data loading failure blocks money-dependent play/purchases; never overwrite a failed load with defaults. Save failure blocks further money-mutating actions until resolved or safely handed off. Prototype balance is not automatically a persistence implementation.

There remains a crash window before a settlement reaches durable storage. Receipt deduplication prevents duplicate application but does not by itself guarantee recovery of a never-recorded payout. Decide and test the desired crash recovery guarantee before a persistent economy ships. Use the established Roblox data mechanism selected at that phase; do not build a transaction service now.

## 7. Server, client, and interaction trust

**Current:** server-created `ProximityPrompt.Triggered` callbacks call services directly. There are no RemoteEvents in the inspected source or Rojo tree. The client only prints.

**Proposed:** keep prototype prompts until the loop works. Add a small remote contract when HUD/results buttons require it. Requests express intent (`Continue`, `CashOut`, `Retry`, `ReturnToBase`) plus expected run identity; they do not contain trusted payouts, user IDs, room completion, or arbitrary destinations. The server obtains the caller from the event, looks up its own registry, and validates status, identity, physical eligibility when relevant, character readiness, input shape, and request frequency. Treat prompts as input too: activation is not permission to bypass these checks.

Reject unknown actions, malformed or oversized fields, stale run/attempt IDs, nonfinite numbers, and spam before expensive work. Derive rewards and difficulty from server rules. A client may report an input or attempted interaction; the server verifies the challenge's success conditions. Cosmetic animation can be local; economy and progression cannot be.

Publish a compact snapshot containing run ID, revision, statuses, room index, unbanked cash, allowed actions, and the terminal summary when appropriate. Include banked balance only from the authoritative data boundary. Revisions let the client discard late snapshots. On UI readiness/reconnect, request a current snapshot rather than assuming the first event arrived. Keep snapshots limited to the receiving player's data.

Prefer one request event and one state event initially, created/bound once by the bootstrap in a clearly named replicated folder. This is a proposal, not an existing protocol. Client disable states improve feedback; server guards remain mandatory.

## 8. Headquarters, retry, and placement

The first version should use the current single-place layout. `PivotTo` is same-place character movement; it is not an inter-place `TeleportService` flow. `Config.Heist.SpawnPosition` and `NewRoom` are presently unused position definitions, not implemented room routing.

Beginning at headquarters must coordinate session creation, challenge readiness, and placement. A successful registry insertion alone must not be presented as arrival in a heist. Return from results clears the old run and places the character at headquarters; retry clears the old run and immediately starts a new session without requiring a headquarters visit. Cashout/failure themselves show results, with both choices available after settlement.

An explicit return while a run is active is abandonment and forfeits unbanked cash. Make that consequence clear in the interaction label/UI. This does not cash out an unfinished room. Keep the decision to return distinct from the cashout operation.

Centralize destination positions in config instead of repeating coordinates in world creation and movement. `BaseService` can remain the headquarters placement adapter; add the smallest corresponding heist placement helper when needed. Both should return a clear outcome and verify the character is still the player's current character after waits.

## 9. Challenges and room progression

No challenge or room-generation module exists today. `CurrentRoom` is an index, not a physical room controller, and `Config.Heist.NewRoom` does not create a room.

Start with one server-owned skill challenge and fixed, testable reward/difficulty rules. A small interface is enough:

```luau
-- Proposed contract sketch; not implemented APIs.
-- Service supplies server-owned context and a callback.
local handle = Challenge.Start(context, reportOutcome)
-- context: player, runId, attemptId, roomIndex, difficulty, owned room location
-- reportOutcome: Success or Failure plus a bounded reason; never a payout
handle:Destroy() -- cancels callbacks and releases owned resources; repeat-safe
```

The service chooses a reward and applies it atomically with accepted success. A callback must match the current run/attempt and active-room status. Cleanup plus identity checks protects against already queued callbacks. Add an explicit cancellation token only if asynchronous challenge work needs one.

Increasing room index feeds a simple server-side difficulty function with sensible bounds. Later, challenge variety can be a table of concrete challenge modules implementing the same contract; do not build a plugin discovery system now.

Each player's run is independent initially. Shared platforms do not imply shared challenge state or cooperative payouts. For multiplayer tests, either isolate each player's physical challenge area or prove that shared geometry cannot affect another player's outcome. A single global mutable room is not a valid per-player session implementation. Party ownership, shared lives, and group settlement are separate future decisions.

## 10. Concurrency and exceptional paths

| Case | Proposed required behavior |
| --- | --- |
| Duplicate entrance/continue/retry input | First valid transition wins; later input returns the current result or rejection. No extra room, run, or reward. |
| Cashout races with continue/failure | Recheck status while holding the per-player operation claim. Only the accepted transition takes effect; never pay and then continue that same run. |
| Callback arrives after failure/retry | Run/attempt mismatch rejects it without state changes. |
| Two players act simultaneously | Separate registry entries, balances, challenge handles, and locks. One player's cleanup cannot affect the other. |
| Player disconnects during an active run | Forfeit unbanked cash, invalidate callbacks, release resources and entry. No automatic cashout. |
| Disconnect during completed payout save | Preserve ownership of the pending settlement until resolved or safely handed off. Retry the same receipt; do not run failure over a completed payout or discard pending work with the character. |
| Death/reset during active room | End once as failure and clear cash; respawn into the results/recovery flow. Bind only the current character's death event. |
| Death/reset at a decision point | Proposed rule: treat as abandonment and forfeit unbanked cash, closing a reset escape route. Terminal results remain terminal. |
| Character missing/replaced during movement | No success claim for failed placement. Use bounded readiness waits, check character identity, and recover to a valid results/headquarters destination. |
| Player/character already exists at startup | Bootstrap initializes existing players/current characters as well as future events, without duplicate connections. |
| Server shutdown | Stop admitting starts, clean challenges, and make bounded attempts to finish pending durable settlements when persistence exists. In-memory runs/balances have no crash survival guarantee. |
| Same-place movement failure | Preserve consistent flow state, show/retry placement recovery; never award cash because movement succeeded or erase a settled payout because it failed. |
| Future inter-place teleport failure | Keep player at a recoverable source state and allow retry; do not create two active runs. Add a handoff identity and destination validation only if multiple places are introduced. Never trust client-supplied teleport data as a balance. |

Current bootstrap sends every newly added character to base without consulting a session. Replace this with service-owned routing when death/reset behavior is added, otherwise respawn can leave an active session stranded at headquarters.

## 11. Repository and Rojo layout

The inspected [`default.project.json`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/default.project.json) maps:

```text
repository                         Roblox DataModel
src/shared/                        ReplicatedStorage/Shared
  Config.luau                        Config
src/server/                        ServerScriptService/Server
  main.server.luau                    main (server Script)
src/services/                      ServerScriptService/Services
  BaseService.luau                    BaseService
  HeistService.luau                   HeistService
src/systems/                       ServerScriptService/Systems
  ExitSystem.luau                     ExitSystem
  HeistSession.luau                   HeistSession
src/client/                        StarterPlayer/StarterPlayerScripts/Client
  main.client.luau                    main (LocalScript)
tests/                             not mapped
docs/                              not mapped; proposed documentation directory
```

World platforms/prompts are created at runtime by `main.server.luau`, not represented in this project tree. Keep server-only services, rules, and challenges under server-mapped directories. Put only intentionally public definitions/assets in shared storage. Add a `src/systems/challenges/` folder when the first challenge warrants it; no broad folder reorganization is needed.

Both [`aftman.toml`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/aftman.toml) and [`rokit.toml`](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/rokit.toml) pin Rojo `7.7.1`. Pick one tool-manager workflow for local instructions; this document does not require migrating either. The [README](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/README.md) documents `rojo build -o "one_more_room.rbxlx"` and `rojo serve`. The project name, README title, client log, and ignored place filename retain `one_more_room` naming; that is configuration debt, not a separate game architecture.

The [editor settings](https://github.com/patricksullivan123411223344/one_more_heist/blob/d7bdb082fb60e48e0b03bc6845dcbcacd6db1daf/.vscode/settings.json) enable Roblox Luau LSP mode, generated sourcemaps from `default.project.json`, and Studio plugin integration. No automated type-check, test runner, or CI command is configured in the inspected tree. Do not imply that building or syncing the project runs `tests/`.

## 12. Recommended verification layers

Use the smallest repeatable check that verifies the slice. Choose and document one way to execute real module tests before describing them as automated; no framework is mandated here.

1. **Pure session tests:** require the actual module. Verify defaults, full success/continue/cashout sequence, failure, abandonment, invalid transitions, finite integer rewards, duplicate room results, terminal immutability, cash clearing, and independent sessions. Include regression tests for the `Status`/`HeistStatus` defect. The existing addition smoke test is not this layer.
2. **Service tests with small fakes:** inject placement, challenge outcome, and balance operations as needed. Verify registry uniqueness, fresh retry identity, stale callbacks, disposal, one credit under duplicate requests, and rollback/recovery when setup fails. Use a controllable yielding fake for the cashout/continue race rather than only sequential happy paths.
3. **Roblox Studio integration:** build/sync, start at headquarters, begin and arrive, succeed once, continue, fail, retry at room 1 with zero cash, cash out, and choose return. Exercise reset, missing character, rapid inputs, and two-player isolation. Confirm the temporary banked balance survives a retry in the same server and failure does not subtract from it.
4. **Persistence tests when added:** failed loads, duplicate receipts, uncertain write outcomes, reconnect, overlapping server ownership, and shutdown during settlement. Verify durable balance and receipt agree after reloading.
5. **Client/transport checks when added:** malformed requests, stale IDs, spam, late snapshots, UI reopening, and actions disabled until authoritative readiness. A hidden button is not a validation test.

Review Luau diagnostics and verify the Rojo build for relevant code/config changes. Record which checks actually ran and which still require Studio. This architecture review itself did not execute the game or its tests.

## 13. Phased implementation: one testable slice per task

These phases are a dependency order, not a request to implement everything together. Each numbered slice should be a separate bounded task with its own acceptance evidence.

| Slice | Change | Independently checkable result |
| --- | --- | --- |
| 1 | Repair canonical statuses and terminal guards in `HeistSession`; define immutable terminal summaries and clear cash correctly. | Actual session tests prove terminal operations cannot repeat or reopen a run. |
| 2 | Make room success plus reward one validated operation; add run/attempt identity checks at the service boundary. | One accepted room outcome awards once; old/duplicate outcomes do nothing. |
| 3 | Add service-owned lifecycle commands and registry cleanup using fake challenge/placement operations. | Start uniqueness, fresh retry, abandonment, and idempotent disposal work without a UI. |
| 4 | Wire headquarters entry and heist placement through those commands. Centralize positions. | Studio entrance starts and places one run; setup failure recovers cleanly. |
| 5 | Add one simple server-validated challenge and decision-point continue behavior. | Player completes a room, receives cash once, and starts a harder next room. |
| 6 | Add temporary server balance and one settlement path; wire cashout/failure results with retry/return prompts. | Complete playable loop; cashout pays once, failure loses only unbanked cash, retry resets run state. |
| 7 | Handle player removal, death/reset, existing characters, delayed callbacks, and two-player resource isolation. | Exceptional paths leave no stranded session or cross-player mutation. |
| 8 | Add minimal HUD/results UI and validated remotes if prompts are no longer sufficient. | UI follows authoritative snapshots; forged/repeated requests cannot alter payouts. |
| 9 | Add persistent player data and durable settlement receipts. | Reload and uncertain-write tests protect banked cash; temporary balance is retired deliberately. |
| 10 | Add challenge variants, upgrades, then empire progression in separate slices. | Each feature uses existing lifecycle/data boundaries and adds focused tests. |

Do not move on from an incomplete slice merely because its happy path prints successfully. Keep code changes local, name the behavior being added, and list a short acceptance procedure. One agent can implement, verify, and hand back each slice before starting the next. Parallel agents are unnecessary for this sequence.

## 14. Decisions deliberately deferred

Exact room rewards, difficulty curves, challenge selection, UI layout, and content counts belong in the later MVP specification. Persistence library choice, receipt retention, crash recovery guarantees, and upgrade pricing belong to their respective implementation slices. Multiplayer parties, reserved servers, multi-place travel, procedural room streaming, analytics infrastructure, and a generalized progression engine are not prerequisites for the first loop.

The stable architectural commitments are server authority, one owned session per player, irreversible run outcomes, one settlement per run, fresh sessions on retry, explicit return to headquarters, and a strict separation between durable progression and disposable run state.

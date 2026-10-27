# ONE MORE HEIST
## Game Vision & Product Overview

**Project:** One More Heist  
**Platform:** Roblox  
**Development Language:** Luau  
**Genre:** Heist Simulator / Risk–Reward / Progression  
**Status:** Early Development — MVP  
**Document Purpose:** Define the game's core concept, initial MVP, and intended official launch experience.

---

## 1. Game Overview

**One More Heist** is a Roblox heist simulator built around a simple premise:

*How much are you willing to risk for one more reward?*

Players begin at their headquarters and enter heists consisting of progressively more challenging rooms or encounters. Successfully completing challenges earns cash, but rewards remain at risk until the player chooses to cash out.

After each successful stage, players face a decision: secure their current earnings or continue deeper into the heist for increasingly valuable rewards.

Pushing too far can result in failure and the loss of everything accumulated during that attempt.

The game combines short, repeatable heist sessions with a longer-term progression system in which players use their secured earnings to expand their criminal operation, improve their capabilities, and pursue increasingly ambitious heists.

The ultimate goal is to create a satisfying loop of **risk, reward, progression, and replayability**.

## 2. Core Gameplay Philosophy

The game's fundamental design is built around four pillars.

### Risk Versus Reward

Every successful encounter should create a meaningful decision.

Players can walk away with guaranteed earnings or continue for potentially greater rewards at the risk of losing their unbanked cash.

The further a player progresses into a heist, the more consequential that decision becomes.

### Skill-Based Gameplay

Heists should involve active participation, not simply waiting for a reward timer.

Challenges may include movement, timing, navigation, escaping security systems, and other mechanics requiring skill or decision-making.

Player improvement should noticeably increase their ability to complete increasingly difficult heists.

### Short, Repeatable Sessions

Individual heists should be relatively quick to enter and replay.

Players should be able to complete a short run, collect rewards, and immediately attempt another without unnecessary downtime.

A failed heist should create motivation to retry rather than make the game feel excessively punishing.

### Long-Term Progression

Cash earned during heists should serve a greater purpose.

Players will invest their money into improving their headquarters, equipment, and criminal operation, unlocking greater capabilities and new objectives over time.

Short-term gameplay should consistently contribute to a broader sense of advancement.

---

## 3. The Core Gameplay Loop

The core experience follows this sequence:

1. **Headquarters:** The player begins at their base, where they can eventually manage upgrades, equipment, and progression.
2. **Enter Heist:** The player initiates a new heist run.
3. **Complete Challenge:** The player attempts a room or encounter involving some combination of skill and risk.
4. **Earn Rewards:** Successful completion increases the player's unbanked cash.
5. **Make a Decision:** The player can secure their earnings or continue to the next, more difficult stage.
6. **Resolve the Run:** Cashing out secures the earnings. Failing forfeits the unbanked rewards for that run.
7. **Retry or Return:** The player can immediately start another attempt or return to headquarters.
8. **Progress:** Secured cash contributes to the player's overall progression and eventual upgrades.

The central experience should remain enjoyable across repeated sessions, even as additional systems are introduced.

## 4. Minimum Viable Product (MVP)

The MVP exists to validate the game's most important mechanic: **whether completing challenges, accumulating rewards, and deciding when to cash out is an enjoyable, repeatable experience.**

The MVP is not intended to represent the full launch product.

### MVP Requirements

**Player Entry and Navigation**
- Players spawn at a basic headquarters.
- Players can initiate a heist through an interaction.
- The game moves players between the headquarters and heist environment.

**Heist Session Management**
- Each heist attempt maintains an independent session.
- Sessions track current room, unbanked cash, and run status.
- The system correctly handles starting, continuing, completing, and failing runs.

**Basic Gameplay**
- Players encounter at least one functioning, repeatable challenge type.
- Completing challenges awards unbanked cash.
- Players can choose to continue into another stage or cash out.
- Failure results in the loss of unbanked rewards.

**Run Completion and Replayability**
- Cashing out ends the current run and secures earned rewards.
- Failure ends the current run without awarding its unbanked cash.
- Players can immediately retry with a fresh session.
- Players can instead return to headquarters.
- Previously secured rewards remain unaffected by subsequent failed attempts.

**Basic Player Feedback**
- Players can see their current unbanked earnings.
- Players receive feedback for successful and failed runs.
- Players understand when they can continue, cash out, retry, or return home.

### MVP Success Criteria

The MVP is considered functionally complete when a player can repeatedly execute the entire gameplay loop without a server restart, corrupted session state, unintended payouts, or forced interruptions.

The initial MVP may use simple environments, placeholder challenges, and temporary interfaces. Sophisticated graphics, extensive content, and a fully developed progression economy are not required to validate the core mechanics.

---

## 5. Official Launch Vision

The official release of One More Heist should feel like a complete, replayable Roblox experience rather than a collection of individual obstacle courses.

The intended launch product expands the MVP into three connected gameplay layers.

### A. The Heist Experience

Heists will become the primary source of engaging moment-to-moment gameplay.

The intended experience includes:

- Multiple challenges requiring different skills.
- Increasing difficulty and rewards as players progress.
- Varied room layouts, hazards, and security obstacles.
- Meaningful decisions about continuing or securing earnings.
- Sufficient variation to keep repeat attempts interesting.
- Clear feedback about progression, difficulty, risk, and potential rewards.

Players should be encouraged to improve their performance and experiment with how far they can push each run.

### B. Headquarters and Criminal Empire Progression

The headquarters will evolve from a basic spawn area into a central progression hub.

Players will use their heist earnings to build and expand their criminal operation.

Planned progression directions include:

- Headquarters upgrades and visual improvements.
- Equipment or tools that affect gameplay.
- New heist locations or higher-difficulty opportunities.
- Unlockable progression milestones.
- Increasingly ambitious objectives and investments.

The headquarters should provide a visible representation of the player's accomplishments.

**The long-term fantasy is not simply robbing the same building repeatedly; it is building a criminal empire through successful heists.**

### C. The Player Economy

Successful heists generate the resources used for progression.

This economy should reward player participation, skill improvement, and calculated risk-taking.

The distinction between **unbanked run earnings** and **secured player wealth** is fundamental to the design.

Unbanked earnings are exposed to heist failure. Secured wealth belongs to the player's broader progression and should not be lost when a later run fails.

The launch economy will need deliberate balancing so rewards, upgrades, difficulty, and progression remain meaningful over time.

---

## 6. Retention and Replayability

The game should create multiple reasons for players to return.

**Immediate motivation:** Can I complete one more room and secure a larger payout?

**Session motivation:** Can I beat my previous run, earn enough for my next upgrade, or complete a more difficult heist?

**Long-term motivation:** Can I expand my headquarters, unlock better opportunities, and build a more impressive criminal operation?

Replayability should emerge primarily from engaging challenges, variable outcomes, meaningful choices, and progression—not artificial waiting periods.

Future retention features may include leaderboards, additional challenges, special events, or new heist environments. These are potential extensions rather than guaranteed MVP requirements.

## 7. Monetization Strategy

One More Heist is intended to become a commercially viable Roblox game.

Monetization should be designed around an engaging free-to-play experience rather than used to compensate for weak gameplay.

Potential monetization opportunities include cosmetic customization, headquarters aesthetics, and carefully balanced optional convenience features.

The exact monetization model remains undecided and should be evaluated after the core gameplay loop has been tested.

The design should avoid making payment a prerequisite for enjoyable participation or undermining the skill-based risk/reward mechanics.

The primary commercial objective is to create a game that players voluntarily return to, then establish monetization that supports sustainable development.

---

## 8. Development Priorities and Scope

Development will proceed in stages.

**Phase 1 — Functional Core:** Build and test the complete session lifecycle, basic challenge resolution, cash-out, failure, retry, and headquarters return.

**Phase 2 — Playable MVP:** Add clearer interfaces, reliable reward tracking, initial game feel, and enough challenge functionality to test whether the experience is genuinely enjoyable.

**Phase 3 — Progression and Content:** Introduce a persistent player economy, headquarters improvements, expanded challenge variety, and progression systems.

**Phase 4 — Launch Preparation:** Polish the experience, balance difficulty and progression, test with players, address reliability issues, and implement an appropriate monetization strategy.

**Phase 5 — Official Release:** Launch a cohesive heist simulator with engaging repeatable gameplay, meaningful progression, functional economic systems, and a clear foundation for future content.

Features should be prioritized according to their contribution to the core gameplay experience.

Additional systems should not be implemented merely because they are technically interesting.

---

## 9. Product Boundaries

For the initial MVP:

- Do not prioritize elaborate environments over functioning gameplay.
- Do not build an extensive upgrade economy before verifying the heist loop.
- Do not require numerous challenge types to demonstrate the concept.
- Do not introduce unnecessary complexity into session management.
- Do not confuse an individual heist run with the player's persistent progression.
- Do not make successful or failed runs automatically require a return to headquarters.

For the official release, the emphasis shifts toward a more complete experience with richer content, lasting progression, visual quality, player retention, and commercial viability.

## 10. Guiding Product Vision

**One More Heist should make players want to attempt just one more run.**

The game's appeal comes from the combination of immediate challenge, growing rewards, meaningful risk, and the satisfaction of building something larger over time.

The MVP proves that the fundamental risk/reward mechanic works.

The official launch transforms that mechanic into a complete heist simulator with an expanding criminal empire, varied gameplay, and long-term progression.

Every major feature should reinforce at least one of those goals.

---

*This document defines intended product direction, not finalized technical architecture. Detailed systems, module responsibilities, data structures, and implementation decisions belong in separate architecture documentation. Features described as planned or potential remain subject to testing and scope decisions.*
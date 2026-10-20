# Philosophy

BlackNode follows Stoicism. That sounds grand for a desktop, so here is the practical version: spend effort on what you control, remove what you do not need, and assume something will fail.

The three sources used here are Epictetus, Marcus Aurelius, and Seneca. Each answers a different question. Epictetus asks what belongs to you. Marcus asks whether a thing earns its place. Seneca asks what it costs in time. The repository is the result of those three questions applied to a session.

## Some things are up to us

> "Some things are in our control and others not."
>
> Epictetus, *Enchiridion*, 1

A desktop is mostly outside your control: hardware, drivers, the kernel, and the behavior of other people's applications. BlackNode controls its own surface. The keybinds, the layout, the palette, the startup order, and the menus are plain files linked into your home. There is no central daemon and no remote service deciding how the session behaves.

That boundary is also why the project states its limits instead of hiding them. It assumes Arch Linux, Hyprland, a single-user Wayland session, and a `us,es` keyboard. It does not promise to work on another distribution, and it does not pretend to harden your machine. A tool that claims to control everything usually controls nothing well.

## Ask whether it is necessary

> "Most of what we say and do is not essential. If you can eliminate it, you'll have more time and more tranquillity. Ask yourself at every moment, 'Is this necessary?'"
>
> Marcus Aurelius, *Meditations*, 4.24

The repository has one palette source, one Waybar layout, one control menu, and one keybind grammar. There is no theme store and no color picker for every application. A setting survives only if someone can explain what it does and what breaks without it.

Every option is a decision someone has to make later. Every extra path through the configuration is another thing to keep working after an update. Removing an option is part of the design, not a missing feature.

## Time is the material

> "It is not that we have a short time to live, but that we waste a lot of it."
>
> Seneca, *On the Shortness of Life*

A desktop that asks for a weekend of tuning every month is not free, even when the code is. The installer makes the package and linking decisions once. The idle sequence handles brightness, locking, display power, and suspend without a prompt. The menu collects the daily actions that would otherwise become a search through settings.

After setup, the session should cost you almost no attention.

## Prepare for failure

The Stoics practiced *premeditatio malorum*: imagine the failure before it arrives, then decide how you will respond. BlackNode applies that to installation and maintenance.

The installer copies existing files to `~/.blacknode-backup-YYYYmmdd-HHMMSS` before replacing them, writes every command to `~/.blacknode-install.log`, and offers retry, skip, or abort when a step fails. The [loose ends](looseEnds.md) page lists the gaps instead of leaving them for a bug report. Reversibility is part of the design.

## Beauty is a preferred indifferent

The Stoics called health, comfort, and beauty *preferred indifferents*. They are worth choosing, but they are not worth sacrificing judgment or function for. Visual coherence belongs in that category. It improves the day; it is not the purpose of the day.

The palette starts from one image so the bar, terminal, notifications, lock screen, and editor agree with each other. Some pieces keep their own colors because wiring them into the pipeline takes more maintenance than the mismatch is worth. The [aesthetics](aesthetics.md) page explains which ones join the pipeline and which ones do not.

BlackNode supports dark and light palettes. The screenshots show the author's dark preference; the repository does not require it. Coherence is the identity.

## The measure is attention

A desktop succeeds when it stops asking for attention. One palette removes the work of matching applications by hand. One keyboard grammar removes the work of relearning movement for each layout. One menu removes the work of hunting through settings for routine actions.

A tool can be pleasant, warm, and detailed. The test is whether the detail costs you time or attention every time you use it.

## What this rules out

- A theme store with dozens of presets to maintain.
- Per-application color pickers that do not share a source.
- Options kept for users who do not exist yet.
- Claims of universal compatibility.
- A changelog that hides the gaps.

## Where Stoicism can mislead

A desktop can be beautiful, and the Stoics did not ask for ugly tools. The risk is the opposite: using philosophy to excuse rough edges or to make a lack of polish sound deliberate.

A detail earns its place by what it saves in time and attention.

## How to judge a change

If you add something, ask three questions:

1. Does it remove a step, or only add an option?
2. Does it survive a clean clone with no generated files?
3. Can you explain it without a diagram?

All three answers should be yes.

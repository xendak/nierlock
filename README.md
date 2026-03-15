# YoRHa UI Lockscreen

## Disclaimers

- **Personal Project Notice**: I wasn't originally planning on posting this, so
  the code is "tailored to my machines." It might not be fully functional for
  every setup out of the box. I'll try to help if you run into issues, but
  please don't count on me for active support. It's mostly a "share and enjoy"
  release.
- **AI Disclosure**: This documentation, and the shaders was generated with AI
  assistance.
- **Inspiration:**
  [Darkal_44 on r/unixporn](https://www.reddit.com/r/unixporn/comments/1rl9owy/oc_a_nier_automata_inspired_lockscreen_theme_for/).
- **SystemStats:** The `SystemStats.qml` implementation is from the
  [Caelestia Shell](https://github.com/caelestia-dots/shell) project by
  **soramanew**.
- **YorHa Symbol:** Taken from: [gigsol on r/nier](https://www.reddit.com/r/nier/comments/1lfkpnl/i_was_unable_to_find_yorha_logo_as_svg_so_i/)  
- **Assets Not Included:** For legal and copyright reasons, the **original game
  sounds** and the **FOT Rodin Pro** fonts are **not** provided in this
  repository. You must provide your own assets in the `./sounds/` directory.
  There's a table telling which ones i used and their origin

---

## Preview

[![Watch the video](https://raw.githubusercontent.com/xendak/nierlock/main/thumbnail.png)](https://github.com/user-attachments/assets/bc7d5454-7114-4f11-ba8a-6f57aabf3e77)

## Requirements

- **Quickshell:** The shell framework.
- **Pipewire:** Used via `pw-play` for audio.
- **Procps:** Used in `uptime -p`

## Features

- **Dynamic System Stats:** Real-time monitoring of CPU/GPU usage and
  temperatures via `/proc` and `sensors`.
- **YoRHa Aesthetics:** based on
  [UI Design in NieR:Automata](https://www.platinumgames.com/official-blog/article/9624)
- **Mission Status:** TODO list parser that reads(really simple for now) from
  your local Markdown notes and calculates "Synchronization" percentage.
- **Immersive Audio:** Positional SFX for navigation and a looping background
  music (BGM) engine.
- **Shaders:** Post-processing effects on authentication failure and success.
- **Config:** I tried to abstract away most of the config into its own file
  `Config.qml`, so try checking there beforehand

## Sound

I don't think im allowed to share the actual game sounds, so you can either get
them, or change them, here is a table of what i used.

| Event          | File               | Game        | Description                     |
| -------------- | ------------------ | ----------- | ------------------------------- |
| **BGM**        | `Significance.mp3` | TitleScreen | The primary background loop.    |
| **Input**      | `input.ogg`        | core_16.ogg | Played on keystrokes/typing.    |
| **Navigation** | `cursor.ogg`       | core_21.ogg | Menu selection changes.         |
| **Confirm**    | `confirm.ogg`      | core_39.ogg | Selection/Action confirmation.  |
| **Error**      | `error.ogg`        | core_64.ogg | Auth failure or system warning. |
| **Power**      | `poweroff.ogg`     | core_55.ogg | System shutdown sequence.       |
| **Reboot**     | `reboot.ogg`       | core_72.ogg | System reboot sequence.         |

The sound system is based on the `.ogg`, and the path `./sounds/`, so if you
want to change how it works, check `YorhaSounds.qml` and `Config.qml`

## Shaders

The visual glitches use GLSL fragment shaders.

> **Note:** The current shaders were generated/modified with the assistance of
> Claude AI, based on logic found in the following community resources. I plan
> to refine or replace these with custom implementations in future versions.

- [Shadertoy: MtXBDs](https://www.shadertoy.com/view/MtXBDs)
- [Shadertoy: wf2SDV](https://www.shadertoy.com/view/wf2SDV)

There might be a few more shadertoy links I used as reference, I don't remember.
sorry.

---

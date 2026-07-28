# 🚀 EndeavourOS-Shell

> A unified Lua-driven theme and configuration generator for **Foot terminal** and a modern **Bash prompt** on EndeavourOS.

---

## 📖 About The Project

**EndeavourOS-Shell** is a full visual and functional customisation setup for your terminal environment. All themes, colors, icons, and layout options are managed from a single "source of truth" (`lua/theme.lua`). A custom Lua script automatically builds and deploys configurations for both the Foot terminal (`foot.ini`) and a dynamic multi-line Bash prompt (`modern-prompt.sh`).

---

## ✨ Features

- 🎨 **Single Source of Truth (`lua/theme.lua`)**: Configure colors, fonts, and status icons in one single file.
- 💻 **Modern Multi-line Bash Prompt**:
  - Displays current working directory (`📁`)
  - Git status integration (branch name + dirty repository indicator)
  - Previous command exit code indicator (`⛓️‍💥` / `❌`)
  - Clean two-line layout with a dedicated prompt arrow
- ⚡ **Foot Terminal & KDE KWin Integration**:
  - Full TrueColor support
  - Automated deployment of KWin rules for window border radius and opacity effects in KDE Plasma

---

## 📦 Requirements

Before installing, make sure you have the following dependencies installed:

- **Shell:** `bash`
- **Interpreter:** `lua` (version 5.4 or higher)
- **Terminal:** `foot`
- **Font:** `JetBrainsMono Nerd Font` (required for proper icon rendering)

---

## 🚀 Quick Start

1. **Clone the repository to your system:**
   ```bash
   git clone https://github.com/Bloby22/EndeavourOS-Shell.git
   cd EndeavourOS-Shell

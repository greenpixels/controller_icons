# 🎮 Godot 4.3 Template – Opinionated Project Structure & Utilities  

This is an **opinionated Godot 4.3 template** that provides a structured folder setup and commonly used utilities to speed up development. It includes helpful tools like a **BBCodeHelper, Tooltip UI component, WeightedList class, TweenHelper**, and more—things I frequently use in every project.

---

## 📁 Folder Structure  

This template enforces an organized folder structure for better scalability and maintainability:

```
/project_root/
  ├── object_scenes/    # Scenes that represent game instances (player, enemies, pickups)
  ├── localization/     # CSV files for language translations
  ├── resources/        # Resource files like upgrades, abilities, ...
  ├── utils/            # Global scripts and utilities (tween_helper, weighted_list, ... )
  ├── ui/               # UI elements and reusable components
  ├── addons/           # Third-party or custom plugins/addons
```

Each folder contains specific guidelines to maintain consistency (see subfolder **README.md** files).

---

## ⚡ Features & Utilities  

### 📝 **BBCodeHelper**  
A utility for handling BBCode-rich text, including dynamic replacements and formatting helpers.

### 💬 **Tooltip UI Component**  
A flexible tooltip system for displaying contextual information on hover or interaction.

### 🎲 **WeightedList**  
A helper class for handling **random weighted selection** from an array. Useful for loot tables, enemy spawning, and probability-based systems.

### 🎭 **TweenHelper**  
A convenience wrapper for **Godot's Tween system**, making smooth transitions, animations, and UI effects easier to manage.

---

## 🚀 Getting Started  

1. Clone this repository:  
   ```bash
   git clone https://github.com/your-username/godot-4.3-template.git
   ```
2. Open the project in **Godot 4.3**.
3. Modify the folder structure and utilities to fit your needs.
4. Enjoy an organized and efficient development experience! 🎉  

---

## 🛠️ Contributing  

Feel free to suggest improvements, add new utilities, or refine the existing template via pull requests.  

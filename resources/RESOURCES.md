## 📂 Resources Directory (`/resources`)

This directory is used to store **Godot Resource files** such as `.tres`, `.res`, and scene-based resources (`.tscn`). Proper organization ensures scalability and easy access to game assets.

### 📌 **Folder Structure**
Use a structured folder pattern for different resource categories. Example with **upgrades**:

```
/resources/
  ├── upgrades/
  │   ├── _all/           # Contains all individual upgrade scenes/resources
  │   │   ├── double_jump.tscn
  │   │   ├── wall_jump.tscn
  │   │   ├── speed_boost.tscn
  │   ├── upgrade.gd      # Script handling upgrade logic
```

### 📝 **Organizing Resources**
- **Store resource instances in subfolders** based on their category.
- **Use `_all/` as a dedicated folder** to hold individual resource scenes or `.tres` files.
- **Keep resource scripts next to relevant assets** (e.g., `upgrade.gd` for handling all upgrades).

### 🚀 **Best Practices**
✔️ Use `.tres` files for **configurable data-driven resources** (e.g., stats, upgrades, abilities).  
✔️ If a resource is generic (e.g., `upgrade.gd`), keep it at the category root level.  
✔️ Separate **game logic scripts** from **resource data** to maintain clean architecture.  

For more on Godot's resource system, check the [official documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). 🚀  
## Object Scenes (`/object_scenes`)

This directory is used to store **scene instances** that represent in-game objects. Proper organization helps maintain a structured and scalable project.

### 📌 **Organizing Object Scenes**
- Store each scene in a structured hierarchy based on its type and category.  
  Example:
  ```
  /object_scenes/
	├── player/
	│   ├── player.tscn
	│   ├── player.gd
	├── pickups/
	│   ├── gold_coin/
	│   │   ├── gold_coin.tscn
	│   │   ├── gold_coin.gd
	│   ├── health_potion/
	│   │   ├── health_potion.tscn
	│   │   ├── health_potion.gd
  ```
- **Scenes should be named based on their function** (e.g., `player.tscn`, `gold_coin.tscn`).

### 📝 **Scripting Guidelines**
- **Place scripts next to their corresponding scene** unless they are generic and reusable.
- If a script is scene-specific, name it accordingly:
  - ✅ `gold_coin.tscn` → `gold_coin.gd`
  - ✅ `health_potion.tscn` → `health_potion.gd`

### 🚀 **Best Practices**
✔️ Keep scene files lightweight—use **composition over inheritance** where possible.  
✔️ Organize assets (textures, sounds) in dedicated folders (e.g `object_scenes/pickups/gold_coin/assets/`).  

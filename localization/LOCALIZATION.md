## Localization Directory (`/localization`)

This directory is used for storing localization `.csv` files for **Godot 4.3**. Godot’s built-in localization system supports CSV-based translations, making it easy to manage and expand language support.

### 📌 **How to Structure Localization Files**
To maintain organization and improve readability, it’s recommended to categorize localization files based on their usage. Suggested file naming conventions:
- `localized_ui.csv` – for UI text
- `localized_dialogue.csv` – for dialogues
- `localized_hero_abilities.csv` – for ability names/descriptions
- `localized_upgrades.csv` – for upgrade descriptions

### ⚙️ **How to Use in Godot 4.3**
1. Place your `.csv` files in this folder.
2. Open **Project Settings** → `Localization` → `Translations`.
3. Click **"Add Translation"** and select the `.csv` files.
4. Ensure your CSV files are formatted correctly:
   ```
   key, en, es, fr
   greeting, "Hello", "Hola", "Bonjour"
   farewell, "Goodbye", "Adiós", "Au revoir"
   ```
5. Use `tr("key")` in GDScript to fetch translations dynamically.

For more details, refer to the [Godot 4.3 documentation](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_translations.html).
# Roblox UI Builder

A browser-based visual editor for designing Roblox interfaces, with a companion Roblox Studio plugin that creates real, editable GUI instances.

## Current features

- Modern dark editor layout with component palette, canvas, hierarchy and properties inspector.
- Add Frames, TextButtons, TextLabels, ImageLabels, ImageButtons and ScrollingFrames.
- Edit names, text, pixel position and size, colours, font, text size, corner radius, stroke and transparency.
- Drag components around the preview.
- Desktop/mobile preview sizing.
- Undo/redo, duplicate, delete.
- Save projects in browser local storage.
- Export/import the project as JSON.
- Companion Studio plugin creates actual Instances under StarterGui, including UICorner and UIStroke.

## Run the website

Open index.html in a modern browser. No build step or dependencies are required.

## Create an actual .rbxm model

The browser exports a project JSON file. Roblox Studio's own serialization is used for the final model so the result contains actual editable instances, not a script that constructs the interface at runtime.

1. Open Roblox Studio.
2. Install studio-plugin/RobloxUIBuilder.plugin.lua as a local plugin, then enable it.
3. Open the Roblox UI Builder — Import dock widget.
4. Paste the contents of the JSON file exported by the website.
5. Click Build GUI. The plugin creates a ScreenGui and the corresponding UI instances in StarterGui.
6. Select RobloxUIBuilderGui in Explorer and use File → Save to File… to save the selected model as .rbxm.

The plugin source is a Studio-side import tool; the saved .rbxm contains the GUI objects themselves. It does not need a runtime LocalScript to construct the interface.

## First-version limitations

- Layout uses pixel offsets relative to a 760×480 design surface; responsive scale/anchor editing is not implemented yet.
- Components are currently siblings under the ScreenGui. Nested parenting, constraints, gradients, asset upload, and full Roblox property coverage are planned.
- The Image asset field accepts an asset ID or rbxassetid:// URI. The website preview does not fetch Roblox assets.
- The final .rbxm save is performed by Roblox Studio. A browser-only page cannot invoke Studio's private binary model serializer directly.

## Project structure

- index.html — complete browser editor.
- studio-plugin/RobloxUIBuilder.plugin.lua — companion Studio import plugin.

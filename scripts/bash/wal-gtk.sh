#!/usr/bin/env bash

source ~/.cache/wal/colors.sh

mkdir -p ~/.config/gtk-3.0

cat > ~/.config/gtk-3.0/gtk.css << GTKEOF
* {
    background-color: ${color0};
    color: ${color7};
}

window, .background {
    background-color: ${color0};
    color: ${color7};
}

button {
    background-color: ${color0};
    color: ${color7};
    border: 1px solid ${color0};
    padding: 5px 10px;
    min-height: 24px;
}

button:hover {
    background-color: ${color1};
    color: ${color7};
}

button:active, button:checked {
    background-color: ${color1};
    color: ${color7};
}

entry {
    background-color: ${color0};
    color: ${color7};
    border: 1px solid ${color0};
    padding: 5px;
}

entry:focus {
    border-color: ${color1};
}

entry selection {
    background-color: ${color1};
    color: ${color7};
}

.view, iconview, treeview {
    background-color: ${color0};
    color: ${color7};
}

.view:selected, iconview:selected, treeview:selected {
    background-color: ${color1};
    color: ${color7};
}

treeview.view {
    background-color: ${color0};
}

treeview.view:selected {
    background-color: ${color1};
}

treeview.view header button {
    background-color: ${color0};
    color: ${color7};
    border: 1px solid ${color0};
}

menubar {
    background-color: ${color0};
    color: ${color7};
}

menubar > menuitem {
    padding: 5px 8px;
    background-color: ${color0};
}

menubar > menuitem:hover {
    background-color: ${color1};
}

menu {
    background-color: ${color0};
    border: 1px solid ${color0};
}

menuitem {
    padding: 5px;
}

menuitem:hover {
    background-color: ${color1};
}

headerbar {
    background-color: ${color0};
    color: ${color7};
    border: none;
}

headerbar button {
    background-color: ${color0};
    border: 1px solid ${color0};
}

headerbar button:hover {
    background-color: ${color1};
}

scrollbar {
    background-color: ${color0};
}

scrollbar slider {
    background-color: ${color1};
    border: none;
    min-width: 12px;
    min-height: 12px;
}

scrollbar slider:hover {
    background-color: ${color1};
    opacity: 0.8;
}

notebook {
    background-color: ${color0};
}

notebook > header {
    background-color: ${color0};
    border: none;
}

notebook > header > tabs > tab {
    background-color: ${color0};
    color: ${color7};
    border: 1px solid ${color0};
    padding: 5px 15px;
}

notebook > header > tabs > tab:checked {
    background-color: ${color1};
}

combobox button {
    background-color: ${color0};
    border: 1px solid ${color0};
}

popover {
    background-color: ${color0};
    border: 1px solid ${color0};
}

textview, textview text {
    background-color: ${color0};
    color: ${color7};
}

textview selection {
    background-color: ${color1};
}
GTKEOF

echo "GTK theme updated with pywal colors"

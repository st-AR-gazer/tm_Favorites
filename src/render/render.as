void RMM_Favorites() {
    bool opened = UI::BeginMenu(Icons::CodeFork + " Favorites");
    if (UI::IsItemClicked(UI::MouseButton::Right)) { S_showSettingsPopupUI = !S_showSettingsPopupUI; }

    if (opened) {
        for (uint i = 0; i < g_Favorites.Length; i++) {
            if (g_Favorites[i].IsSeparator) { UI::Separator(); }
            else { CallRender(g_Favorites[i].PluginID); }
        }
        UI::EndMenu();
    }
}

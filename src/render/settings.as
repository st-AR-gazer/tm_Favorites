class FavoriteEntry {
    string PluginID;
    bool IsSeparator;
}

const string SEP_ID = "__SEPARATOR__";

[Setting hidden]
bool S_showSettingsPopupUI = true;

array<FavoriteEntry> g_Favorites;

bool g_ShowRemoveAllConfirm = false;
bool g_HideUnavailable = false;
string g_FilterText = "";
int g_SelectedIndex = -1;

string g_CurrentProfile = "Default";

bool g_RenamePopup = false;
string g_RenameBuffer = "";

void RenderSettings() {
    RT_Settings_General();
}

void RenderInterface() {
    if (!S_showSettingsPopupUI) return;

    if (UI::Begin("Favorites Settings", S_showSettingsPopupUI,
                  UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize))
    {
        RT_Settings_General();
    }
    UI::End();
}

void RT_Settings_General() {

    array<string> names = g_Profiles.GetKeys();
    names.SortAsc();
    if (names.Find(g_CurrentProfile) < 0) { names.InsertLast(g_CurrentProfile); names.SortAsc(); }

    int idx = names.Find(g_CurrentProfile);
    if (idx < 0) idx = 0;

    if (UI::BeginCombo("Active Profile", names[idx])) {
        for (uint i = 0; i < names.Length; i++) {
            bool sel = (names[i] == g_CurrentProfile);
            if (UI::Selectable(names[i], sel)) {
                SaveProfile(g_CurrentProfile);
                g_CurrentProfile = names[i];
                LoadProfile(g_CurrentProfile);
            }
            if (sel) UI::SetItemDefaultFocus();
        }
        UI::EndCombo();
    }
    
    if (UI::Button("New Profile")) {
        SaveProfile(g_CurrentProfile);
        g_CurrentProfile = "Profile" + (names.Length + 1);
        g_Favorites.Resize(0);
        SaveProfile(g_CurrentProfile); SaveAllProfiles();
    }
    UI::SameLine();
    if (UI::Button("Rename Profile")) { g_RenameBuffer = g_CurrentProfile; g_RenamePopup = true; }
    UI::SameLine();
    if (UI::Button("Delete Profile") && g_CurrentProfile != "Default") {
        g_Profiles.Remove(g_CurrentProfile);
        g_CurrentProfile = "Default";
        LoadProfile(g_CurrentProfile);
        SaveAllProfiles();
    }

    if (g_RenamePopup) {
        if (UI::Begin("Rename Profile", g_RenamePopup,
                      UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize))
        {
            UI::Text("New name:");
            g_RenameBuffer = UI::InputText("##newname", g_RenameBuffer);
            if (UI::Button("OK")) {
                string nm = g_RenameBuffer.Trim();
                if (nm.Length > 0 && !g_Profiles.HasKey(nm)) {
                    RenameProfile(g_CurrentProfile, nm);
                    g_CurrentProfile = nm;
                    SaveAllProfiles();
                }
                g_RenamePopup = false;
            }
            UI::SameLine();
            if (UI::Button("Cancel")) { g_RenamePopup = false; }
            UI::End();
        }
    }



    UI::Separator();
    if (UI::Button("Add Plugin"))          { AddSelectedPlugin(); }
    UI::SameLine();
    if (UI::Button("Add Separator")) {
        FavoriteEntry fe; fe.PluginID = SEP_ID; fe.IsSeparator = true;
        g_Favorites.InsertLast(fe);
        SaveProfile(g_CurrentProfile); SaveAllProfiles();
    }
    UI::SameLine();
    if (UI::Button("Add All (Filter)"))    { AddAllFilteredPlugins(); }
    UI::SameLine();
    if (UI::Button("Remove All"))          { g_ShowRemoveAllConfirm = true; }

    if (g_ShowRemoveAllConfirm) {
        if (UI::Begin("Confirm Remove All", g_ShowRemoveAllConfirm,
                      UI::WindowFlags::NoCollapse | UI::WindowFlags::AlwaysAutoResize))
        {
            UI::Text("Remove all favorites?");
            if (UI::Button("Yes")) {
                g_Favorites.Resize(0);
                SaveProfile(g_CurrentProfile); SaveAllProfiles();
                g_ShowRemoveAllConfirm = false;
            }
            UI::SameLine();
            if (UI::Button("No")) { g_ShowRemoveAllConfirm = false; }
            UI::End();
        }
    }

    g_HideUnavailable = UI::Checkbox("Hide Unavailable", g_HideUnavailable);
    UI::Separator();
    UI::Text("Filter:");
    UI::SameLine();
    g_FilterText = UI::InputText("##filter", g_FilterText);
    if (UI::IsItemFocused() && UI::IsKeyPressed(UI::Key::Enter)) { AddSelectedPlugin(); }

    Meta::Plugin@[] all = Meta::AllPlugins();
    array<Meta::Plugin@> filt;
    for (uint i = 0; i < all.Length; i++) {
        bool match = g_FilterText == "" || all[i].Name.ToLower().Contains(g_FilterText.ToLower());
        if (!match) continue;
        if (g_HideUnavailable && !PluginIsKnown(all[i].ID)) continue;
        filt.InsertLast(all[i]);
    }
    if (g_SelectedIndex >= int(filt.Length)) g_SelectedIndex = filt.Length - 1;
    if (g_SelectedIndex < 0 && filt.Length > 0) g_SelectedIndex = 0;
    string preview = (filt.Length > 0 && g_SelectedIndex >= 0) ? filt[g_SelectedIndex].Name : "---";

    if (UI::BeginCombo("##plugins", preview)) {
        for (uint i = 0; i < filt.Length; i++) {
            bool sel = (i == uint(g_SelectedIndex));
            if (UI::Selectable(filt[i].Name, sel)) { g_SelectedIndex = i; }
            if (sel) UI::SetItemDefaultFocus();
        }
        UI::EndCombo();
    }

    UI::SameLine();
    bool hasRender = false;
    if (filt.Length > 0 && g_SelectedIndex >= 0) { hasRender = PluginIsKnown(filt[g_SelectedIndex].ID); }

    if (hasRender) {
        UI::PushStyleColor(UI::Col::Text, vec4(0,1,0,1));
        UI::Text(Icons::Check);
        UI::PopStyleColor();
    } else {
        UI::PushStyleColor(UI::Col::Text, vec4(1,0.6,0,1));
        UI::Text(Icons::ExclamationTriangle);
        UI::PopStyleColor();
    }

    UI::Separator();
    UI::Text("Current Favorites");
    for (uint i = 0; i < g_Favorites.Length; i++) {
        bool sep = g_Favorites[i].IsSeparator;
        string id = g_Favorites[i].PluginID;
        Meta::Plugin@ p = sep ? null : Meta::GetPluginFromID(id);
        UI::Text(sep ? "Separator" : (p is null ? id : p.Name));
        UI::SameLine();

        if (UI::Button(Icons::AngleUp + "##u" + i) && i > 0) {
            auto t = g_Favorites[i]; g_Favorites.RemoveAt(i); g_Favorites.InsertAt(i-1,t);
            SaveProfile(g_CurrentProfile); SaveAllProfiles();
        }
        UI::SameLine();
        if (UI::Button(Icons::AngleDown + "##d" + i) && i < g_Favorites.Length-1) {
            auto t = g_Favorites[i]; g_Favorites.RemoveAt(i); g_Favorites.InsertAt(i+1,t);
            SaveProfile(g_CurrentProfile); SaveAllProfiles();
        }
        UI::SameLine();
        if (UI::Button(Icons::Trash + "##x" + i)) {
            g_Favorites.RemoveAt(i--);
            SaveProfile(g_CurrentProfile); SaveAllProfiles();
        }
    }
}

bool PluginIsKnown(const string &in id) {
    return HasManualRender(id) || HasAutoRender(id);
}

void AddSelectedPlugin() {
    Meta::Plugin@[] all = Meta::AllPlugins();
    array<Meta::Plugin@> filt;
    for (uint i = 0; i < all.Length; i++) {
        bool match = g_FilterText == "" || all[i].Name.ToLower().Contains(g_FilterText.ToLower());
        if (!match) continue;
        if (g_HideUnavailable && !PluginIsKnown(all[i].ID)) continue;
        filt.InsertLast(all[i]);
    }
    if (g_SelectedIndex < 0 || g_SelectedIndex >= int(filt.Length)) return;

    Meta::Plugin@ pl = filt[g_SelectedIndex];
    if (!PluginIsKnown(pl.ID)) return;

    for (uint k = 0; k < g_Favorites.Length; k++) {
        if (!g_Favorites[k].IsSeparator && g_Favorites[k].PluginID == pl.ID) { return; }
    }
    FavoriteEntry fe; fe.PluginID = pl.ID; fe.IsSeparator = false;
    g_Favorites.InsertLast(fe);
    SaveProfile(g_CurrentProfile); SaveAllProfiles();
}

void AddAllFilteredPlugins() {
    Meta::Plugin@[] all = Meta::AllPlugins();
    array<Meta::Plugin@> filt;
    for (uint i = 0; i < all.Length; i++) {
        bool match = g_FilterText == "" || all[i].Name.ToLower().Contains(g_FilterText.ToLower());
        if (!match) continue;
        if (g_HideUnavailable && !PluginIsKnown(all[i].ID)) continue;
        filt.InsertLast(all[i]);
    }
    uint added = 0;
    for (uint i = 0; i < filt.Length; i++) {
        string pid = filt[i].ID;
        if (!PluginIsKnown(pid)) continue;
        bool exists = false;
        for (uint k = 0; k < g_Favorites.Length; k++) {
            if (!g_Favorites[k].IsSeparator && g_Favorites[k].PluginID == pid) { exists = true; break; }
        }
        if (!exists) {
            FavoriteEntry fe; fe.PluginID = pid; fe.IsSeparator = false;
            g_Favorites.InsertLast(fe);
            added++;
        }
    }
    if (added > 0) { SaveProfile(g_CurrentProfile); SaveAllProfiles(); }
}

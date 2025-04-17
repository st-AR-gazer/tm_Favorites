Json::Value g_Profiles = Json::Object();
const string PROFILES_JSON_PATH = IO::FromDataFolder("FavoritesProfiles.json");

void SaveAllProfiles() {
    IO::File f(PROFILES_JSON_PATH, IO::FileMode::Write);
    f.WriteLine(Json::Write(g_Profiles));
    f.Close();
}

void LoadAllProfiles() {
    if (!IO::FileExists(PROFILES_JSON_PATH)) {
        g_Profiles = Json::Object();
        g_Profiles["Default"] = Json::Array();
        SaveAllProfiles();
        return;
    }
    IO::File f(PROFILES_JSON_PATH, IO::FileMode::Read);
    string raw = "";
    while (!f.EOF()) { raw += f.ReadLine(); }
    f.Close();

    g_Profiles = Json::Parse(raw);
    if (g_Profiles.GetType() != Json::Type::Object) {
        g_Profiles = Json::Object();
        g_Profiles["Default"] = Json::Array();
        SaveAllProfiles();
    }
}

void SaveProfile(const string &in name) {
    Json::Value arr = Json::Array();
    for (uint i = 0; i < g_Favorites.Length; i++) {
        arr.Add(g_Favorites[i].IsSeparator ? SEP_ID : g_Favorites[i].PluginID);
    }
    g_Profiles[name] = arr;
}

void LoadProfile(const string &in name) {
    if (!g_Profiles.HasKey(name)) { g_Profiles[name] = Json::Array(); }
    Json::Value arr = g_Profiles[name];
    g_Favorites.Resize(0);
    for (uint i = 0; i < arr.Length; i++) {
        FavoriteEntry fe;
        fe.IsSeparator = (arr[i] == SEP_ID);
        fe.PluginID    = arr[i];
        g_Favorites.InsertLast(fe);
    }
}

void RenameProfile(const string &in oldName, const string &in newName) {
    if (!g_Profiles.HasKey(oldName) || g_Profiles.HasKey(newName)) { return; }
    g_Profiles[newName] = g_Profiles[oldName];
    g_Profiles.Remove(oldName);
}

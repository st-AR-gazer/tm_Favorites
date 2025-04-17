void Main() {
    LoadAllProfiles();
    g_CurrentProfile = "Default";
    LoadProfile(g_CurrentProfile);
}

void RenderMenuMain() {
    RMM_Favorites();
}

void OnDisabled() {
    SaveProfile(g_CurrentProfile);
    SaveAllProfiles();
}

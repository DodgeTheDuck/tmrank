
// User interface
Window _window;

// Plugin entry point
void Main() {
    Logger::DevMessage("--- Starting plugin ---");
    _window = Window();
    Logger::DevMessage("Authenticating with Nadeo...");
    Async::Await(Nadeo::Service::Authenticate);
    Logger::DevMessage("Loading TMRank data...");
    Async::Await(TMRank::Service::LoadMapPacks);
    Async::Await(TMRank::Service::LoadUserData);
    // Logger::DevMessage("Loading Nadeo map data...");
    // Async::Await(Nadeo::Service::FetchMapInfoForStyle, "RPG");
    // Async::Await(Nadeo::Service::FetchMapInfoForStyle, "Trial");
    // Async::Await(Nadeo::Service::FetchMapInfoForStyle, "SOTD");
}

void Update(float dt) {
    _window.Update(dt);
}

void Render() {
    if(!UI::IsGameUIVisible()) return;
    _window.Render();
}
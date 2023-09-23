
// User interface
Window _window;
bool _reload;

// Plugin entry point
void Main() {
    Logger::DevMessage("--- Starting plugin ---");
    _window = Window();
    Logger::DevMessage("Authenticating with Nadeo...");
    Async::Await(Nadeo::Service::Authenticate);
    Logger::DevMessage("Loading TMRank data...");
    Async::Await(TMRank::Service::LoadMapPacks);
    Async::Await(TMRank::Service::LoadUserData);
    _reload = false;
}

void Update(float dt) {
    _window.Update(dt);
}

void RenderInterface() {
    if(!UI::IsGameUIVisible()) return;
    _window.Render();
}

void RenderMenu()
{
    string menuItemText = Colors::colGold + Icons::Kenney::Podium + Colors::colWhite + " TMRank";
    if(UI::MenuItem(menuItemText, "")) {
       _window.Show();
    }
}
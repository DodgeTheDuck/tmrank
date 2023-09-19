
Window _window;

void Main() {
    Logger::DevMessage("--- Starting plugin ---");
    _window = Window();    
    Logger::DevMessage("Authenticating with Nadeo...");
    Async::Await(Nadeo::Api::Authenticate);
    Logger::DevMessage("Loading TMRank data...");
    Async::Await(TMRank::Service::Load);
    Logger::DevMessage("Loading Nadeo map data...");
    Async::Await(Nadeo::Service::Load, "RPG");
    Async::Await(Nadeo::Service::Load, "Trial");
    Async::Await(Nadeo::Service::Load, "SOTD");
}

void Update(float dt) {
    _window.Update(dt);
}

void Render() {
    if(!UI::IsGameUIVisible()) return;
    _window.Render();
}
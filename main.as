
Window _window;

void Main() {
    print("--- Starting plugin ---");
    _window = Window();    
    print("Authenticating with Nadeo...");
    Async::Await(Nadeo::Api::Authenticate);
    print("Loading TMRank data...");
    Async::Await(TMRank::Service::Load);
    print("Loading Nadeo map data...");
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
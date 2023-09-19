namespace Logger {
    void DevMessage(string message) {
        if(Meta::IsDeveloperMode()) {
            print(message);
        }
    }
    void Error(string message) {
        throw(message);
    }
}
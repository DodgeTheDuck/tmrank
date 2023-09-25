
// Logging helper functions
namespace Logger {

    // Print to console when in dev mode
    void DevMessage(string message) {
        if(Meta::IsDeveloperMode()) {
            print(message);
        }
    }

    // Raise a fatal error
    void Error(string message) {
        throw(message);
    }
}

// Async function wrappers
namespace Async {

    // Start a yieldable coroutine
    void Start(CoroutineFunc@ routine) {
        startnew(routine);
    }

    void Start(CoroutineFuncUserdata@ routine, ref userData) {
        startnew(routine, userData);
    }

    // Yield until coroutine is complete
    void Await(CoroutineFunc@ routine) {
        auto cr = startnew(routine);
        while(cr.IsRunning()) {
            yield();
        }
    }

    // Yield until coroutine is complete
    void Await(CoroutineFuncUserdataString@ routine, string userData) {
        auto cr = startnew(routine, userData);
        while(cr.IsRunning()) {
            yield();
        }
    }

    // Yield until coroutine is complete
    void Await(CoroutineFuncUserdataInt64@ routine, int userData) {
        auto cr = startnew(routine, userData);
        while(cr.IsRunning()) {
            yield();
        }
    }

    // Yield until coroutine is complete
    void Await(CoroutineFuncUserdata@ routine, ref userData) {
        auto cr = startnew(routine, userData);
        while(cr.IsRunning()) {
            yield();
        }
    }

}
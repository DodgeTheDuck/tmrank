
namespace Async {

    void Start(CoroutineFunc@ routine) {
        startnew(routine);
    }

    void Await(CoroutineFunc@ routine) {
        auto cr = startnew(routine);
        while(cr.IsRunning()) {
            yield();
        }
    }

    void Await(CoroutineFuncUserdataString@ routine, string userData) {
        auto cr = startnew(routine, userData);
        while(cr.IsRunning()) {
            yield();
        }
    }

    void Await(CoroutineFuncUserdataInt64@ routine, int userData) {
        auto cr = startnew(routine, userData);
        while(cr.IsRunning()) {
            yield();
        }
    }

    void Await(CoroutineFuncUserdata@ routine, ref userData) {
        auto cr = startnew(routine, userData);
        while(cr.IsRunning()) {
            yield();
        }
    }

}
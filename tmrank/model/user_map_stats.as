
namespace TMRank {
    namespace Model {
        class UserMapStats {

            int score;
            int pb;

            UserMapStats(const Json::Value &in json) {
                try {
                    score = json["score"];
                    pb = json["finish_finish_time"];
                } catch {
                    throw("Unable to parse UserMapStats json");
                }
            }

        }
    }
}
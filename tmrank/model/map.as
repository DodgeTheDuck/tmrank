
namespace TMRank {
    namespace Model {

        class Map {

            uint id;
            string nid;
            string uid;
            string name;
            string img;
            int finishScore;
            int bronzeScore;
            int silverScore;
            int goldScore;
            int authorScore;
            int bronzeTime;
            int silverTime;
            int goldTime;
            int authorTime;
            int finishes;
            int worldRecord;

            Map(const Json::Value@ &in json) {
                try {
                    id = json["map_id"];
                    nid = json["map_nid"];
                    uid = json["map_uid"];
                    name = json["map_name"];
                    img = json["map_img"];
                    finishScore = json["map_finish_score"];
                    bronzeScore = json["map_bronze_score"];
                    silverScore = json["map_silver_score"];
                    goldScore = json["map_gold_score"];
                    authorScore = json["map_at_score"];
                    bronzeTime = json["map_bronze_time"];
                    silverTime = json["map_silver_time"];
                    goldTime = json["map_gold_time"];
                    authorTime = json["map_at_time"];
                    finishes = json["fins"];
                    worldRecord = json["wr"];
                } catch {
                    throw("Unable to parse Map json");
                }
            }

        }

    }
}
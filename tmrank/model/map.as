
namespace TMRank {
    namespace Model {

        class Map {

            uint ID;
            string NID;
            string UID;
            string Name;
            string Img;
            int FinishScore;
            int BronzeScore;
            int SilverScore;
            int GoldScore;
            int AuthorScore;
            int BronzeTime;
            int SilverTime;
            int GoldTime;
            int AuthorTime;
            int Finishes;
            int WorldRecord;
            UserMapStats@ UserStats;

            Map(const Json::Value@ &in json) {
                try {
                    ID = json["map_id"];
                    NID = json["map_nid"];
                    UID = json["map_uid"];
                    Name = json["map_name"];
                    Img = json["map_img"];
                    FinishScore = json["map_finish_score"];
                    BronzeScore = json["map_bronze_score"];
                    SilverScore = json["map_silver_score"];
                    GoldScore = json["map_gold_score"];
                    AuthorScore = json["map_at_score"];
                    BronzeTime = json["map_bronze_time"];
                    SilverTime = json["map_silver_time"];
                    GoldTime = json["map_gold_time"];
                    AuthorTime = json["map_at_time"];
                    Finishes = json["fins"];
                    WorldRecord = json["wr"];
                } catch {
                    throw("Unable to parse Map json");
                }
            }

        }

    }
}
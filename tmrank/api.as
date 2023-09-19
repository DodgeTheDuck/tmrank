
namespace TMRank {
    namespace Api {

        const string MAP_CSV_ENDPOINT = "https://raw.githubusercontent.com/spl1nes/tmrank/master/maps.csv";

        void GetMapData() {        
            Net::HttpRequest@ req = Net::HttpGet(MAP_CSV_ENDPOINT);
            while(!req.Finished()) yield();
            if(req.ResponseCode() != 200) {
                print("GetCsv status " + req.ResponseCode());
            }
            auto res = req.String();
            TMRank::Csv@ csv = @TMRank::Csv(res, true);

            for(int i = 0; i < csv.RowCount(); i++) {
                string[] mapRow = csv.GetRowAtIndex(i);

                TMRank::MapData@ map = @TMRank::MapData();
                map.uid = mapRow[0];
                map.style = mapRow[1];
                map.ptFinish = Text::ParseInt(mapRow[2]);
                map.ptBronze = Text::ParseInt(mapRow[3]);
                map.ptSilver = Text::ParseInt(mapRow[4]);
                map.ptGold = Text::ParseInt(mapRow[5]);
                map.ptAuthor = Text::ParseInt(mapRow[6]);
                TMRank::Repository::AddMap(@map);

            }
        }
    }
}
namespace TMRank {
    namespace Service {

        dictionary _mapStyles = dictionary();

        void Load() {
            Async::Await(TMRank::Api::GetMapData);
            Async::Await(TMRank::Service::CategoriseMaps);
            print("Loaded TMRank map data: " + TMRank::Repository::GetMaps().Length + " maps");
        }

         void CategoriseMaps() {
            print("Categorisig maps...");
            print("Getting RPGs...");
            _mapStyles["RPG"] = _CacheMapsFromStyle("RPG");
            print("Getting Trials...");
            _mapStyles["Trial"] = _CacheMapsFromStyle("Trial");
            print("Getting SOTDs...");
            _mapStyles["SOTD"] = _CacheMapsFromStyle("SOTD");
            print("Categorising complete");
        }

        TMRank::MapData@[] GetMapsFromStyle(string style) {
            if(!_mapStyles.Exists(style)) {
                return {};
            }
            return cast<TMRank::MapData@[]>(_mapStyles[style]);
        }

        TMRank::MapData@[] _CacheMapsFromStyle(string type) {

            auto result = array<TMRank::MapData@>();
            auto maps = TMRank::Repository::GetMaps();
            for(uint i = 0; i < maps.Length; i++) {
                TMRank::MapData@ mapData = maps[i];
                if(mapData.style == type) {
                    result.InsertLast(mapData);
                }
            }            
            print("Cached " + result.Length + " maps for style " + type);
            return result;
        }

    }
}
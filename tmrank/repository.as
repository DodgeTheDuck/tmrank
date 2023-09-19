namespace TMRank {
    namespace Repository {

        TMRank::MapData@[] _maps = {};
        TMRank::Driver@[] _drivers = {};

        bool _dirty = true;
        bool _caching = false;

        TMRank::MapData@[] GetMaps() {
            return _maps;
        }

        TMRank::MapData@ GetMap(int index) {
            return _maps[index];
        }

        void AddMap(TMRank::MapData@ mapData) {
            _maps.InsertLast(@mapData);
        }

        TMRank::Driver GetDriver(int index) {
            return _drivers[index];
        }

    }
}
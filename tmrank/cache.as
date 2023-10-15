
namespace TMRank {
    namespace Cache {

        TMRank::Model::MapPack@[] _mapPacks;

        void CacheMapPack(TMRank::Model::MapPack@ mapPack) {
            _mapPacks.InsertLast(mapPack);
        }

        TMRank::Model::MapPack@[] GetMapPacks() {
            return _mapPacks;
        }

    }
}
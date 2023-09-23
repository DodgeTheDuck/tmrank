namespace App {

    App::Map@[] _maps;

    void AddMap(App::Map@ map) {
        _maps.InsertLast(map);
    }

}
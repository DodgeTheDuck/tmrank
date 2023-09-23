namespace Game {

    void PlayMap(ref@ mapRef) {
        auto map = cast<TMRank::Model::Map@>(mapRef);
        if (Permissions::PlayLocalMap()) {
            string url = Nadeo::Api::GetMapDownloadUrl(map.uid);
            CTrackMania@ app = cast<CTrackMania>(GetApp());
            ReturnToMenu(true);
            app.ManiaTitleControlScriptAPI.PlayMap(url, "", "");
        }
    }
 
    // lovingly stolen from XertroV
    void ReturnToMenu(bool yieldTillReady = false) {
        auto app = cast<CGameManiaPlanet>(GetApp());
        if (app.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
            app.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
        }
        app.BackToMainMenu();
        while (yieldTillReady && !app.ManiaTitleControlScriptAPI.IsReady) yield();
    }

}
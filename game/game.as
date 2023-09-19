namespace Game {

    void PlayMap(ref@ map) {
        auto mapInfo = cast<Nadeo::MapInfo@>(map);
        if (Permissions::PlayLocalMap()) {
            CTrackMania@ app = cast<CTrackMania>(GetApp());
            ReturnToMenu(true);
            app.ManiaTitleControlScriptAPI.PlayMap(mapInfo.downloadUrl, "", "");
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
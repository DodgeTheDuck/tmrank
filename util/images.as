namespace Util {
    namespace Images {

        // Code inspired (almost copied) from TMX plugin
        // https://github.com/GreepTheSheep/openplanet-maniaexchange-menu/blob/main/src/Utils/CachedImage.as

        class CachedImage
        {
            string m_url;
            UI::Texture@ m_texture;
            int m_responseCode;
            bool m_error = false;

            void DownloadFromURLAsync()
            {
                auto req = Http::GetAsyncRaw(m_url);
                @m_texture = UI::LoadTexture(req.Buffer());
                if (m_texture.GetSize().x == 0) {
                    @m_texture = null;
                } else {
                    m_error = true;
                }
            }
        }

        dictionary g_cachedImages;

        CachedImage@ FindExisting(const string &in url)
        {
            CachedImage@ ret = null;
            g_cachedImages.Get(url, @ret);
            return ret;
        }

        CachedImage@ CachedFromURL(const string &in url)
        {
            auto existing = FindExisting(url);
            if (existing !is null) {
                return existing;
            }
            auto ret = CachedImage();
            ret.m_url = url;
            g_cachedImages.Set(url, @ret);
            startnew(CoroutineFunc(ret.DownloadFromURLAsync));
            return ret;
        }
    }
}
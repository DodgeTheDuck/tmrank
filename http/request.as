
namespace Http {

    const uint HTTP_200 = 200;

    Json::Value GetAsync(const string&in url) {
        Net::HttpRequest@ req = Net::HttpGet(url);
        while(!req.Finished()) yield();
        if(req.ResponseCode() != HTTP_200) {
            Logger::Error("Failed request (" + req.ResponseCode() + ") to " + url);
        }
        return Json::Parse(req.String());
    }

    Net::HttpRequest@ GetAsyncRaw(const string&in url) {
        Net::HttpRequest@ req = Net::HttpGet(url);
        while(!req.Finished()) yield();
        if(req.ResponseCode() != HTTP_200) {
            Logger::Error("Failed request (" + req.ResponseCode() + ") to " + url);
        }
        return @req;
    }

}
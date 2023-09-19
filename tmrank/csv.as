
namespace TMRank {

    class Csv {

        string[] _rows;

        Csv(const string&in csvString, bool skipHeader = false) {
            _rows = {};
            Regex::SearchAllResult@ regRows = Regex::SearchAll(csvString, '[^\n]+');
            for(int i = (skipHeader) ? 1 : 0 ; i < regRows.Length; i++) {
                _rows.InsertLast(regRows[i][0]);
            }
        }

        uint RowCount() {
            return _rows.Length;
        }

        string[] GetRowAtIndex(int index) {
            try {
                string row = _rows[index];
                return row.Split(",");
            } catch {
                print("GetRowAtIndex Error");
                return {};
            }
        }

    }

}
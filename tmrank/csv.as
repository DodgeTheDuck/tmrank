
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
            if(index >= _rows.Length) {
                Logger::Error("CSV Row index out of bounds: rows = " + _rows.Length + "; index = " + index);
            }
            string row = _rows[index];
            return row.Split(",");
        }

    }

}
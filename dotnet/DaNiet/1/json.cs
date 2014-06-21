using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using Newtonsoft.Json;

namespace DaNiet
{
    public class Json<T>
    {
        string json;

        public Json(string s) { json = s; }

        public override string ToString() { return json; }

        public Json(T x) { json = JsonConvert.SerializeObject(x); }
        public T New() { return JsonConvert.DeserializeObject<T>(json); }
    }
}

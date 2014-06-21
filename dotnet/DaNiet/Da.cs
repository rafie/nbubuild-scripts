using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DaNiet
{
	public class Da
	{
		public static Path Path(string path) { return new Path(path); }
		public static File File(string path) { return new File(new Path(path)); }
		public static Directory Directory(string path) { return new Directory(new Path(path)); }
	}
}

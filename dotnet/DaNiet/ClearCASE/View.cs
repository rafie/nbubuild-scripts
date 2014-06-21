using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DaNiet.ClearCASE
{
	public class View
	{
		private string _name;
		private static readonly Path view_root = Da.Path("m:/");

		public View(string name)
		{
			_name = name;
		}

		public static implicit operator View(string name)
		{
			return new View(name);
		}

		protected void Start()
		{
			var startview = DaNiet.Syscmd.Run("cleartool startview " + _name);
			if (startview.failed)
				throw new Exception("Error: cannot start view " + _name);
		}

		public Directory Root
		{
			get { return view_root / _name; }
		}
	}
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DaNiet
{
	namespace Ext
	{
		public static class Ext
		{
			public static string stringf(this String fmt, params object[] args)
			{
				return string.Format(fmt, args);
			}
		}
	}
}

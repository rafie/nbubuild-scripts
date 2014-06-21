using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using Plossum.CommandLine;

[assembly: log4net.Config.XmlConfigurator(Watch = true)]

namespace DaNiet
{
	public interface IOptions
	{
		bool _Help { get; }
	}

	public class Program<Options> where Options : IOptions, new()
	{
		protected static readonly log4net.ILog log = log4net.LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

		protected static void Exit(string message, int code = 0)
		{
			Console.WriteLine(message);
			System.Environment.Exit(code);
		}

		protected static Options Args()
		{
			var options = new Options();
			var parser = new CommandLineParser(options);
			parser.Parse();

			if (options._Help)
				Exit(parser.UsageInfo.ToString(78, false));
			else if (parser.HasErrors)
				Exit(parser.UsageInfo.ToString(78, true), -1);

			return options;
		}

		static protected int Run(Func<Options, int> main)
		{
			try
			{
				var options = Args();
				return main(options);
			}
			catch (System.Exception x)
			{
				Exit(string.Format("Error: {0}", x.ToString()), -1);
			}

			return 0;
		}
	}
}

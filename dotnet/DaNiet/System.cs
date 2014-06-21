using System;
using System.Diagnostics;
using System.IO;
using System.Collections.Generic;
using System.Text;

using DaNiet.Ext;

namespace DaNiet
{
#if false
	public class SystemLog
	{
		protected static string system_log = "c:/system.log";

		void Append(string output, string error, int retcode)
		{
			try
			{
				FileStream fileStream = File.Open(system_log, FileMode.Append, FileAccess.Write, FileShare.Read);
			}
			catch (Exception)
			{
				System.Threading.Thread.Sleep(500);
			}
		}		
	}
#endif

	public class Syscmd
    {
		static readonly File systemLog = Da.File("c:/system.log");

		protected class Output
		{
			private bool _first = true;
			//public string text;
			private StringBuilder _builder = new StringBuilder();

			public static implicit operator string(Output self) { return self.ToString(); }

			public void AppendLine(string line)
			{
				if (_first)
					_first = false;
				else
					_builder.AppendLine("");
				_builder.Append(line);
			}

			override public string ToString()
			{
				return _builder.ToString();
			}
		}

	    private Output _out, _err, _all;

		protected int ret_code;

		private void resetOutput()
		{
			_out = new Output();
			_err = new Output();
			_all = new Output();
		}

   		static public Syscmd Run(string cmd, bool log = true, Directory at = null)
   		{
   			return new Syscmd(cmd, log, at);
   		}

		static public Syscmd Runx(string cmd, bool log = true, Directory at = null)
		{
			var syscmd = new Syscmd(cmd, log, at);
			if (syscmd.failed)
				throw new Exception("Command '{0}' failed with return code {1}".stringf(cmd, syscmd.retcode));
			return syscmd;
		}

		public Syscmd(string cmd, bool log = true, Directory at = null)
    	{
			var t0 = DateTime.Now;
			string when = t0.ToString("yy-MM-dd HH-mm-ss");
			string where = at != null ? at.ToString() : System.IO.Directory.GetCurrentDirectory();

			string[] v = cmd.Split(new Char[] { ' ', '\t' }, 2);
    		if (v.Length < 1)
    			throw new ArgumentException("Invalid command");
    		string prog = v[0];
    		string args = v.Length > 1 ? v[1] : "";
			var p = new Process
				{
					StartInfo =
						{
							UseShellExecute = false,
							CreateNoWindow = true,
							RedirectStandardOutput = true,
							RedirectStandardError = true,
							FileName = prog,
							WorkingDirectory = at != null ? at.ToString() : "",
							Arguments = args
						}
				};
			p.OutputDataReceived += (sender, arg) => { _out.AppendLine(arg.Data); _all.AppendLine(arg.Data); };
			p.ErrorDataReceived += (sender, arg) => { _err.AppendLine(arg.Data); _all.AppendLine(arg.Data); };

			try
			{
				resetOutput();
			 	p.Start();
			}
			catch
			{
				resetOutput();
				string comspec = Environment.GetEnvironmentVariable("COMSPEC");
				if (comspec == "")
					comspec = "cmd.exe";
				p.StartInfo.FileName = comspec;
			 	p.StartInfo.Arguments = "/c " + cmd;
			 	p.Start();
			}
			p.BeginOutputReadLine();
			p.BeginErrorReadLine();
			while (! p.HasExited)
				p.WaitForExit(1000);
			ret_code = p.ExitCode;

			// invoke
			var t1 = DateTime.Now;
			var elapsed = (t1 - t0).Seconds;

/*
			string log_text = ("=== {0} ({1}s) [{2}]\n" + 
				"{3}\n" + 
				"--- ({4})\n" + 
				"{5}\n" + 
				"---\n" +
				"{6}\n" +
				"---\n").stringf(when, elapsed, where, cmd, ret_code, _out.ToString(), _err.ToString());
 */
				string log_text = 
@"=== {0} ({1}s) [{2}]
{3}
--- ({4})
{5}
---
{6}
---
"					.stringf(when, elapsed, where, cmd, ret_code, _out.ToString(), _err.ToString());

			systemLog.Wait((stream) =>
				{
					using (var writer = new StreamWriter(stream))
					{
						writer.WriteLine(log_text);
					}
				});
		}
   
    	protected string[] lines(string s)
    	{
      		var reader = new StringReader(_out);
      		var lines = new List<string>();
      		for (;;)
      		{
      			string line = reader.ReadLine();
      			if (line != null)
      				break;
				lines.Add(line);
      		}
      		return lines.ToArray();	  		
    	}
   
    	public string outstr { get { return _out; } }

    	public string[] output { get { return lines(_out); } }

    	public string out0
    	{
    		get
	    	{
	      		var reader = new StringReader(_out);
	    		string line =  reader.ReadLine();
	    		return line ?? "";
	  		}
    	}

		public string errstr { get { return _err; } }

		public string[] error { get { return lines(_err); } }
    	
    	public string err0
    	{
    		get
	    	{
				var reader = new StringReader(_err);
	    		string line =  reader.ReadLine();
	    		return line ?? "";
	    	}
    	}

		public string allstr { get { return _all; } }

		public string[] all { get { return lines(_all); } }

    	public int retcode { get { return ret_code; } }

		public bool OK { get { return retcode == 0;  } }
		public bool failed { get { return retcode != 0; } }
    }
	
	public class Screen
	{
		public static string ReadPassword(string prompt = "Password: ")
		{
			string pass = "";
			Console.Write(prompt);
			ConsoleKeyInfo key;
			
			do
			{
			    key = Console.ReadKey(true);	
				if (key.Key != ConsoleKey.Backspace && key.Key != ConsoleKey.Enter)
				{
				   pass += key.KeyChar;
				   Console.Write("*");
				}
				else
				{
				   if (key.Key == ConsoleKey.Backspace && pass.Length > 0)
				   {
				      pass = pass.Substring(0, pass.Length - 1);
				      Console.Write("\b \b");
				   }
				}
			}
			while (key.Key != ConsoleKey.Enter);
			Console.WriteLine();

			return pass;			
		}
	}
}

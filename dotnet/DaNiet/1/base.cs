using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

using ZMQ;
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

    public class System
    {
    	protected string _out, _err;
    	protected int ret_code;
   
    	public System(string cmd)
    	{
    		string[] v = cmd.Split(new Char[] { ' ', '\t' }, 2);
    		 if (v.Length < 1)
    		 	throw new ArgumentException("Invalid command");
    		 string prog = v[0];
    		 string args = v.Length > 1 ? v[1] : "";
			 Process p = new Process();
			 // Redirect the error stream of the child process.
			 p.StartInfo.UseShellExecute = false;
			 p.StartInfo.RedirectStandardOutput = true;
			 p.StartInfo.RedirectStandardError = true;
			 p.StartInfo.FileName = prog;
			 p.StartInfo.Arguments = args;
			 try
			 {
			 	p.Start();
			 }
			 catch
			 {
			 	p.StartInfo.FileName = "cmd.exe";
			 	p.StartInfo.Arguments = "/c " + cmd;
			 	p.Start();
			 }
			 _err = p.StandardError.ReadToEnd();
//			 p.WaitForExit();
			 _out = p.StandardOutput.ReadToEnd();
			 p.WaitForExit();
    	}
    	
    	public string output { get { return _out; } }

    	public string out0()
    	{
      		var reader = new StringReader(_out);
    		string line =  reader.ReadLine();
    		return line == null ? "" : line;
  	}
    	
    	public string error { get { return _err; } }
    	
    	public string err0()
    	{
    		var reader = new StringReader(_err);
    		string line =  reader.ReadLine();
    		return line == null ? "" : line;
    	}
    	
    	public int retcode { get { return ret_code; } }
    }

    public class Person
    {
        public string Name { get; set; }
        public string[] Traits { get; set; }
    }
}

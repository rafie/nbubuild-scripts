using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;

namespace DaNiet
{
	//-----------------------------------------------------------------------------------------

	public class Path
	{
		private string _path;

		public Path(string path)
		{
			_path = path;
		}

		public Path this[string path]
		{
			get { return new Path(System.IO.Path.Combine(_path, path)); }
		}

		public static Path operator +(Path self, string str)
		{
			return new Path(self._path + str);
		}

		public static Path operator /(Path self, string path)
		{
			return new Path(System.IO.Path.Combine(self._path, path));
		}

		public static implicit operator string(Path self)
		{
			return self._path;
		}
		
		override public string ToString() { return _path; }
	}

	//-----------------------------------------------------------------------------------------

	public class File
	{
		private Path _path;

		public File(Path path)
		{
			_path = path;
		}

		public Path Path { get { return _path; } }
		
		public static implicit operator File(Path path)
		{
			return new File(path);
		}

		public bool Exists()
		{
			return System.IO.File.Exists(_path);
		}

		public static implicit operator Path(File self)
		{
			return self._path;
		}

		override public string ToString() { return _path.ToString(); }
			
		public static implicit operator string(File self)
		{
			return self._path;
		}

		public string AllText()
		{
			return System.IO.File.ReadAllText(_path);
		}

		public IEnumerable<string> Lines()
		{
			using (StreamReader in1 = System.IO.File.OpenText(_path))
			{
				string line;
				while ((line = in1.ReadLine()) != null)
					yield return line;
			}
		}

		public void Wait(Action<FileStream> action, FileMode mode = FileMode.Append)
		{
			var event1 = new AutoResetEvent(false);
			for (;;)
			{
				try
				{
					using (var file = System.IO.File.Open(_path, mode, FileAccess.Write, FileShare.Read))
					{
						action(file);
						break;
					}
				}
				catch (IOException)
				{
					var fileSystemWatcher = new FileSystemWatcher(System.IO.Path.GetDirectoryName(_path))
						{
							EnableRaisingEvents = true
						};
			
					fileSystemWatcher.Changed += (o, e) =>
						{
							if (System.IO.Path.GetFullPath(e.FullPath) == System.IO.Path.GetFullPath(_path))
								event1.Set();
						};
					event1.WaitOne();
				}
			}
		}	
	}

	//-----------------------------------------------------------------------------------------

	public class Directory
	{
		private Path _path;

		public Directory(Path path)
		{
			_path = path;
		}

		public static implicit operator Directory(Path path)
		{
			return new Directory(path);
		}

		public bool Exists()
		{
			return System.IO.Directory.Exists(_path);
		}

		public void Create()
		{
			System.IO.Directory.CreateDirectory(_path);
		}

		public static Directory Create(Path path)
		{
			var dir = new Directory(path);
			dir.Create();
			return dir;
		}

		public static Path operator /(Directory self, string path)
		{
			return new Path(System.IO.Path.Combine(self._path, path));
		}

		public static implicit operator Path(Directory self)
		{
			return self._path;
		}

		override public string ToString() { return _path.ToString(); }
	}

	//-----------------------------------------------------------------------------------------
}

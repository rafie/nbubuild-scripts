using System.Threading;

namespace DaNiet
{
	public abstract class Thread
	{
		System.Threading.Thread _thread;

		static void _Main(object self)
		{
			((Thread) self).Main();
		}
		
		public abstract void Main();

		public Thread()
		{
			_thread = new System.Threading.Thread(new ParameterizedThreadStart(_Main));
		}
		
		public void Start()
		{
			_thread.Start(this);
		}
		
		public void Join()
		{
			_thread.Join();
		}
	}
}

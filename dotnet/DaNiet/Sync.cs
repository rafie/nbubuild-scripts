using System;
using System.Threading;

namespace DaNiet
{
	public class Sync
	{
		static public void Take(Mutex mutex, Action action)
		{
			try
			{
				mutex.WaitOne();
				action();
			}
			finally
			{
				mutex.ReleaseMutex();
			}
		}

		static public T Take<T>(Mutex mutex, Func<T> funct)
		{
			try
			{
				mutex.WaitOne();
				return funct();
			}
			finally
			{
				mutex.ReleaseMutex();
			}
		}
	}
}

using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Concurrent;
using System.Threading;

using NGenerics;
using NGenerics.DataStructures.Queues;

namespace DaNiet
{
	public class SyncPQueue<T> : ICollection<T>, IEnumerable<T>, IEnumerable, IQueue<T>
	{
		readonly object _lock = new object();
		ManualResetEvent not_empty = new ManualResetEvent(false);
		PriorityQueue<T, int> _pq;

		public SyncPQueue()
	    {
			DefaultPriority = 0;
			_pq = new PriorityQueue<T, int>(PriorityQueueType.Minimum);
	    }

		public int DefaultPriority
		{
			get;
			set;
		}

		public void Enqueue(T item, int prio)
		{
			lock (_lock)
			{
				_pq.Enqueue(item, prio);
				not_empty.Set();
			}
		}
	
		public T Dequeue()
		{
			int prio;
			return Dequeue(out prio);
		}

		public T Dequeue(out int prio)
		{
			prio = DefaultPriority;
			T item = default(T);
			for (;;)
			{
				while (!not_empty.WaitOne())
					;
				lock(_lock)
				{
					if (_pq.Count == 0)
						break;
					item = _pq.Dequeue(out prio);
					if (_pq.Count == 0)
						not_empty.Reset();
					return item;
				}
			}
			return item;
		}
		
		public bool SetPriority(int key, int new_prio, Func<T, int> keyfunc)
		{
			lock(_lock)
			{
				foreach (T obj in _pq)
				{
					if (keyfunc(obj) == key)
					{
						_pq.Remove(obj);
						_pq.Enqueue(obj, new_prio);
						return true;
					}
				}
				return false;
			}
		}
	
		public bool IsReadOnly
		{
			get { return false; }
		}

		public int Count
		{
			get { lock(_lock) return _pq.Count; }
		}

		public bool IsEmpty
		{
			get { return Count == 0; }
		}

		public T Peek()
		{
			lock(_lock) return _pq.Peek();
		}

		public bool Contains(T item)
		{
			lock(_lock) return _pq.Contains(item);
		}

		public void Add(T item)
		{
			Enqueue(item);
		}

		public void Enqueue(T item)
		{
			Enqueue(item, DefaultPriority);
		}
		
		public bool Remove(T item)
		{
			lock(_lock) return _pq.Remove(item);
		}

		public bool RemoveKey(int key, Func<T, int> keyfunc)
		{
			lock(_lock)
			{
				bool found = false;
				T item = default(T);
				foreach (T obj in _pq)
				{
					if (keyfunc(obj) == key)
					{
						item = obj;
						//_pq.Remove(obj);
						found = true;
						break;
					}
				}
				if (found)
					_pq.Remove(item);
				return found;
			}
		}

		public void Clear()
		{
			lock(_lock) _pq.Clear();
		}

		public SyncPQueue<T> Clone()
		{
			var pq = new SyncPQueue<T>();
			lock (_lock)
			{
				var i = _pq.GetKeyEnumerator();
				while (i.MoveNext())
					pq.Enqueue(i.Current.Value, i.Current.Key);
				return pq;
			}
		}

	    public T[] ToArray()
	    {
	    	T[] array = null;
	        lock (_lock) 
	        {
	        	array = new T[_pq.Count];
	        	_pq.CopyTo(array, 0);
	        }
	        return array;
	    }
	
	    public void CopyTo(T[] array, int index)
	    {
	        lock (_lock) _pq.CopyTo(array, index);
	    }
	
	    public IEnumerator<T> GetEnumerator()
	    {
		    var pq = Clone();
			var copy = new T[pq.Count];
			for (var i = 0; !pq.IsEmpty; ++i)
				copy[i] = pq.Dequeue();

			return new List<T>(copy).GetEnumerator();
	    }
	
	    IEnumerator IEnumerable.GetEnumerator()
	    {
	        return ((IEnumerable<T>)this).GetEnumerator();
	    }
	
	    public bool IsSynchronized
	    {
	        get { return true; }
	    }
	
	    public object SyncRoot
	    {
	        get { return _lock; }
	    }
	
	    public void CopyTo(Array array, int index)
	    {
	        lock (_lock) ((ICollection)_pq).CopyTo(array, index);
	    }
	}
}

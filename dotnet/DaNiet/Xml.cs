using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Xml;
using System.Xml.XPath;

namespace DaNiet
{

	public class Xml
	{
		public string base_xml, _query;
		public XPathNavigator _nav;
    	public XPathNodeIterator _i;

   		//-------------------------------------------------------------------------------------
   		// Construction
		//-------------------------------------------------------------------------------------

		public static XmlFile FromFile(string fname)
		{
			return new XmlFile(fname);
		}

		internal void Init(XPathNodeIterator i, string query = "/")
		{
			_i = i.Clone();
			if (_i.CurrentPosition == 0) // standing before first node
				_i.MoveNext();
			_nav = _i.Current;
			base_xml = _nav.OuterXml;
			_query = query;
#if DEBUG
			Debug.Print("xml:\n" + base_xml + "\n");
			Debug.Print("query:" + _query + "\n\n");
#endif
			
		}
		
		protected Xml()
		{
		}

		protected Xml(XPathNodeIterator i, string query)
		{
			Init(i, query);
		}

		// Explicit XML
//		Xml(string xml)
//		{
//		}

		//-------------------------------------------------------------------------------------
		// Attributes
		//-------------------------------------------------------------------------------------
		
		public string xml
		{
			get { return OuterXml; }
		}

		public string OuterXml
		{
			get { return _nav.OuterXml; }
		}

		public string InnerXml
		{
			get { return _nav.InnerXml; }
		}

		//-------------------------------------------------------------------------------------
		// Queries
		//-------------------------------------------------------------------------------------
		
		public Xml xpath(string query)
		{
			return new Xml(_nav.Select(query), query);
		}

		public Xml bytype(string type)
		{
			return xpath(type);
		}

		public Xml byattr(string path, string attr, string value)
		{
			return xpath(path + "[@" + attr + "='" + value + "']");
		}

		public Xml byname(string path, string name)
		{
			return byattr(path, "name", name);
		}

		public Xml byid(string path, string id)
		{
			return byattr(path, "id", id);
		}

		//-------------------------------------------------------------------------------------
		// Enumeration
		//-------------------------------------------------------------------------------------

		public static bool operator!(Xml xml)
		{
			return xml._i.Count == 0;
		}

		public IEnumerator<Xml> GetEnumerator()
		{
			XPathNodeIterator i = _i.Clone();
			do 
			{
				yield return new Xml(i, "[]");
			}
			while (i.MoveNext());
		}

    	public string this[string attr]
    	{
    		get
    		{
    			return _nav.GetAttribute(attr, "");
    		}
    		
    		set
    		{
    			var nav = _nav.Clone();
    			nav.MoveToAttribute(attr, "");
    			nav.SetValue(value);
    		}
    	}

 		//-------------------------------------------------------------------------------------
 		// Diagnostics
		//-------------------------------------------------------------------------------------

		// public XPathNodeIterator iterator { get { return _i; } }
	
	}

	//-----------------------------------------------------------------------------------------

	public class XmlFile : Xml
	{
		XPathDocument _doc;
		
		public XmlFile(string fname)
		{
			_doc = new XPathDocument(fname);
			base.Init(_doc.CreateNavigator().Select("/"));
		}
	}
}

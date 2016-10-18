package com.videoswipe.model.vo 
{
	/**
	 * ...
	 * @author 
	 */
	public class AbstractAtomVO 
	{
		private var _xml:XML;
		protected var ATOM:Namespace;
		/*
		*/

		public function AbstractAtomVO( x:XML = null) 
		{
			_xml = returnValidXML(x);
			ATOM = xml.namespace();
			 //= new Namespace("http://www.w3.org/2005/Atom");
		}
		
		public function get xml():XML
		{
			return _xml;
		}
		public function get xmlString():String
		{
			return _xml.toString();
		}
		public function get id():String {
			return String(xml.ATOM::id);
		}
		public function get name():String {
			return (String(xml.localName() != "")) ? String(xml.localName()) : "no name for this element";
		}
		public function get title():String
		{
			return String(xml.ATOM::title);
		}
		public function get category():String
		{
			return String(xml.ATOM::category.@label);
		}
		protected function returnValidXML(x:XML):XML
		{
			if (x == null) x = <xml />;
			return x;
		}
	}

}
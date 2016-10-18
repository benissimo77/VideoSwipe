package com.videoswipe.model.vo 
{
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author 
	 */
	public class GraphRequestVO 
	{
		private var graphURL:String = "https://graph.facebook.com";
		private var _objectID:String = "";	// facebook ID we are interested in (usually the current user)
		private var _connection:String = "";	// set if we want to retrieve a connection for this object
		private var _access_token:String = "";	// the access token for this user (allows us to retrieve private data)

		//private var _fullRequest:URLRequest;	// the completed request object ready to be sent
		
		public function GraphRequestVO() 
		{ }
		
		public function get objectID():String 
		{
			return _objectID;
		}
		public function set objectID(value:String):void 
		{
			_objectID = value;
		}
		public function get access_token():String 
		{
			return _access_token;
		}
		public function set access_token(value:String):void 
		{
			_access_token = value;
		}
		
		
		public function get connection():String 
		{
			return _connection;
		}
		public function set connection(value:String):void 
		{
			_connection = value;
		}
		
		private function fullURL():String
		{
			var _fullURL:String = graphURL + "/" + objectID;
			if (connection.length > 0) _fullURL += "/" + connection;
			return _fullURL;
		}
		public function get fullRequest():URLRequest 
		{
			var _fullRequest:URLRequest = new URLRequest();
			var _variables:URLVariables = new URLVariables();
			_fullRequest.url = fullURL();
			_variables.access_token = access_token;
			_variables.data = 1;
			_fullRequest.data = _variables;
			return _fullRequest;
		}
		
	}

}
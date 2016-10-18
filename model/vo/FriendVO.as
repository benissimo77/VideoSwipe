package com.videoswipe.model.vo
{
	/**
	 * ...
	 * @author 
	 */
	public class FriendVO 
	{
		public static const FRIEND:uint = 0;
		public static const LIST:uint = 1;
		public static const ADDLISTBUTTON:uint = 2;
		
		public var type:uint;	// one of above enums
		public var open:Boolean;	// for LISTS holds whether the list is open or closed
		public var name:String;
		public var uid:String;		// facebook user id (can be a list of ids if type is LIST
		private var id:String;		// currently not used
		public var connected:Boolean;	// maintains online status of this friend (Facebook online_presence field 'active' or 'idle')
		public var live:Boolean;		// is this user LIVE on VideoSwipe?
		
		public function FriendVO(_f:Object=null) 
		{
			type = FRIEND;	// default to FRIEND (below fn will overwrite if necessary)
			open = false;	// default to LIST closed
			connected = false;	// default to OFFLINE (server updates on connection and disconnection)
			live = false;		// default to NOT LIVE
			if (_f) fillFromObject(_f);
		}
		
		private function fillFromObject(_o:Object):void
		{
			name = _o.name;
			if (_o.id) uid = _o.id;
			if (_o.uid) uid = _o.uid;
			if (_o.type) type = _o.type;
		}
		
		
	}

}
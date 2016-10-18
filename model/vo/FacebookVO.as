package com.videoswipe.model.vo 
{
	public class FacebookVO 
	{
		private var _connected:Boolean;
		private var _uid:String;
		private var _name:String;
		private var _username:String;
		private var _picture:String;	// URL of the user profile pic
		private var _cover:Object;
		private var _gender:String;
		private var _locale:String;
		private var _timezone:int;
		private var _age_range:int;
		private var _installed:Boolean;
		private var _devices:String;
		private var _email:String;
		private var _friends:FriendlistVO;
		private var _friendlists:Array;

		public function FacebookVO(result:Object = null)
		{
			_connected = false;
			_uid = "";
			_name = "";
			_username = "";
			_picture = "";
			_cover = null;
			_gender = "";
			_locale = "";
			_timezone = 0;
			_age_range = 21;
			_installed = true;
			_devices = "";
			_email = "";
			_friends = new FriendlistVO();
			_friendlists = [];
			if (result) {
				if (result.id) _uid = result.id;
				if (result.name) _name = result.name;
				if (result.username) _username = result.username;
				if (result.picture) _picture = result.picture.data.url;
				if (result.cover) _cover = result.cover;
				if (result.gender) _gender = result.gender;
				if (result.locale) _locale = result.locale;
				if (result.timezone) _timezone = result.timezone;
				if (result.age_range) _age_range = result.age_range.min;
				if (result.installed) _installed = result.installed;
				if (result.devices) _devices = result.devices;
				if (result.email) _email = result.email;
				if (result.friends) {
					_friends = new FriendlistVO(result.friends.data as Array, "All Friends");
					_friendlists["All Friends"] = _friends;
				}
			}
		}

		// updateOnlineStatus
		// when users change from offline/online, connect/disconnect to VideoSwipe
		// we maintain their online status. Update in all the friendlists at same time.
		public function updateOnlineStatus( _updateList:Array ):void
		{
			for (var i:String in _friendlists) {
				var _f:FriendlistVO = _friendlists[i] as FriendlistVO;
				_f.updateOnlineStatus(_updateList);
			}
		}
		public function get friendlists():Array 
		{
			return _friendlists;
		}
		
		public function set friendlists(value:Array):void 
		{
			_friendlists = value;
		}
		
		public function get name():String 
		{
			return _name;
		}
		
		public function set name(value:String):void 
		{
			_name = value;
		}
		
		public function get uid():String 
		{
			return _uid;
		}
		
		public function set uid(value:String):void 
		{
			_uid = value;
		}
		
		public function get connected():Boolean 
		{
			return _connected;
		}
		
		public function set connected(value:Boolean):void 
		{
			_connected = value;
		}
		
		public function get friends():FriendlistVO
		{
			return _friends;
		}
		
		public function get cover():Object 
		{
			return _cover;
		}
		
		public function set cover(value:Object):void 
		{
			_cover = value;
		}
		
		public function get picture():String
		{
			return _picture;
		}
		
		public function set picture(value:String):void 
		{
			_picture = value;
		}
		
		public function get username():String 
		{
			return _username;
		}
		
		public function set username(value:String):void 
		{
			_username = value;
		}
		
		public function get gender():String 
		{
			return _gender;
		}
		
		public function set gender(value:String):void 
		{
			_gender = value;
		}
		
		public function get locale():String 
		{
			return _locale;
		}
		
		public function set locale(value:String):void 
		{
			_locale = value;
		}
		
		public function get installed():Boolean 
		{
			return _installed;
		}
		
		public function set installed(value:Boolean):void 
		{
			_installed = value;
		}
		
		public function get devices():String 
		{
			return _devices;
		}
		
		public function set devices(value:String):void 
		{
			_devices = value;
		}
		
		public function get email():String 
		{
			return _email;
		}
		
		public function set email(value:String):void 
		{
			_email = value;
		}
		
		public function get age_range():int 
		{
			return _age_range;
		}
		
		public function set age_range(value:int):void 
		{
			_age_range = value;
		}
		
		public function get timezone():int 
		{
			return _timezone;
		}
		
		public function set timezone(value:int):void 
		{
			_timezone = value;
		}
		
		
		
	}

}
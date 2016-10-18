package com.videoswipe.model.vo
{
	/**
	 * ...
	 * @author 
	 */
	public class FriendlistVO 
	{
		private var _name:String;	// name of this friendlist
		private var _list:Vector.<FriendVO>;
		
		public function FriendlistVO(_f:Object = null, _n:String = "") 
		{
			_list = new Vector.<FriendVO>;
			_name = _n;
			if (_f) createFriendlist(_f as Array);
		}
		
		public function updateOnlineStatus( _updateList:Array ):void
		{
			for (var i:int = _updateList.length; i--; ) {
				for (var j:int = _list.length; j--; ) {
					if (_list[j].uid == _updateList[i].uid) {
						// found a friend that needs to be updated
						if (_updateList[i].online_presence) {
							_list[j].connected = _updateList[i].online_presence == "active" || _updateList[i].online_presence == "idle";
						}
						if (_updateList[i].live != null) {
							_list[j].live = _updateList[i].live;
						}
						break;
					}
				}
			}
		}

		private function createFriendlist(_l:Array):void
		{
			var _f:FriendVO;
			_l.sortOn( "name" );
			for (var i:uint = _l.length; i--; ) {
				_f = new FriendVO( _l[i] );
				_list.unshift( _f );
			}
		}
		
		public function get length():int
		{
			return _list.length;
		}
		
		public function get friends():Vector.<FriendVO> 
		{
			return _list;
		}
		public function get liveFriends():Vector.<FriendVO>
		{
			var _o:Vector.<FriendVO> = new Vector.<FriendVO>;
			for (var i:int = length; i--; ) {
				if (_list[i].live) {
					_o.unshift( _list[i] );
				}
			}
			return _o;
		}
		public function get connectedFriends():Vector.<FriendVO>
		{
			var _o:Vector.<FriendVO> = new Vector.<FriendVO>;
			for (var i:int = length; i--; ) {
				if (_list[i].connected) {
					_o.unshift( _list[i] );
				}
			}
			return _o;
		}
		public function get offlineFriends():Vector.<FriendVO>
		{
			var _o:Vector.<FriendVO> = new Vector.<FriendVO>;
			for (var i:int = length; i--; ) {
				if (_list[i].live || _list[i].connected) {
					// do nothing
				} else {
					_o.unshift( _list[i] );
				}
			}
			return _o;
		}
		
	}

}
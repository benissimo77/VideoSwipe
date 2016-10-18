package com.videoswipe.view.component
{
	import com.videoswipe.model.vo.FriendlistVO;
	import com.videoswipe.model.vo.FriendVO;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * (c) Ben Silburn 2013
	 */
	public class FriendList extends Sprite
	{
		private var _friendlistVO:FriendlistVO;	// the array of friends (uid, name)
		private var _list:Sprite;			// sprite holds the list of friendView objects
		private var _listTitle:FriendView;	// holds the title panel of this friend list
		private var _UIDList:String;		// list of UIDs of the friends in this list (needed for Facebook calls)
		
		public function FriendList(_name:String="Friends", _list:FriendlistVO = null)
		{
			this.name = _name;
			initView();
			if (_list) listVO = _list;
		}
		
		private function initView():void
		{
			trace("FriendList:: initView:" );
			_list = new Sprite();
			addChild(_list);
		}
		
		private function drawView():void
		{
			while (_list.numChildren > 0) _list.removeChildAt(0);
			var _friendVO:FriendVO;
			_UIDList = "";
			for (var i:int = _friendlistVO.length; i--; ) {
				_friendVO = _friendlistVO.friends[i];
				var friendView:FriendView = new FriendView(_friendVO);
				//friendView.name = _friendVO.name;
				_list.addChildAt(friendView, 0);
				friendView.y = i * FriendView.HEIGHT;
				_UIDList = _UIDList.concat(",", _friendVO.uid);	// Facebook only allows to send to 50 users at once so BEWARE!
			}
			_friendVO = new FriendVO();
			_friendVO.type = FriendVO.LIST;
			_friendVO.uid = _UIDList.substr(1);
			_friendVO.name = this.name;
			_listTitle = new FriendView(_friendVO);
			addChild(_listTitle);
			_list.y = _listTitle.height;	// placed down to make way for the title
			trace("FriendList:: drawView: UIDList:", _friendVO.uid );
			closeFriendlist();	// start with friendlist closed
		}

		public function toggleFriendlist():void
		{
			if (_listTitle.open) {
				closeFriendlist();
			} else {
				openFriendlist();
			}
		}
		
		private function reorderFriendViews():void
		{
			for (var i:int = _list.numChildren; i--; ) {
				_list.getChildAt(i).y = i * FriendView.HEIGHT;
			}
		}
		// friendsOnlineStatus
		// called when a friend goes either online or offline
		// only complex thing is that we want to re-order the display so that online friends are shown at the top
		public function friendsOnlineStatus(result:FriendlistVO):void
		{
			trace("FriendList:: friendsOnlineStatus:");
			
			// since all the info is in the friendlistVO we simply loop through in the order we want the friends displayed
			// find the relevant friendView for each one and bring it to the top of the display list, then re-order
			
			// first offline friends
			if (result) {
				updateOnlineStatus( result.offlineFriends );
				updateOnlineStatus( result.connectedFriends );
				updateOnlineStatus( result.liveFriends );
			}

			// finally adjust the y positions based on the display stack
			reorderFriendViews();
		}
		
		private function updateOnlineStatus( _o:Vector.<FriendVO> ):void
		{
			var _f:FriendView;
			for (var i:int = _o.length; i--; ) {
				for (var j:uint = _list.numChildren; j--; ) {
					_f = _list.getChildAt(j) as FriendView;
					if (_f.uid == _o[i].uid) {
						_list.addChildAt( _f, 0);
						_f.setOnlineStatus( _o[i] );
						break;
					}
				}
			}
		}

		private function setAllFriendsOffline():void
		{
			for (var i:uint = _list.numChildren; i--; ) {
				var _f:FriendView = _list.getChildAt(i) as FriendView;
				//_f.connected = false;
			}
		}

		private function openFriendlist():void
		{
			_listTitle.open = true;
			addChild(_list);
		}
		private function closeFriendlist():void
		{
			_listTitle.open = false;
			if (this.contains(_list)) removeChild(_list);
		}
		// GETTER/SETTERS
		public function set listVO(_l:FriendlistVO):void
		{
			// we need to order the list as it arrives from FB
			// NOTE: we first receive this list without any connected status set - this happens only after visiting FMS
			// so just sort on name, then later we'll receive the friends' online statuses
			//_listVO = _l.sortOn("name");
			_friendlistVO = _l;
			drawView();
		}
	}

}
package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.model.vo.FriendlistVO;
	import com.videoswipe.model.vo.FriendVO;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	/**
	 * ...
	 * @author 
	 */
	public class FriendPanel extends ScrollableSprite
	{
		private var _friendPanel:Sprite;	// holds the lists
		private var _addListButton:FriendView;
		private var _cursor:FriendCursor;
		private var _scrolling:Boolean;	// flag holds if this panel is scrolling (can disable cursor until finished)
		
		public function FriendPanel() 
		{
			initView();
		}

		private function initView():void
		{
			_friendPanel = new Sprite();
			addChild(_friendPanel);

			_addListButton = new FriendView( new FriendVO( { type:FriendVO.ADDLISTBUTTON, uid:"", name:"Add Friend Lists" } ));
			_addListButton.name = "AddFriendLists";
			_addListButton.buttonMode = true;
			_addListButton.useHandCursor = true;
			
			_friendPanel.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			_friendPanel.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			_friendPanel.addEventListener(MouseEvent.CLICK, cursorClicked);

			_cursor = new FriendCursor();
			//_cursor.addEventListener(MouseEvent.CLICK, cursorClicked);
			//_cursor.addEventListener(MouseEvent.ROLL_OUT, mouseOut);
		}

		/*
		public function setAllFriendsOffline():void
		{
			for (var i:int = _friendPanel.numChildren; i--;) {
				var _f:FriendList = _friendPanel.getChildAt(i) as FriendList;
				_f.setAllFriendsOffline();
			}
			if (this.contains(_cursor)) removeChild(_cursor);
		}
		*/
		public function onFriends(_friends:FriendlistVO):void
		{
			var _friendList:FriendList;
			if (_friendPanel.getChildByName("All Friends")) {
				_friendList = _friendPanel.getChildByName("All Friends") as FriendList;
				//_friendList.listVO = result as Array;
			} else {
				_friendList = new FriendList("All Friends", _friends);
				_friendPanel.addChild(_friendList);
				_friendList.toggleFriendlist();	// friendlists usually start closed, start this one open
			}
			layoutFriendlists();
		}
		public function onFriendlists(result:Object):void
		{
			if (result.length == 0) {
				this.addChild( _addListButton );
				_friendPanel.y = _addListButton.height;
			} else {
				// remove above 'add friendlists' button if its there
				if (this.contains(_addListButton)) this.removeChild(_addListButton);
				_friendPanel.y = 0;

				// loop through result array adding a friendlist for each element
				// NOTE: its possible that the friendlist can have NO MEMBERS in which case don't add it
				var _friendList:FriendList;
				for (var i:int = result.length; i--; ) {
					trace("Main:: onFriendlists:", result[i].name );
					if (result[i].members && result[i].members.data) {
						// don't add it we already have it
						if (_friendPanel.getChildByName(result[i].name)) {
							//_friendList = _friendPanel.getChildByName(result[i].name) as FriendList;
						} else {
							_friendList = new FriendList(result[i].name, result[i].members.data as FriendlistVO);
							_friendPanel.addChildAt(_friendList, 0);
						}
					}
				}
			}
			layoutFriendlists();
		}
		public function friendsOnlineStatus(result:Array):void
		{
			// result holds an object in format returned by FQL query to retrieve friends online_presence
			// array of objects, uid and online_presence (string) one of 'active', 'idle', 'offline', 'error'
			// we interpret 'active' and 'idle' to be online, others to be offline
			var _friendList:FriendList;
			for (var j:int = _friendPanel.numChildren; j--; ) {
				trace("FriendPanel:: friendsOnlineStatus: friendlist", j, _friendPanel.getChildAt(j).name );
				_friendList = _friendPanel.getChildAt(j) as FriendList;
				_friendList.friendsOnlineStatus( result[_friendList.name] as FriendlistVO );
			}
			trace("FriendPanel:: friendsOnlineStatus: DONE"  );
		}
		private function layoutFriendlists(e:Event = null):void
		{
			if (_friendPanel.numChildren > 0) {
				_friendPanel.getChildAt(0).y = 0;
			}
			// we now loop through all the children of the friendPanel setting their y coordinates
			for (var i:int = 1; i < _friendPanel.numChildren; i++) {
				// only set coordinate if this child is NOT the cursor (must remain where it is)
				if (_friendPanel.getChildAt(i).name != "cursor") {
					_friendPanel.getChildAt(i).y = _friendPanel.getChildAt(i - 1).y + _friendPanel.getChildAt(i - 1).height;
				}
			}
			// draw an entire graphic background to prevent rogue mouseOut events
			this.graphics.clear();
			this.graphics.beginFill(0x000, 0);
			//this.graphics.drawRect(0, 0, FriendView.WIDTH, _friendPanel.y + _friendPanel.getChildAt(i - 1).y + _friendPanel.getChildAt(i - 1).height);
			this.graphics.drawRect(0, 0, this.width, this.height);
			this.graphics.endFill();
		}
		
		private function cursorClicked(e:MouseEvent = null):void
		{
			trace("FriendPanel:: cursorClicked:", e.target.name );
			
			if (_cursor.friendVO.type == FriendVO.LIST) {
				toggleFriendlist();
			}
		}
		private function toggleFriendlist():void
		{
			var _f:FriendVO = _cursor.friendVO;
			var _fl:FriendList = _friendPanel.getChildByName(_f.name) as FriendList;
			_fl.toggleFriendlist();
			_cursor.toggleSelector();
			layoutFriendlists();
		}
		private function mouseOver(e:MouseEvent=null):void
		{
			var _f:FriendView = e.target as FriendView;
			//var _p:Point = globalToLocal(_f.localToGlobal(new Point(0, 0)));
			//_cursor.x = _p.x;
			//_cursor.y = _p.y;
			_cursor.friendVO = _f.friendVO;
			_f.selected = true;
			if (_f.friendVO.type == FriendVO.FRIEND) {
				ToolTip.show("Invite " + _f.friendVO.name + " to join you");
			}
		}
		private function mouseOut(e:MouseEvent = null):void
		{
			var _f:FriendView = e.target as FriendView;
			_f.selected = false;
			ToolTip.hide();
		}
		
		public function get cursorVO():FriendVO
		{
			return _cursor.friendVO;
		}
		
		override public function set scrolling(value:Boolean):void 
		{
			_scrolling = value;
		}


	}
	

}
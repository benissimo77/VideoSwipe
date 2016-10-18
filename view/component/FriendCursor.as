package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.FriendVO;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/*
	 * (c) Ben Silburn 2013
	 */
	
	public class FriendCursor extends Sprite
	{
		[Embed (source = "assets/fb_requestIcon.png")]
		private static var RequestIcon:Class;
		[Embed (source = "assets/fb_requestIconOver.png")]
		private static var RequestIconOver:Class;
		[Embed (source = "assets/fb_sendIcon.png")]
		private static var SendIcon:Class;
		[Embed (source = "assets/fb_sendIconOver.png")]
		private static var SendIconOver:Class;
		[Embed (source = "assets/fb_inviteIcon.png")]
		private static var InviteIcon:Class;
		[Embed (source = "assets/fb_inviteIconOver.png")]
		private static var InviteIconOver:Class;
		
		private var _friendVO:FriendVO;		// the friendVO that the cursor is currently acting on
		private var _selector:Shape;		// icon for the dropdown selector (friendlist title)
		private var _requestIcon:Sprite;	// icon for sending friend an invitation request
		private var _sendIcon:Sprite;		// icon for sending friend a message
		private var _inviteIcon:Sprite;		// icon for inviting friend to join in room
		
		
		public function FriendCursor() 
		{
			this.name = "cursor";
			initView();
		}

		/*
		 * Initialises the basic (empty) cursor that will be used to present the content
		 */
		private function initView():void
		{
			graphics.clear();
			graphics.lineStyle(2, 0x0000ff, 1);
			graphics.beginFill(0xbbbbee, 0);
			graphics.drawRect( 0,0, FriendView.WIDTH, FriendView.HEIGHT );
			graphics.endFill();

			_selector = new Shape();
			_selector.graphics.clear();
			_selector.graphics.beginFill(0, 0);
			_selector.graphics.drawCircle(0, 0, 6);
			_selector.graphics.endFill();
			_selector.graphics.beginFill(0x0000ff, 1);
			_selector.graphics.moveTo(-3, -4);
			_selector.graphics.lineTo(5, 0);
			_selector.graphics.lineTo(-3, 4);
			_selector.graphics.endFill();
			_selector.x = 15;	// centre sprite around its registration point so it can be rotated on the spot
			_selector.y = 15;

			_inviteIcon = new Sprite();
			_inviteIcon.name = "invite";
			_inviteIcon.addChild(new InviteIcon());
			_inviteIcon.addChild(new InviteIconOver());
			_inviteIcon.x = FriendView.WIDTH - 28;
			_inviteIcon.y = (FriendView.HEIGHT - _inviteIcon.height) / 2;
			_inviteIcon.getChildAt(1).visible = false;
			_inviteIcon.mouseChildren = false;
			_requestIcon = new Sprite();
			_requestIcon.name = "request";
			_requestIcon.addChild(new RequestIcon());
			_requestIcon.addChild(new RequestIconOver());
			_requestIcon.getChildAt(1).visible = false;
			_requestIcon.x = FriendView.WIDTH - 52;
			_requestIcon.y = (FriendView.HEIGHT - _requestIcon.height) / 2;
			_requestIcon.mouseChildren = false;
			_sendIcon = new Sprite();
			_sendIcon.name = "send";
			_sendIcon.addChild(new SendIcon());
			_sendIcon.addChild(new SendIconOver());
			_sendIcon.x = FriendView.WIDTH - 76;
			_sendIcon.y = (FriendView.HEIGHT - _sendIcon.height) / 2;
			_sendIcon.getChildAt(1).visible = false;
			_sendIcon.mouseChildren = false;
			//this.addEventListener(MouseEvent.MOUSE_OVER, iconMouseOver);
			//this.addEventListener(MouseEvent.MOUSE_OUT, iconMouseOut);
		}

		private function drawView():void
		{
			// remove icons to initialise
			while (numChildren > 0) removeChildAt(0);
			
			switch (_friendVO.type) {
				
				case FriendVO.ADDLISTBUTTON:
					// nothing needed here
					break;
				
				case FriendVO.FRIEND:
					//addChild(_requestIcon);
					//addChild(_sendIcon);
					//addChild(_inviteIcon);
					break;
					
				case FriendVO.LIST:
					addChild(_selector);
					_selector.rotation = _friendVO.open ? 90 : 0;
					//addChild(_inviteIcon);
					break;
			}
		}
		
		// toggleSelector
		// function is called by the parent which catches the mouse click on the cursor
		public function toggleSelector():void
		{
			if (_selector.rotation == 0) {
				_selector.rotation = 90;
			} else {
				_selector.rotation = 0;
			}
		}
		
		private function iconMouseOver(e:MouseEvent = null):void
		{
			//trace("FriendCursor:: iconMouseOver:", e.target.name );
			var _icon:Sprite = e.target as Sprite;
			
			if (_icon.name == "request" || _icon.name == "send" || _icon.name == "invite") {

				_icon.getChildAt(1).visible = true;
				
				switch (_icon.name) {

					case "request":
						ToolTip.show("Send notification to " + toolTipFriend());
						break;
					case "send":
						ToolTip.show("Send message to " + toolTipFriend());
						break;
					case "invite":
						ToolTip.show("Invite " + toolTipFriend() + " to join you NOW!");
						break;

					default:
						break;
				}
			}
		}
		private function iconMouseOut(e:MouseEvent = null):void
		{
			//trace("FriendCursor:: iconMouseOut:", e.target.name );
			var _icon:Sprite = e.target as Sprite;
			if (_icon.name == "request" || _icon.name == "send" || _icon.name == "invite") {
				_icon.getChildAt(1).visible = false;
				ToolTip.hide();
			}
		}
		
		// toolTipFriend
		// returns a string to be used in the ToolTip
		private function toolTipFriend():String
		{
			if (_friendVO.type == FriendVO.LIST) return _friendVO.name;
			return _friendVO.name.split(" ")[0];
		}
		// PUBLIC GETTER/SETTERS
		public function set friendVO(_f:FriendVO):void
		{
			_friendVO = _f;
			drawView();
		}
		public function get friendVO():FriendVO 
		{
			return _friendVO;
		}
		
	}
}
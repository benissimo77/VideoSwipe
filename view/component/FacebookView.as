package com.videoswipe.view.component 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.FacebookVO;
	import com.videoswipe.model.vo.FriendVO;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;

	/**
	 * ...
	 * @author 
	 */
	public class FacebookView extends GlassSprite
	{
		private var _facebookVO:FacebookVO;
		private var _cover:Loader;
		private var _coverMask:Sprite;
		private var _userimage:Loader;
		private var _connect:ConnectPanel;
		private var _username:TFTextField;
		private var _connectionLight:ConnectionLight;
		private var _connectionURL:TFTextField;
		private var _copyLink:FacebookButton;
		private var _inviteText:TFTextField;
		private var _inviteButton:FacebookButton;
		private var _friendPanel:FriendPanel;	// holds/organises the list of friends (and friendlists)
		private var _scroll:Scroller;	// handles scrolling of the friendPanel

		public function FacebookView(_f:FacebookVO = null) 
		{
			trace("FacebookView:: FacebookView: hello");
			initView();
			_facebookVO = new FacebookVO();
			connected = false;	// start with display representing NOT connected
			if (_f) facebookVO = _f;	// will draw view
		}
		
		private function initView():void
		{
			// COVER PIC
			_cover = new Loader();
			addChild(_cover);
			// COVER MASK (FOR PIC)
			_coverMask = new Sprite();
			addChild(_coverMask);
			_cover.mask = _coverMask;
			// USER IMAGE - we can fix this position as it is constant
			_userimage = new Loader();
			_userimage.x = 8;
			_userimage.y = 40;
			addChild(_userimage);
			// USERNAME TEXT - also fixed position (relative to userimage)
			_username = new TFTextField("facebook");
			_username.colour = Theme.TEXTSTANDARD;
			_username.selectable = false;
			_username.x = 62;
			_username.y = 72;
			addChild(_username);
			// LINK LABEL - below username
			var _sendLink:TFTextField = new TFTextField();
			_sendLink.colour = Theme.TEXTHIGHLIGHT;
			_sendLink.text = "Copy-Paste this link to friends:";
			_sendLink.small = true;
			_sendLink.bold = true;
			_sendLink.x = 2;
			_sendLink.y = 98;
			addChild(_sendLink);
			// CONNECTION URL - fixed below the username
			_connectionURL = new TFTextField();
			_connectionURL.autoSize = TextFieldAutoSize.NONE;
			_connectionURL.multiline = false;
			_connectionURL.small = true;
			_connectionURL.x = 4;
			_connectionURL.y = 114;
			_connectionURL.height = 20;	// width will get set by the redraw
			_connectionURL.border = true;
			_connectionURL.borderColor = Theme.EDGETINT;
			_connectionURL.colour = Theme.TEXTSTANDARD;
			addChild(_connectionURL);
			// COPY LINK BUTTON - fixed to right of connectionURL
			_copyLink = new FacebookButton("facebook", "Copy", 52, 20, false);
			_copyLink.name = "copy";
			_copyLink.y = _connectionURL.y;	// x will get set by the redraw
			addChild(_copyLink);
			// INVITE BUTTON - just below the URL box
			_inviteText = new TFTextField();
			_inviteText.colour = Theme.TEXTHIGHLIGHT;
			_inviteText.text = "OR click to invite through Facebook:";
			_inviteText.small = true;
			_inviteText.bold = true;
			_inviteText.x = 2;
			_inviteText.y = 136;
			addChild(_inviteText);
			_inviteButton = new FacebookButton("facebook", "Invite", 52, 20, false);
			_inviteButton.name = "invite";
			_inviteButton.y = _inviteText.y;
			addChild(_inviteButton);
			// CONNECT PANEL
			_connect = new ConnectPanel();
			addChild(_connect);
			// CONNECTION LIGHT
			_connectionLight = new ConnectionLight();
			_connectionLight.width = 20;
			_connectionLight.height = 20;
			//addChild(_connectionLight);
			_friendPanel = new FriendPanel();
			_scroll = new Scroller();
			_scroll.x = 2;
			_scroll.y = 160;
			_scroll.scrollTarget = _friendPanel;
			addChild(_scroll);
			
			// initial state is glass background visible
			showGlass();
		}

		private function drawView():void
		{
			username = _facebookVO.name;
			userimage = _facebookVO.picture;	// uses setter fn
			if (_facebookVO.cover) {
				cover = _facebookVO.cover.source;	// uses setter fn
			}
			if (_facebookVO.friends && _facebookVO.friends.length > 0) {
				_friendPanel.onFriends(_facebookVO.friends);
			}

			_scroll.update();
			//userimage = _f.picture;
			//cover = _f.cover;
			//onFriends(_f.friends);
		}
		public function update():void
		{
			_scroll.update();
		}
		public function textCopied():void
		{
			_copyLink.label = "Copied";
		}
		/*
		public function onFriends(result:Object):void
		{
			_friendPanel.onFriends(result);
			_scroll.update();
		}
		*/
		public function onFriendlists(result:Object):void
		{
			_friendPanel.onFriendlists(result);
			_scroll.update();
		}
		public function friendsOnlineStatus(result:Object):void
		{
			_friendPanel.friendsOnlineStatus(_facebookVO.friendlists);
		}
		private function imageLoaded(e:Event):void
		{
			_userimage.contentLoaderInfo.removeEventListener( Event.COMPLETE, imageLoaded );
			_userimage.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, IOErrorHandler );
			_userimage.width = 50;
			_userimage.height = 50;
		}
		private function IOErrorHandler(e:IOErrorEvent):void
		{
			trace("FacebookView:: IOErrorHandler:" );
		}
		private function coverLoaded(e:Event):void
		{
			_cover.contentLoaderInfo.removeEventListener( Event.COMPLETE, coverLoaded );
			_cover.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, IOErrorHandler );
			scaleAndPositionCover();
		}
		
		// scaleAndPositionCover
		// fairly complex calculation here
		// offset_y is a percentage of the total cover height that it should be adjusted by
		// more complex because cover image is also being scaled, so need to use the original cover height to determine offset
		// 315/850 is based on the fixed size of a facebook cover image (850x315)
		private function scaleAndPositionCover():void
		{
			var scale:Number = _width / _cover.width;
			_cover.scaleX = scale;
			_cover.scaleY = scale;
			_cover.y = (_cover.height - _width*315/850) * _facebookVO.cover.offset_y * 0.01 * -1;
		}
		override public function redraw():void
		{
			super.redraw();	
			//trace("FacebookView:: redraw:", _width, _height );
			// need to set the cover mask to the width (we fix the height at 64 pixels just to make it slightly less tall than it is on facebook)
			_coverMask.graphics.clear();
			_coverMask.graphics.beginFill(0x000, 1);
			_coverMask.graphics.drawRect(2, 2, _width-4, 64);
			_coverMask.graphics.endFill();
			_copyLink.x = _width - 56;
			_inviteButton.x = _width - 56;
			_connectionURL.width = _width - 64;
			_scroll.setSize(_width - 4, _height - _scroll.y - 2);
			_connect.setSize(_width, _height);
		}

		// PUBLIC GETTER/SETTERS
		
		// userinfo
		// accepts a JSON object (as returned by the Facebook API call "/me")
		// sets all view component objects based on the userinfo
		public function set userinfo(_f:FacebookVO):void
		{
			facebookVO = _f;
		}
		private function set username(u:String):void
		{
			_username.text = u;
		}
		private function set userimage(i:String):void
		{
			_userimage.contentLoaderInfo.addEventListener( Event.COMPLETE, imageLoaded);
			_userimage.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, IOErrorHandler );
			_userimage.load( new URLRequest(i) );
		}
		private function set cover(c:String):void
		{
			_cover.contentLoaderInfo.addEventListener( Event.COMPLETE, coverLoaded );
			_cover.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, IOErrorHandler );
			_cover.load( new URLRequest(c));
		}
		public function set connectionURL(u:String):void
		{
			_connect.linktext = u;
			_connectionURL.text = u;
			_copyLink.label = "Copy";
		}
		public function get connectionURL():String
		{
			return _connectionURL.text;
		}
		
		public function get connected():Boolean
		{
			return _facebookVO.connected;
		}
		public function set connected(_b:Boolean):void
		{
			_facebookVO.connected = _b;
			if (_b) {
				_connect.visible = false;
				_inviteText.visible = true;
				_inviteButton.visible = true;
				_friendPanel.visible = true;
			} else {
				//_friendPanel.setAllFriendsOffline();
				_inviteButton.visible = false;
				_inviteText.visible = false;
				_friendPanel.visible = false;
				_connect.linktext = "";
				_connectionURL.text = "";
				_connect.visible = true;
			}
		}
		
		public function set facebookVO(_f:FacebookVO):void
		{
			_facebookVO = _f;
			connected = _f.connected;	// updates display
			drawView();
		}
		public function get cursorVO():FriendVO
		{
			return _friendPanel.cursorVO;
		}

	}

}
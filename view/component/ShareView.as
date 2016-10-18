package com.videoswipe.view.component 
{
	import com.videoswipe.model.vo.PlaylistVO;
	import fl.controls.RadioButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import myLib.controls.Button;
	import myLib.controls.Label;
	import myLib.controls.TextArea;
	/**
	 * ShareView
	 * (c) Ben Silburn
	 * 
	 * Presents a dialog box to allow the current playing video or playlist to be posted to the user's feed
	 * NOTE: Using the Adobe controls in this class as the myLib RadioButtons don't appear to work...
	 */
	public class ShareView extends GlassSprite
	{
		private var statusText:Label;
		private var currentlyPlayingRB:RadioButton;
		private var playlistRB:RadioButton;
		private var messageText:Label;
		private var messageInput:TextArea;
		private var cancelButton:Button;
		private var submitButton:Button;

		private var currentlyPlayingItemView:PlaylistItemView;	// currently playing video item
		private var playlistView:Sprite;	// holds the playlist item views for the current playlist
		
		private var _playlistVO:PlaylistVO;	// the playlistVO to be shared (includes info for the currently playing video)
		
		public function ShareView( _p:PlaylistVO = null) 
		{
			trace("ShareView:: ShareView: hello");
			super();
			initView();
			if (_p) playlistVO = _p;	// calls setter function
		}
		
		override public function redraw():void
		{
			//trace("ShareView:: redraw:", _width, _height );
			statusText.x = 8;
			statusText.y = 8;
			statusText.width = _width - 16;
			
			currentlyPlayingRB.move(8, 24);
			currentlyPlayingItemView.x = 148;
			currentlyPlayingItemView.y = 24;
			
			playlistRB.move(8, 80);
			playlistView.x = 148;
			playlistView.y = 80;
			
			messageText.x = 8;
			messageText.y = 120;
			messageText.width = _width - 16;
			
			messageInput.x = 8;
			messageInput.y = 138;
			messageInput.setSize(_width - 16, 64);
			
			cancelButton.x = 8;
			cancelButton.y = 212;
			submitButton.x = _width - submitButton.width - 8;
			submitButton.y = 212;
		}
		
		private function initView():void
		{
			// line below doesn't work :(
			//StyleManager.getInstance().setClassStyle( RadioButtonTextField, { textFormat: new TextFormat("Verdana", 14) } );

			statusText = new Label();
			statusText.textField.defaultTextFormat = new TextFormat("Verdana", 14);
			addChild(statusText);
	
			currentlyPlayingRB = new RadioButton();
			currentlyPlayingRB.label = "Currently playing item";
			currentlyPlayingRB.setSize(140, 32);
			addChild(currentlyPlayingRB);

			playlistRB = new RadioButton();
			playlistRB.label = "Current playlist";
			playlistRB.setSize(140, 32);
			playlistRB.selected = true;
			addChild(playlistRB);

			messageText = new Label();
			messageText.textField.defaultTextFormat = new TextFormat("Verdana", 14);
			messageText.text = "Add an optional personal message";
			addChild(messageText);
			
			messageInput = new TextArea();
			addChild(messageInput);
			
			currentlyPlayingItemView = new PlaylistItemView();
			currentlyPlayingItemView.scaleX = currentlyPlayingItemView.scaleY = 0.6;
			addChild(currentlyPlayingItemView);
			playlistView = new Sprite();
			playlistView.scaleX = playlistView.scaleY = 0.4;
			addChild(playlistView);

			cancelButton = new Button();
			cancelButton.textField.defaultTextFormat = new TextFormat("Verdana", 14);
			cancelButton.name = "cancel";
			cancelButton.text = "Cancel";
			cancelButton.addEventListener(MouseEvent.CLICK, buttonHandler);
			addChild(cancelButton);
			submitButton = new Button();
			submitButton.name = "submit";
			submitButton.text = "OK";
			addChild(submitButton);
		}

		// drawView
		// drawView is called when we have a VO object to fill out the details
		private function drawView():void
		{
			trace(JSON.stringify(_playlistVO));
			
			// clear out any old info
			while (playlistView.numChildren > 0) {
				playlistView.removeChildAt(0);
			}
			
			// make sure we have some stuff to share
			if (_playlistVO.playlistItems.length == 0) {
				statusText.text = "You have nothing to share!";
				submitButton.enabled = false;
			} else {
				statusText.text = "What would you like to share?";
				submitButton.enabled = true;
				
				var currentlyPlaying:int = _playlistVO.currentlyPlaying;
				if (currentlyPlaying >= _playlistVO.playlistItems.length) currentlyPlaying = _playlistVO.playlistItems.length - 1;
				currentlyPlayingItemView.videoItemVO = _playlistVO.playlistItems[ currentlyPlaying ];
				var item:PlaylistItemView;
				if (_playlistVO.playlistItems.length > 0) {
					item = new PlaylistItemView( _playlistVO.playlistItems[0] );
					playlistView.addChild(item);
				}
				if (_playlistVO.playlistItems.length > 1) {
					item = new PlaylistItemView( _playlistVO.playlistItems[1] );
					item.x = item.width;
					playlistView.addChild(item);
				}
				if (_playlistVO.playlistItems.length > 2) {
					item = new PlaylistItemView( _playlistVO.playlistItems[2] );
					item.x = 2 * item.width;
					playlistView.addChild(item);
				}
			}
		}
		
		private function buttonHandler(e:MouseEvent):void
		{
			trace("ShareView:: submitHandler:", e.currentTarget.name, currentlyPlayingRB.selected, playlistRB.selected );
		}
		
		// GETTER/SETTERS
		public function set playlistVO(value:PlaylistVO):void 
		{
			_playlistVO = value;
			drawView();
		}

	}

}
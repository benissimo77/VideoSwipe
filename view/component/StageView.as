package com.videoswipe.view.component 
{
	import com.greensock.TweenLite;
	import com.videoswipe.model.vo.FeedVO;
	import fl.managers.FocusManager;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	/**
	 * StageView
	 * (c) Ben Silburn 2012
	 * top-level class accepts a stage as a parameter and adds all page elements to the stage
	 * could place all this into a stageMediator class, but this approach decouples the view creation from the PureMVC apparatus
	 * in theory could hook up the entire display hierarchy to another framework and it would still function
	 *  
	 */
	public class StageView extends EventDispatcher
	{
		[Embed (source = "assets/fblogo32.png")]
		private static var FacebookIcon:Class;
		[Embed (source = "assets/ytlogo32.png")]
		private static var YoutubeIcon:Class;

		private static var YOUTUBEPANELWIDTH:int = 640;	// width of youtube panel (note: this is a var)
		private static const FACEBOOKPANELWIDTH:int = 262;	// width of facebook panel
		private static const HOTSPOTWIDTH:int = 48;			// width of panel hotpot width
		
		public var ytPlayer:YouTubeViewer;
		public var ncView:NetConnectionView;
		public var facebookPanel:FacebookView;
		public var searchView:SearchView;
		public var feedView:FeedView;
		public var channelView:ChannelSearchView;
		public var myPlaylistsView:PlaylistsView;
		public var playlistView:PlaylistView;
		public var toptensView:TopTensView;
		public var mySubscriptionsView:SubscriptionListView;
		public var controlBarView:ControlBarView;
		public var chatView:ChatView;
		public var streamsView:StreamsView;
		public var youtubePanel:GlassSprite;
		public var tabMenu:TabMenu;
		public var helpButton:FacebookButton;
		public var systemMessageView:SystemMessageView;
		public var helpSlideView:HelpSlideView;
		public var videoMessagesView:VideoMessagesView;
		
		private var fbHotspot:Sprite;
		private var ytHotspot:Sprite;
		
		public var myStage:DisplayObjectContainer;
		private var fm:FocusManager;
		private var _viewportWidth:int;
		private var _viewportHeight:int;
		private var _viewportScale:Number;
		private var youTubePanelOff:Boolean;	// start with youtube panel showing
		private var facebookPanelOff:Boolean;	// start with fb menu panel showing
		private var playlistPanelOff:Boolean;	// start with playlist panel showing
		private var playlistPanelFlash:Boolean;	// set to true if we are flashing the playlist panel
		private var tweening:Boolean;	// true if we are mid-tween of elements
		private var mouseTimer:Timer;
		private var fullScreen:Boolean;	// holds true if we are viewing youtube fullscreen
    
		public function StageView( _s:DisplayObjectContainer )
		{
			myStage = _s;
			initView();
			setSize();	// will call drawView to layout elements
		}
		public function stageGetsFocus():void
		{
			fm.setFocus(myStage);
		}
		public function goFullScreen():void
		{
			myStage.stage.displayState = StageDisplayState.FULL_SCREEN;	// resize handler will catch this later
			panelsSlide(true);
		}
		public function mouseMove(e:MouseEvent=null):void
		{
			Mouse.show();
			controlBarView.visible = true;
			helpButton.visible = true;
			streamsView.makeVisibleIfUserAlone();
			mouseTimer.reset();
			mouseTimer.start();
		}
		public function addChat():void
		{
			chatView.visible = true;
		}
		public function removeChat():void
		{
			chatView.visible = false;
		}
		public function setSize(_w:int=1280, _h:int=720):void
		{
			_viewportWidth = _w;
			_viewportHeight = _h;
			_viewportScale = 1;
			if (myStage is Stage) {
				_viewportWidth = myStage.stage.stageWidth;
				_viewportHeight = myStage.stage.stageHeight;
				if (CONFIG::tablet) {
					_viewportScale = 1.4;
				}
				
			}
			// make some additional changes to sizes of panels for larger screen sizes
			if (_viewportWidth > 1600) {
				_viewportScale = 1.2;
			}
			drawView();
		}
		public function panelsSlide(b:Boolean = true):void
		{
			// add swipe events for tablets
			// mouse event listeners for PCs
			if (b) {
				if (CONFIG::tablet) {
					myStage.addEventListener(TransformGestureEvent.GESTURE_SWIPE, swipeHandler);
				} else {
					facebookPanel.addEventListener(MouseEvent.ROLL_OVER, hotspotOver);
					facebookPanel.addEventListener(MouseEvent.ROLL_OUT, hotspotOut);
					youtubePanel.addEventListener(MouseEvent.ROLL_OVER, hotspotOver);
					youtubePanel.addEventListener(MouseEvent.ROLL_OUT, hotspotOut);
					controlBarView.addEventListener(MouseEvent.ROLL_OVER, hotspotOver);
					playlistView.addEventListener(MouseEvent.ROLL_OUT, hotspotOut);
				}
			} else {
				if (CONFIG::tablet) {
					myStage.removeEventListener(TransformGestureEvent.GESTURE_SWIPE, swipeHandler);
				} else {
					facebookPanel.removeEventListener(MouseEvent.ROLL_OVER, hotspotOver);
					facebookPanel.removeEventListener(MouseEvent.ROLL_OUT, hotspotOut);
					youtubePanel.removeEventListener(MouseEvent.ROLL_OVER, hotspotOver);
					youtubePanel.removeEventListener(MouseEvent.ROLL_OUT, hotspotOut);
					controlBarView.removeEventListener(MouseEvent.ROLL_OVER, hotspotOver);
					playlistView.removeEventListener(MouseEvent.ROLL_OUT, hotspotOut);
				}
				
			}
		}
		// flashPlaylistPanel
		// provide some visual feedback when an item is added to the playlist
		// slide in the playlist panel, then slide it off again
		// only do this is the playlist panel is NOT visible already
		public function flashPlaylistPanel():void
		{
			if (playlistPanelOff) {
				playlistPanelFlash = true;
				playlistPanelOff = false;
				doPlaylistPanelTween();
			}
		}
		private function focusEventHandler(e:FocusEvent):void
		{
			trace("StageView:: focusEventHandler:", e.type );
			trace("StageView:: focusEventHandler:", e.currentTarget.name );
		}
		// initView
		// instantiates all the top-level page elements
		private function initView():void
		{
			// initialise the static classes (TF registers fonts used by this view, ToolTip displays tooltip)
			ToolTip.init(myStage);
			TF.registerFonts();

			ytPlayer = new YouTubeViewer();
			ncView = new NetConnectionView();
			facebookPanel = new FacebookView();
			searchView = new SearchView();
			feedView = new FeedView();
			channelView = new ChannelSearchView();
			myPlaylistsView = new PlaylistsView();
			toptensView = new TopTensView();
			mySubscriptionsView = new SubscriptionListView();
			playlistView = new PlaylistView();
			controlBarView = new ControlBarView();
			chatView = new ChatView();
			streamsView = new StreamsView();
			youtubePanel = new GlassSprite();
			tabMenu = new TabMenu();
			helpButton = new FacebookButton("facebook", "HELP", 80, 24, false);
			systemMessageView = new SystemMessageView();
			helpSlideView = new HelpSlideView();
			videoMessagesView = new VideoMessagesView();

			// Focus Manager - controls which component has keyboard input
			fm = new FocusManager(myStage);
			fm.activate();
			//myStage.addEventListener(FocusEvent.FOCUS_IN, focusEventHandler);
			//myStage.addEventListener(FocusEvent.FOCUS_OUT, focusEventHandler);
			//myStage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, focusEventHandler);
			//myStage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, focusEventHandler);

			// the two hotspots for the facebookView and tabMenuViews
			fbHotspot = new Sprite();
			fbHotspot.name = "facebook";
			var fblogo:Bitmap = new FacebookIcon();
			fblogo.x = 4;
			fbHotspot.addChild(fblogo);
			facebookPanel.addChild(fbHotspot);
			if (CONFIG::screengrab) {
				fblogo.visible = false;	// can't show Facebook logo on FB marketing images
			}

			ytHotspot = new Sprite();
			ytHotspot.name = "youtube";
			var ytlogo:Bitmap = new YoutubeIcon();
			ytlogo.x = 12;	// 12 + 32 leaves a 4-pix border to the right
			ytHotspot.addChild(ytlogo);
			youtubePanel.addChild(ytHotspot);

			// name the 'hotspot' panels - so can use same handler for panels and hotspots
			facebookPanel.name = "facebook";
			youtubePanel.name = "youtube";
			controlBarView.name = "controlbar";
			playlistView.name = "playlist";
 
			// initialise the youtube panel
			tabMenu.add(feedView, "Videos");
			//youtubeView.add(channelView, "Channels");
			tabMenu.add(toptensView, "Top 10 Lists");
			tabMenu.add(myPlaylistsView, "My Playlists");
			tabMenu.add(mySubscriptionsView, "My YouTube");
			//tabMenu.activateTabByName("Videos");
			//tabMenu.activateTabByName("My Playlists");
			tabMenu.activateTabByName("My YouTube");
			youtubePanel.addChild(searchView);
			youtubePanel.addChild(tabMenu);
			tabMenu.y = 32;	// allow for height of search view
			
			// add page elements to the stage
			myStage.addChild(ytPlayer);
			//stage.addChild(ncView);
			myStage.addChild(helpButton);	// help button will be masked by streams view (good)
			myStage.addChild(streamsView);
			myStage.addChild(chatView);
			myStage.addChild(facebookPanel);
			myStage.addChild(youtubePanel);
			myStage.addChild(playlistView);
			myStage.addChild(controlBarView);
			myStage.addChild(systemMessageView);
			myStage.addChild(helpSlideView);
			myStage.addChild(videoMessagesView);
			
			youTubePanelOff = false;	// true when tabMenu is off or moving off
			facebookPanelOff = false;	// true when fbMenu is off or moving off
			playlistPanelOff = false;	// true when playlist is off or moving off
			playlistPanelFlash = false;	// playlist 'flashes' on/off when an item is added
			tweening = false;	// true if we are mid-tween of elements
			mouseTimer = new Timer(2000, 1);	// mouse/control bar disappear after 2 seconds of inactivity
			mouseTimer.addEventListener(TimerEvent.TIMER, mouseTimerHandler);
			fullScreen = false;
			removeChat();
		}
		
		private function drawView():void
		{
			trace("StageView:: drawView:", _viewportWidth, _viewportHeight );
			
			// set sizes and positions

			// playlistView - along the bottom of the screen, full width
			playlistView.x = 0;
			playlistView.setSize(_viewportWidth / _viewportScale, playlistView.HEIGHT);
			playlistView.scaleX = playlistView.scaleY = _viewportScale;

			if (tweening) {
				doYouTubePanelTween();
				doFacebookPanelTween();
				doPlaylistPanelTween();
			} else {
				youtubePanel.x = setYouTubePanelXPosition();
				facebookPanel.x = setFacebookPanelXPosition();
				playlistView.y = setPlaylistPanelYPosition();
			}
			facebookPanel.y = 4;
			youtubePanel.y = 4;

			// controlBarView - along the bottom, full width
			controlBarView.x = 0;
			controlBarView.y = _viewportHeight - 40 * _viewportScale;
			controlBarView.setSize(_viewportWidth / _viewportScale, 40);
			controlBarView.scaleX = controlBarView.scaleY = _viewportScale;
			
			// once we have the y pos of the playlist panel and control bar we can adjust the heights of other panels
			facebookPanel.scaleX = facebookPanel.scaleY = _viewportScale;
			youtubePanel.scaleX = youtubePanel.scaleY = _viewportScale;

			// and since YouTube panel is now dynamically-calculated we do this, then setPanelHeights will setSize on the panel
			var _maxWidth:int = Math.floor( _viewportWidth / _viewportScale - FACEBOOKPANELWIDTH - 2 * HOTSPOTWIDTH);
			// testing just use this width and see how it looks...
			YOUTUBEPANELWIDTH = Math.min(640, _maxWidth);
			
			// now we can adjust the sizes of the two panels
			setPanelHeights();
			
			// youtubePlayer - size and position depends on the layout choice (small / medium / large / fullscreen)
			ytPlayer.x = 0;
			ytPlayer.y = 0;
			var ytWidth:int = _viewportWidth;
			var ytHeight:int = _viewportHeight;
			ytPlayer.setSize( ytWidth, ytHeight);
			
			// chatView - directly below fbView (for now)
			chatView.x = 2;
			chatView.y = facebookPanel.y + 36;

			// streamsView - centred at the top (note registration point in centre of this display object)
			streamsView.x = _viewportWidth / 2;
			streamsView.y = 2;

			// helpButton - for now centre it, worry about what to do when streams visible later
			helpButton.x = (_viewportWidth - 324 - helpButton.width) / 2;
			helpButton.y = 4;
			
			// systemMessageView - centred at top below the streams view
			systemMessageView.x = (_viewportWidth - SystemMessageItemView.WIDTH) / 2;
			systemMessageView.y = 120;
			
			// helpSlideView - scale to size of viewport
			helpSlideView.scaleX = _viewportWidth / 1280;
			helpSlideView.scaleY = _viewportHeight / 800;
			
			// videoMessagesView - never changes
			videoMessagesView.x = 60;
			videoMessagesView.y = 60;
			
			panelsSlide();
			trace("StageView:: drawView: DONE"  );
		}

		private function mouseTimerHandler(e:TimerEvent = null):void
		{
			if (allPanelsOff() && !mouseOverCameraView()) {
				Mouse.hide();
				controlBarView.visible = false;
				helpButton.visible = false;
				streamsView.makeInvisibleIfUserAlone();
			}
		}
		private function setPanelHeights():void
		{
			// panel height calculated once here then used for all panels
			// 60 is to allow for height of controlbar
			var panelHeight:int = controlBarView.y < playlistView.y ? controlBarView.y - 8 : playlistView.y - 8;
			
			// facebookView 262 x height of screen minus space for playlist and controlbar
			facebookPanel.setSize(FACEBOOKPANELWIDTH, panelHeight / _viewportScale);

			// chatView same as facebookView
			chatView.setSize( FACEBOOKPANELWIDTH, panelHeight - 36);

			// youtubeView width of search panel, height of screen minus playlist/controlbar
			youtubePanel.setSize(YOUTUBEPANELWIDTH, panelHeight / _viewportScale);
			tabMenu.setSize(YOUTUBEPANELWIDTH, (panelHeight - tabMenu.y) / _viewportScale);

			// hotspot for facebookView
			fbHotspot.graphics.clear();
			fbHotspot.graphics.beginFill(0x000, 0);
			fbHotspot.graphics.drawRect(0, 0, HOTSPOTWIDTH, panelHeight);
			fbHotspot.graphics.endFill();
			fbHotspot.x = FACEBOOKPANELWIDTH;	// currently the width of the fb panel

			// hotspot for youtubeview
			ytHotspot.graphics.clear();
			ytHotspot.graphics.beginFill(0x000, 0);
			ytHotspot.graphics.drawRect(0, 0, HOTSPOTWIDTH, panelHeight);
			ytHotspot.graphics.endFill();
			ytHotspot.x = -ytHotspot.width;	// adjust as it runs to the left of the youtubeview
			
			// UPDATE: don't adjust YouTube viewer size, playlist appears over top
			if (CONFIG::screengrab) {
				// don't adjust YouTube viewer size
			} else {
//				ytPlayer.setSize( _viewportWidth, playlistView.y);
			}
		}

		// adjustments for Facebook by reading flashVars
		private function readFlashVars():void
		{
			if (myStage is Stage) {
				var flashVars:Object = myStage.root.loaderInfo.parameters;
			}
		}

		// swipeHandler for tablet gesture events
		private function swipeHandler(e:TransformGestureEvent):void
		{
			trace("StageView:: swipeHandler:", e.currentTarget.name, e.localX, e.localY, e.offsetX, e.offsetY );
			
			// offsetX/offsetY determine the swipe direction
			// can use the stageX/stageY to determine which panel should swipe on/off
			switch (e.offsetX) {
				
				case -1:
					// left
					// if facebook off then swipe must be to bring youtube on
					// if youtube on then swipe must be to send facebook off
					// if facebook on and youtube off then swipe ambigious - use X pos to determine which
					// if not inside youtube panel then send facebook off
					if (facebookPanelOff) {
						if (youTubePanelOff) {
							youTubePanelOff = false;
							doYouTubePanelTween();
						}
					} else {
						if (youTubePanelOff && e.stageX > myStage.width*3/4) {
							youTubePanelOff = false;
							doYouTubePanelTween();
						} else {
							facebookPanelOff = true;
							doFacebookPanelTween();
						}
					}
					break;
				case 1:
					// right
					// as for left but reversed...
					if (youTubePanelOff) {
						if (facebookPanelOff) {
							facebookPanelOff = false;
							doFacebookPanelTween();
						}
					} else {
						if (facebookPanelOff && e.stageX < myStage.width / 4) {
							facebookPanelOff = false;
							doFacebookPanelTween();
						} else {
							youTubePanelOff = true;
							doYouTubePanelTween();
						}
					}
					break;
			}
			// an up/down swipe will also be caught by the youtube/facebook panels if user
			// swipes within these (so won't bubble up to here)
			switch (e.offsetY) {
				case -1:
					// up
					if (playlistPanelOff) {
						playlistPanelOff = false;
						doPlaylistPanelTween();
					}
					break;
				case 1:
					// down
					if (!playlistPanelOff) {
						playlistPanelOff = true;
						doPlaylistPanelTween();
					}
					break;
			}
		}
		private function hotspotOver(e:MouseEvent):void
		{
			//trace("StageView:: hotspotOver:", e.currentTarget.name );
			if (e.currentTarget.name == "facebook") {
				facebookPanelOff = false;
				doFacebookPanelTween();
			} else if (e.currentTarget.name == "youtube") {
				youTubePanelOff = false;
				doYouTubePanelTween();
			} else if (e.currentTarget.name == "controlbar") {
				playlistPanelOff = false;
				doPlaylistPanelTween();
			}
		}
		private function hotspotOut(e:MouseEvent):void
		{
			trace("StageView:: hotspotOut:", e.currentTarget.name, myStage.mouseX, e.currentTarget.x, e.currentTarget.mouseX, YOUTUBEPANELWIDTH );
			if (e.currentTarget.name == "facebook") {
				// don't remove panel if mouse if further left than panel)
				if (e.currentTarget.mouseX > 0) {
						facebookPanelOff = true;
						doFacebookPanelTween();
				}
			} else if (e.currentTarget.name == "youtube") {
				// don't remove panel if mouse if further right than panel
				if (e.currentTarget.mouseX < 0) {
					youTubePanelOff = true;
					doYouTubePanelTween();
				}
			} else if (e.currentTarget.name == "playlist") {
				// don't remove panel if mouse is below panel
				if (e.currentTarget.mouseY < 0) {
					playlistPanelOff = true;
					if (CONFIG::screengrab) {
						playlistPanelOff = false;
					}
					doPlaylistPanelTween();
				}
			}
		}

		// doYouTubePanelTween
		// perform task of creating tween
		// uses tabMenuOff boolen to determine endpoint of tween, either onstage (false) or off (true)
		private function doYouTubePanelTween():void
		{
			TweenLite.to( youtubePanel, 0.5, { x: setYouTubePanelXPosition(), onComplete:tweenComplete } );
			tweening = true;
		}
		private function doFacebookPanelTween():void
		{
			TweenLite.to( facebookPanel, 0.5, { x:setFacebookPanelXPosition(), onComplete:tweenComplete } );
			tweening = true;
		}
		private function doPlaylistPanelTween():void
		{
			// extra hack to slow down playlist exit when its being 'flashed'
			var _delay:Number = 0;
			if (playlistPanelOff && playlistPanelFlash) {
				_delay = 0.8;
			}
			TweenLite.to( playlistView, 0.5, { y:setPlaylistPanelYPosition(), delay:_delay, onComplete:tweenComplete, onUpdate:setPanelHeights } );
			tweening = true;
		}
		private function tweenComplete():void
		{
			tweening = false;
			stageGetsFocus();	// in case user put focus into an input component
			if (playlistPanelFlash) {
				playlistPanelOff = true;
				doPlaylistPanelTween();
				playlistPanelFlash = false;
			}
			if (allPanelsOff())
			{
				dispatchEvent(new Event( Event.CLEAR ));
			}
			
		}
		private function setYouTubePanelXPosition():int
		{
			//trace("StageView:: setTabmenuXPosition:", stage.stageWidth, youtubeView.width, hotspot2.width );
			return youTubePanelOff ? _viewportWidth : _viewportWidth - YOUTUBEPANELWIDTH * _viewportScale - 2;
		}
		private function setFacebookPanelXPosition():int
		{
			return facebookPanelOff ? -FACEBOOKPANELWIDTH * _viewportScale -2 : 2;
		}
		private function setPlaylistPanelYPosition():int
		{
				return playlistPanelOff ? _viewportHeight : _viewportHeight - _viewportScale * (40 + playlistView.HEIGHT);
		}
		private function allPanelsOff():Boolean
		{
			return (facebookPanelOff && youTubePanelOff && playlistPanelOff);
		}
		private function mouseOverCameraView():Boolean
		{
			var pt:Point = new Point (myStage.mouseX, myStage.mouseY);
			var objects:Array = myStage.getObjectsUnderPoint(pt); 
			for (var i:int = 0; i< objects.length; i++)
			{
				if (objects[i].name == "cameraView") {
					return true;
				}
			}
			return false;
		}

	}

}
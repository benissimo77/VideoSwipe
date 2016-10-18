/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.vo.PlaylistVO;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import com.videoswipe.model.YouTubeOAuthProxy;
	import com.videoswipe.view.component.StageView;
	import com.videoswipe.view.popup.ConfirmationPopupMediator;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class StageMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "StageMediator";
		
		public function StageMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		/**
		 * Get the Mediator name.
		 * <P>
		 * Called by the framework to get the name of this
		 * mediator. If there is only one instance, we may
		 * define it in a constant and return it here. If
		 * there are multiple instances, this method must
		 * return the unique name of this instance.</P>
		 * 
		 * @return String the Mediator name
		 */
		override public function getMediatorName():String {
			return StageMediator.NAME;
		}
		
		override public function onRegister():void {
			trace("StageMediator:: onRegister: hello");

			// register all the lower-level mediators for elements further down the view hierarchy
			facade.registerMediator( new YouTubeMediator( stageView.ytPlayer ));
			facade.registerMediator( new NetConnectionMediator( stageView.ncView ));
			facade.registerMediator( new FacebookMediator( stageView.facebookPanel ));
			facade.registerMediator( new SearchInputMediator( stageView.searchView ));
			facade.registerMediator( new FeedMediator( stageView.feedView, "YouTubeFeed" ));
			facade.registerMediator( new ChannelInputMediator( stageView.channelView.searchInputView ));
			facade.registerMediator( new ChannelListMediator( stageView.channelView.channelListView ));
			facade.registerMediator( new PlaylistsMediator( stageView.myPlaylistsView ));
			facade.registerMediator( new PlaylistMediator( stageView.playlistView ));
			facade.registerMediator( new TopTensMediator( stageView.toptensView ));
			facade.registerMediator( new SubscriptionsMediator( stageView.mySubscriptionsView ));
			facade.registerMediator( new ControlBarMediator( stageView.controlBarView ));
			facade.registerMediator( new StreamsMediator( stageView.streamsView ));
			facade.registerMediator( new ChatMediator( stageView.chatView ));
			facade.registerMediator( new HelpSlideMediator( stageView.helpSlideView ));
			facade.registerMediator( new UserManagerMediator( stageView ));
			facade.registerMediator( new VideoMessagesMediator( stageView.videoMessagesView ));
			
			// register the popup mediators
			facade.registerMediator( new SystemMessageMediator( stageView.systemMessageView ) );

			// we place the Stage listeners here because the stageView might be running inside another display object
			// only needed for the standalone version (where we need to receive Stage events
			CONFIG::standalone {
				stage.addEventListener(Event.RESIZE, stageResizeHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseHandler);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyHandler);
				stageView.addEventListener(Event.CLEAR, stageClear);
				stageView.helpButton.addEventListener(MouseEvent.CLICK, helpButtonClicked);
			}

		}
		
		/**
		 * List all notifications this Mediator is interested in.
		 * <P>
		 * Automatically called by the framework when the mediator
		 * is registered with the view.</P>
		 * 
		 * @return Array the list of Nofitication names
		 */
		override public function listNotificationInterests():Array {
			return [
				AppConstants.PLAYERFULLSCREEN,
				AppConstants.STAGERESIZE,
				AppConstants.MOUSEMOVE,
				NetConnectionProxy.CONNECTIONCLOSED,
				AppConstants.ADDCHATVIEW,
				AppConstants.KEYBOARDINPUTDONE,
				AppConstants.SERVERADDTOPLAYLIST
				
				];
		}

		/**
		 * Handle all notifications this Mediator is interested in.
		 * <P>
		 * Called by the framework when a notification is sent that
		 * this mediator expressed an interest in when registered
		 * (see <code>listNotificationInterests</code>.</P>
		 * 
		 * @param INotification a notification
		 */
		override public function handleNotification(note:INotification):void {
			switch (note.getName()) {
				
				case AppConstants.PLAYERFULLSCREEN:
					trace("StageMediator:: handleNotification: FULL_SCREEN");
					stageView.goFullScreen();
					break;
				
				case AppConstants.STAGERESIZE:
					trace("StageMediator:: handleNotification: STAGERESIZE:", note.getBody().width, note.getBody().height );
					stageView.setSize( note.getBody().width, note.getBody().height );
					break;
					
				case AppConstants.MOUSEMOVE:
					stageView.mouseMove();
					break;
					
				case NetConnectionProxy.CONNECTIONCLOSED:
					trace("StageMediator:: handleNotification: CONNECTIONCLOSED" );
					stageView.removeChat();
					break;
				
				case AppConstants.ADDCHATVIEW:
					trace("StageMediator:: handleNotification: ADDCHATVIEW" );
					stageView.addChat();
					break;
					
				case AppConstants.KEYBOARDINPUTDONE:
					trace("StageMediator:: handleNotification: KEYBOARDINPUTDONE" );
					stageView.stageGetsFocus();
					break;
					
				case AppConstants.SERVERADDTOPLAYLIST:
					trace("StageMediator:: handleNotification: SERVERADDTOPLAYLIST" );
					stageView.flashPlaylistPanel();
					break;
					
				default:
					break;		
			}
		}

		// e.currentTarget holds the Stage object for RESIZE events
		private function stageResizeHandler(e:Event):void
		{
			trace("StageMediator:: stageResizeHandler:", e.currentTarget.stageWidth, e.currentTarget.stageHeight );
			sendNotification( AppConstants.STAGERESIZE, { width:e.currentTarget.stageWidth, height:e.currentTarget.stageHeight } );
 		}
		// e.currentTarget holds... ?
		private function stageMouseHandler(e:MouseEvent):void
		{
			//trace("StageMediator:: stageMouseHandler:", e.currentTarget );
			sendNotification( AppConstants.MOUSEMOVE, { x:e.currentTarget.mouseX, y:e.currentTarget.mouseY } );
		}
		private function stageKeyHandler(e:KeyboardEvent):void
		{
			sendNotification( AppConstants.KEYBOARDEVENT, e );
		}
		private function stageClear(e:Event = null):void
		{
			//trace("StageMediator:: stageClear:" );
			sendNotification( AppConstants.STAGECLEAR );
		}
		private function helpButtonClicked(e:MouseEvent = null):void
		{
			sendNotification( AppConstants.USERREQUESTHELP );
			//var _oauth:YouTubeOAuthProxy = facade.retrieveProxy( YouTubeOAuthProxy.NAME ) as YouTubeOAuthProxy;
			//_oauth.requestToken();
		}
		private function get stageView():StageView
		{
			return viewComponent as StageView;
		}
		private function get stage():Stage
		{
			return stageView.myStage.stage;
		}
	}
}
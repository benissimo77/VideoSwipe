/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.CameraListModel;
	import com.videoswipe.model.FacebookGraphProxy;
	import com.videoswipe.model.FeedProxy;
	import com.videoswipe.model.LayoutProxy;
	import com.videoswipe.model.LogNotificationsProxy;
	import com.videoswipe.model.NetConnectionProxy;
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.UserManagerProxy;
	import com.videoswipe.model.VideoMessageProxy;
	import com.videoswipe.model.YouTubeOAuthProxy;
	import com.videoswipe.model.YouTubeV3Proxy;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class PrepareModelCommand extends SimpleCommand {
		
		override public function execute(note:INotification):void {
			
			// set up Proxies...
			trace("PrepareModelCommand:: hello.");

			// bit of a swizz to get the passed-in flashVars but it works and its probably better than attempting
			// to pass it around from the Main.as script
			var stage:DisplayObject = note.getBody() as DisplayObject;
			var flashVars:Object = { };
			if (stage is Stage) {
				flashVars = stage.root.loaderInfo.parameters;
				// add the Stage dimensions to the flashVars object so we can store for analytics
				flashVars.sw = stage.stage.stageWidth;
				flashVars.sh = stage.stage.stageHeight;
			}

			// testing simulate a join user on startup
			//flashVars.u = "607151921";
			
			var _ncp:NetConnectionProxy = new NetConnectionProxy( );
			var _plp:PlaylistProxy = new PlaylistProxy();
			facade.registerProxy( _plp );
			facade.registerProxy( _ncp );
			facade.registerProxy( new FacebookGraphProxy(_ncp, _plp, flashVars));
			facade.registerProxy( new LogNotificationsProxy( _ncp ));
			facade.registerProxy( new FeedProxy() );
			facade.registerProxy( new CameraListModel());
			facade.registerProxy( new UserManagerProxy( flashVars ));
			facade.registerProxy( new VideoMessageProxy() );
			facade.registerProxy( new YouTubeOAuthProxy() );
			facade.registerProxy( new YouTubeV3Proxy() );
		}
		
	}
}
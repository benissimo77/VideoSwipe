/*
Simple Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.PlaylistProxy;
	import com.videoswipe.model.SystemMessageRequest;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	import org.puremvc.as3.patterns.observer.Notification;
    
	/**
	 * SimpleCommand
	 */
	public class UserRequestHelpCommand extends SimpleCommand {
		
		private static const HELPPID:int = 8205;
		
		override public function execute(note:INotification):void {
			
			var _plp:PlaylistProxy = facade.retrieveProxy( PlaylistProxy.NAME ) as PlaylistProxy;
			if (_plp.playlistLength > 0 && _plp.vo.father != HELPPID) {
				
				_plp.autoSavePlaylist();
				
				var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("warning", "Loading VideoSwipe Tips!", "Your current playlist has been saved for you, click the 'MY PLAYLIST' tab to load it once you've checked out the help videos", null, ["OK"], 5000);
				var _request:SystemMessageRequest = new SystemMessageRequest(_itemVO);
				sendNotification(AppConstants.ADDSYSTEMMESSAGE, _request);

			}
			
			_plp.loadPlaylist( HELPPID );
		}
		
	}
}

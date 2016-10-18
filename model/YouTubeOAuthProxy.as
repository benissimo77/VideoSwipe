/*
Proxy - PureMVC
*/
package com.videoswipe.model 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import flash.external.ExternalInterface;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;

	/**
	 * A proxy
	 */
	public class YouTubeOAuthProxy extends Proxy implements IProxy {
		
		public static const NAME:String = "YouTubeOAuthProxy";

		public function YouTubeOAuthProxy(data:Object = null) {
			super(NAME, data);
		}
	
		override public function onRegister():void
		{
			trace("YouTubeOAuthProxy:: onRegister:" );
			
			if( ExternalInterface.available )
			{
				var activated : Boolean = ExternalInterface.call( "vs_oauthCB.init", "videoswipe" );
				
				if( activated )
				{
					ExternalInterface.addCallback( "setAuthResult", setAuthResult );
				}
			}
					
		}

		public function requestToken():void
		{
			if (ExternalInterface.available) {
				ExternalInterface.call( "vs_oauthCB.authRequest" );
			} else {
				
				// testing - hardcode an access token here
				var _token:String = "ya29.zADmAXosm9kzUhRFWEPhPSyEMkg9fFPmGxzw713x_RSNWdhG9E5suuA0bG6v1meCkFeF70GzPEBD4A";
				setAuthResult( _token );
			}
		}
	
		// setAuthResult - called when the app first starts to see if we are already authorised...
		private function setAuthResult( result:String ):void
		{
			trace("WebAuthHandler:: setAuthResult:", result );
			//var json:Object = JSON.parse(result);
			
			// testing - display result passed from browser
			if (ExternalInterface.available) {
				var _itemVO:SystemMessageItemVO = new SystemMessageItemVO("invite", "setAuthResult: ", result, null, ["OK"], 0 );
				var request:SystemMessageRequest = new SystemMessageRequest( _itemVO );
				//sendNotification( AppConstants.ADDSYSTEMMESSAGE, request );
			}
			if (result) {
				var _v3:YouTubeV3Proxy = facade.retrieveProxy( YouTubeV3Proxy.NAME ) as YouTubeV3Proxy;
				_v3.getUserSubscriptions( result );
			}
			//if (json.error) {
				//trace("WebAuthHandler:: setAuthResult: ERROR" );
			//} else {
				//trace("WebAuthHandler:: setAuthResult: SUCCESS!" );
				//var _v3:YouTubeV3Proxy = facade.retrieveProxy( YouTubeV3Proxy.NAME ) as YouTubeV3Proxy;
				//_v3.getUserSubscriptions(  );
			//}
		}		
		
	}
}
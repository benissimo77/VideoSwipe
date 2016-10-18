/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.ApplicationFacade;
	import com.videoswipe.model.vo.VideoVO;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	import com.videoswipe.view.*;
	
	/**
	 * A Mediator
	 */
	public class VideoMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "VideoMediator";
		
		public function VideoMediator(viewComponent:Object) {
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
			return VideoMediator.NAME;
		}
        
		override public function onRegister():void {
			trace("VideoMediator:: onRegister: hello.");
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
				ApplicationFacade.ADDVIDEOITEM
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
				
				case ApplicationFacade.ADDVIDEOITEM:
					trace("VideoMediator:: handleNotification: ApplicationFacade.ADDVIDEOITEM");
					var v:VideoItemView = note.getBody() as VideoItemView;
					v.addEventListener("QueueVideoItem", clickHandler);
					v.y = stage.numChildren * 100;
					stage.addChild( v );
					break;
					
				default:
					break;		
			}
		}

		private function clickHandler(e:Event):void
		{
			var _v:VideoItemView = e.currentTarget as VideoItemView;
			trace("VideoMediator:: clickHandler:", _v.videoID);
		}
		private function get stage():Sprite
		{
			return viewComponent as Sprite
		}
	}
}
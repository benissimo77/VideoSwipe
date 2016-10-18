/*
 Mediator - PureMVC
 */
package com.videoswipe.view 
{
	import com.videoswipe.controller.AppConstants;
	import com.videoswipe.model.FeedProxy;
	import com.videoswipe.view.component.SearchView;
	import flash.events.Event;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	/**
	 * A Mediator
	 */
	public class SearchInputMediator extends Mediator implements IMediator {
	
		// Cannonical name of the Mediator
		public static const NAME:String = "SearchInputMediator";
		
		public function SearchInputMediator(viewComponent:Object) {
			// pass the viewComponent to the superclass where 
			// it will be stored in the inherited viewComponent property
			super(NAME, viewComponent);
		}

		override public function onRegister():void {
			trace("SearchMediator:: onRegister:");
			searchView.addEventListener( "beginSearch", beginSearch );
			
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
			return SearchInputMediator.NAME;
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
			return [];
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
				default:
					break;		
			}
		}

		private function beginSearch(e:Event = null):void
		{
			trace("SearchMediator:: beginSearch:", searchView.searchVO.searchText);
			var fp:FeedProxy = facade.retrieveProxy(FeedProxy.NAME) as FeedProxy;
			fp.youTubeSearch( searchView.searchVO );
			sendNotification( AppConstants.LOGSEARCH, searchView.searchVO.searchText );
			// for now use the search button to test out the YouTube OAuth functionality...
			//fp.attemptOAuth();
			sendNotification( AppConstants.KEYBOARDINPUTDONE );
		}

		private function get searchView():SearchView
		{
			return viewComponent as SearchView;
		}
	}
}
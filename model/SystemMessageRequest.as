package com.videoswipe.model 
{
	import com.videoswipe.model.vo.SystemMessageItemVO;
	import org.puremvc.as3.patterns.observer.Observer;

	/**
	 * SystemMessageRequest
	 * Class to hold all info for a system message request - passed to the SystemMessageMediator
	 */
	public class SystemMessageRequest extends Observer
	{
		// Prefix for all request notification names
		private static const NAME:String = "SystemMessageRequest";

		public var hasCallback:Boolean = false;
		public var center:Boolean = true;
		public var modal:Boolean = false;

		// attributes of the system message
		private var _itemVO:SystemMessageItemVO;
		
		/**
		* Constructor.
		* Example: new SystemMessageRequest( vo, handlePopupNotification, this );
		*/
		public function SystemMessageRequest( vo:SystemMessageItemVO=null, callback:Function=null, caller:Object=null )
		{
			super( callback, caller );
			hasCallback = ( callback != null && caller != null );
			if (vo) itemVO = vo;
		}
		
		public function get itemVO():SystemMessageItemVO 
		{
			return _itemVO;
		}
		
		public function set itemVO(value:SystemMessageItemVO):void 
		{
			_itemVO = value;
		}

	}
}
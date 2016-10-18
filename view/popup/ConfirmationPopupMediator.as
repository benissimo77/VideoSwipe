package com.videoswipe.view.popup
{
	import flash.display.DisplayObject;

	public class ConfirmationPopupMediator extends AbstractPopupMediator
	{

		public static const NAME:String = "ConfirmationPopupMediator";

		public function ConfirmationPopupMediator( viewComponent:DisplayObject)
		{
			super( NAME, viewComponent );
		}

		override public function listNotificationInterests():Array
		{
			return [ PopupRequest.CONFIRMATION_POPUP ];
		}
		override protected function popupFactory():ConfirmationPopup
		{
			return new ConfirmationPopup();
		}
	}
}
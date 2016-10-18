package com.videoswipe.view.popup 
{
	import flash.events.IEventDispatcher;
	import myLib.display.IDisplayObject;
	
	/**
	 * ...
	 * @author 
	 */
	public interface IPopup extends IDisplayObject
	{
		function setData( data:Object ):void;
		function getEvents():Array;
	}
}
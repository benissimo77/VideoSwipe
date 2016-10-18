/*
Macro Command - PureMVC
 */
package com.videoswipe.controller 
{
	import com.videoswipe.model.FacebookGraphProxy;
	import org.puremvc.as3.patterns.command.MacroCommand;
	
	/**
	 * A MacroCommand
	 */
	public class StartupCommand extends MacroCommand 
	{
	
		/**
		 * Initialize the MacroCommand by adding its SubCommands.
		 * 
		 */
		override protected function initializeMacroCommand():void {

			addSubCommand( PrepareControllerCommand );
			addSubCommand( PrepareModelCommand );
			addSubCommand( PrepareViewCommand );
			
		}
		
	}
}
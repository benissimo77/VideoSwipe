/*
Macro Command - PureMVC
 */
package com.videoswipe.controller 
{
	import org.puremvc.as3.patterns.command.MacroCommand;
	
	/**
	 * A MacroCommand
	 */
	public class StartupViewerCommand extends MacroCommand 
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
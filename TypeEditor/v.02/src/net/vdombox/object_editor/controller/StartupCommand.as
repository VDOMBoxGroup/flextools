/*

 */
package net.vdombox.object_editor.controller
{  
	import flash.sampler.startSampling;	
	import net.vdombox.object_editor.view.mediators.ApplicationMediator;	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.command.*;

	public class StartupCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() :void
		{
			addSubCommand( PrepCommand );
			addSubCommand( OpenLastDirectory );			
		}
	}
}



/*
	Class StartupCommand complit of AplicationMediator and start of OpenLastDirectoryCommand
*/
package net.vdombox.object_editor.controller
{  
	import flash.sampler.startSampling;
	
	import net.vdombox.object_editor.view.mediators.ApplicationMediator;
	import net.vdombox.object_editor.view.mediators.UpdateMediator;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.command.*;

	public class StartupCommand extends MacroCommand
	{
		override protected function initializeMacroCommand() :void
		{
			facade.registerMediator( new UpdateMediator() );
			
			var appMediator:ApplicationMediator = facade.retrieveMediator( ApplicationMediator.NAME ) as ApplicationMediator;
			appMediator.complit();
			addSubCommand( OpenLastDirectoryCommand );			
		}
	}
}



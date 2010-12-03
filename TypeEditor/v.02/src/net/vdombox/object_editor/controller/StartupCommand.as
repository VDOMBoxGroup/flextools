/*
  Class StartupCommand register the Proxies and AplicationMediators
*/
package net.vdombox.object_editor.controller
{  
	import net.vdombox.object_editor.view.Mediators.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.command.*;
    
    
    public class StartupCommand extends SimpleCommand implements ICommand
    {
		// Register the Proxies and AplicationMediators
		override public function execute(note:INotification):void    
		{
			// Create and register proxy
//			facade.registerProxy(new OpenFileProxy());
//			facade.registerProxy(new SaveFileProxy());
			facade.registerMediator( new ApplicationMediator( note.getBody() ) );			
		}                
    }
}

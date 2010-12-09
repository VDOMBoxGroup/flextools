/*
	Class StartupCommand register the Proxies and AplicationMediators.
*/
package net.vdombox.object_editor.controller
{
    import net.vdombox.object_editor.model.proxy.FileProxy;
    import net.vdombox.object_editor.model.proxy.ItemProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
    import net.vdombox.object_editor.view.mediators.ApplicationMediator;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;
  
        
    public class PrepCommand extends SimpleCommand
    {        
		// Register the Proxies and AplicationMediators
		override public function execute(note:INotification):void    
		{
// Create and register proxy
//			facade.registerProxy(new OpenFileProxy());
			facade.registerProxy(new ItemProxy());
			facade.registerProxy(new ObjectTypeProxy());
			facade.registerProxy(new FileProxy());
			facade.registerMediator( new ApplicationMediator( note.getBody() ) );			
		} 
    }
}
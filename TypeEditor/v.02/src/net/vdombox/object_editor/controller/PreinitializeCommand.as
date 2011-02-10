/*
	Class PreinitializeCommand register the Proxies and AplicationMediator.
*/
package net.vdombox.object_editor.controller
{
    import net.vdombox.object_editor.model.proxy.FileProxy;
    import net.vdombox.object_editor.model.proxy.ObjectsProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.ActionContainersProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.AttributesProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.EventsProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.LibrariesProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.ResourcesProxy;
    import net.vdombox.object_editor.view.mediators.ApplicationMediator;
    
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    import org.puremvc.as3.patterns.observer.*;  
        
    public class PreinitializeCommand extends SimpleCommand
    {        
		// Register the Proxies and AplicationMediators
		override public function execute(note:INotification):void    
		{
			// Create and register proxy
			facade.registerProxy(new ObjectsProxy());
			facade.registerProxy(new ObjectTypeProxy());
			facade.registerProxy(new FileProxy());
			facade.registerProxy(new ActionContainersProxy());
			facade.registerProxy(new AttributesProxy());
			facade.registerProxy(new EventsProxy());
			facade.registerProxy(new LanguagesProxy());			
			facade.registerProxy(new LibrariesProxy());			
			facade.registerProxy(new ResourcesProxy());
			facade.registerMediator( new ApplicationMediator( note.getBody() ) );			
		} 
    }
}
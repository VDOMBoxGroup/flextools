package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SettingsApplicationProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SettingsProxy;
	import net.vdombox.ide.modules.wysiwyg.model.TypesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.VisibleRendererProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			facade.registerProxy( new VisibleRendererProxy() );
			facade.registerProxy( new SettingsApplicationProxy() );
			facade.registerProxy( new TypesProxy() );
			facade.registerProxy( new SessionProxy() );
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new RenderProxy() );
			facade.registerProxy( new ResourcesProxy() );
		}
	}
}
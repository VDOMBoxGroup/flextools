package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.MessageProxy;
	import net.vdombox.ide.modules.wysiwyg.model.MultiObjectsManipulationProxy;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SettingsApplicationProxy;
	import net.vdombox.ide.modules.wysiwyg.model.UserTypesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.VisibleRendererProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			facade.registerProxy( new VisibleRendererProxy() );
			facade.registerProxy( new SettingsApplicationProxy() );
			facade.registerProxy( new MultiObjectsManipulationProxy() );
			facade.registerProxy( new TypesProxy() );
			facade.registerProxy( new StatesProxy() );
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new RenderProxy() );
			facade.registerProxy( new ResourcesProxy() );
			facade.registerProxy( new UserTypesProxy() );
			facade.registerProxy( new MessageProxy() );
		}
	}
}

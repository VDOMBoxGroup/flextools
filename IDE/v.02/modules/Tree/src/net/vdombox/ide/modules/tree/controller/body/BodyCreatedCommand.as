package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.LevelsPanelMediator;
	import net.vdombox.ide.modules.tree.view.MenuPanelMediator;
	import net.vdombox.ide.modules.tree.view.PropertiesPanelMediator;
	import net.vdombox.ide.modules.tree.view.WorkAreaMediator;
	import net.vdombox.ide.modules.tree.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

			facade.registerMediator( new WorkAreaMediator( body.treeCanvas ) );
			
//			facade.registerMediator( new MenuPanelMediator( body.menuPanel ) );
			facade.registerMediator( new PropertiesPanelMediator( body.propertiesPanel ) );
			facade.registerMediator( new LevelsPanelMediator( body.levelsPanel ) );
		}
	}
}
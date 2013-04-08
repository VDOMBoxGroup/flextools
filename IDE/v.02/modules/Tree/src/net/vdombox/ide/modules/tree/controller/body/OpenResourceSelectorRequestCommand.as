package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.view.ResourceSelectorWindowMediator;
	import net.vdombox.ide.modules.tree.view.components.ResourceSelector;
	import net.vdombox.ide.modules.tree.view.components.ResourceSelectorWindow;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenResourceSelectorRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourceSelectorWindow : ResourceSelectorWindow = new ResourceSelectorWindow();
			var resourceSelector : ResourceSelector = notification.getBody() as ResourceSelector;

			if ( facade.hasMediator( ResourceSelectorWindowMediator.NAME ) )
				facade.removeMediator( ResourceSelectorWindowMediator.NAME );

			var resourceSelectorWindowMediator : ResourceSelectorWindowMediator = new ResourceSelectorWindowMediator( resourceSelectorWindow );
			resourceSelectorWindowMediator.resourceSelector = resourceSelector;

			facade.registerMediator( resourceSelectorWindowMediator );

			//sendNotification( Notifications.OPEN_WINDOW, { content: resourceSelectorWindow, title: "Select Resource", isModal: true, resizable : true } );
		}
	}
}

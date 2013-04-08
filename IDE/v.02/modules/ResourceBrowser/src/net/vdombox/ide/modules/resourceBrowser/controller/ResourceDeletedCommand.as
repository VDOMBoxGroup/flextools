package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ResourceDeletedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourceVO : ResourceVO = notification.getBody() as ResourceVO;

			if ( resourceVO )
			{
				var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

				if ( statesProxy.selectedResource && statesProxy.selectedResource.id == resourceVO.id )
					statesProxy.selectedResource = null;
			}
		}
	}
}

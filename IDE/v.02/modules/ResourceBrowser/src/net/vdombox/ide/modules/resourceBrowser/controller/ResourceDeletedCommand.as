package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ResourceDeletedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var resourceVO : ResourceVO = notification.getBody() as ResourceVO;

			if ( resourceVO )
			{
				var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
				
				if( sessionProxy.selectedResource && sessionProxy.selectedResource.id == resourceVO.id )
					sessionProxy.selectedResource = null;
			}
		}
	}
}
package net.vdombox.ide.modules.resourceBrowser.controller
{
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class DeleteResourceRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var resourceVO : ResourceVO = sessionProxy.selectedResource;

			if ( resourceVO && sessionProxy.selectedApplication )
				sendNotification( ApplicationFacade.DELETE_RESOURCE, { applicationVO: sessionProxy.selectedApplication, resourceVO: resourceVO } );
		}
	}
}
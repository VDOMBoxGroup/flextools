package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class DeleteLibraryRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var libraryVO : LibraryVO = notification.getBody() as LibraryVO;
			
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			var applicationVO : ApplicationVO = statesProxy.selectedApplication;
			
			if( libraryVO && applicationVO )
				sendNotification( ApplicationFacade.DELETE_LIBRARY, { applicationVO : applicationVO, libraryVO : libraryVO } );
		}
	}
}
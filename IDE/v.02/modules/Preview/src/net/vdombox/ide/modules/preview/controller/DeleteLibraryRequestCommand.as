package net.vdombox.ide.modules.preview.controller
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class DeleteLibraryRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var libraryVO : LibraryVO = notification.getBody() as LibraryVO;
			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var applicationVO : ApplicationVO = sessionProxy.selectedApplication;
			
			if( libraryVO && applicationVO )
				sendNotification( ApplicationFacade.DELETE_LIBRARY, { applicationVO : applicationVO, libraryVO : libraryVO } );
		}
	}
}
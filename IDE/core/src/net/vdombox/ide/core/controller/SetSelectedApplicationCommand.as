package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SetSelectedApplicationCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationVO : ApplicationVO;
			var body : ApplicationVO = notification.getBody() as ApplicationVO;

			applicationVO = body || lastOpenedApplication;

			if ( !applicationVO )
				return;

			statesProxy.selectedApplication = applicationVO;

			sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, statesProxy.selectedApplication );

			sendNotification( ApplicationFacade.CLEAR_PROXY_STORAGE );

			settingsProxy.setSelectedApp( serverProxy.server, applicationVO.id );
		}

		private function get lastOpenedApplication() : ApplicationVO
		{
			var applicationID : String = settingsProxy.getSelectedApp( serverProxy.server );

			if ( applicationID == "" )
				return null;

			for each ( var applicationVO : ApplicationVO in applications )
			{
				if ( applicationVO.id == applicationID )
					return applicationVO;
			}

			return null;
		}

		//		private function get firstOfListApplications():  ApplicationVO
		//		{
		//			return ( applications.length > 0 ) ? applications[0] : null;
		//		}

		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}

		private function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		private function get settingsProxy() : SettingsProxy
		{
			return facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
		}

		private function get applications() : Array
		{
			return serverProxy.applications;
		}

	}
}

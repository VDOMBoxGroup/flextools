package net.vdombox.ide.view
{
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.ServerProxy;
	import net.vdombox.ide.view.components.ApplicationsManagment;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationsManagmentMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationManagmentMediator";

		public function ApplicationsManagmentMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var localeProxy : LocaleProxy;
		private var serverProxy : ServerProxy;

		private function get applicationsManagment() : ApplicationsManagment
		{
			return viewComponent as ApplicationsManagment;
		}

		override public function onRegister() : void
		{
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;
			serverProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			var appList : XML = serverProxy.applicationList;
			applicationsManagment.applicationsList.labelFunction = function( data : XML ) : String
			{
				return data.Information.Name;
			}
			applicationsManagment.applicationsList.dataProvider = appList.*;
		}
	}
}
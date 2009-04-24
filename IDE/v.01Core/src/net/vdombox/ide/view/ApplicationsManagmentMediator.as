package net.vdombox.ide.view
{
	import flash.events.Event;

	import mx.controls.List;
	import mx.events.FlexEvent;

	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.ServerProxy;
	import net.vdombox.ide.view.components.ApplicationsManagment;
	import net.vdombox.ide.view.controls.ApplicationItemRenderer;

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

			var applicationsList : List = applicationsManagment.applicationsList;
			applicationsList.addEventListener( ApplicationItemRenderer.RENDERER_CREATED,
											   applicationItemRenderer_rendererCreated,
											   true );
			applicationsList.dataProvider = serverProxy.applicationList.*
		}

		private function applicationItemRenderer_rendererCreated( event : Event ) : void
		{
			var renderer : ApplicationItemRenderer = event.target as ApplicationItemRenderer;
			var mediator : ApplicationItemRendererMediator = new ApplicationItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}

		private function zzz( event : FlexEvent ) : void
		{
			var dummy : * = ""; // FIXME remove dummy
		}
	}
}
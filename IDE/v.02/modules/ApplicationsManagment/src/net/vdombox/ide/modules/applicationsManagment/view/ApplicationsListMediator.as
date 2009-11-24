package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class ApplicationsListMediator extends Mediator implements IMediator
	{
		public function ApplicationsListMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		public const NAME : String = "ApplicationsListMediator";

		private var applications : Array;
		private var selectedApplication : Object;

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.APPLICATIONS_LIST_GETTED );
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );

			return interests;
		}

		override public function onRegister() : void
		{
			addHandlers();
			
			applicationsList.itemRenderer = new ClassFactory( ApplicationItemRenderer );

			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.APPLICATIONS_LIST_GETTED:
				{
					applications = notification.getBody() as Array;
					applicationsList.dataProvider = new ArrayList( applications );

					sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
					break;
				}

				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					var selectedApplication : Object = notification.getBody();

					if ( !applications || applications.length == 0 || selectedApplication == null )
						return;

					var index : int = applications.lastIndexOf( selectedApplication );

					if ( index != -1 )
						applicationsList.selectedIndex = index;

					break;
				}
			}
		}

		private function get applicationsList() : List
		{
			return viewComponent as List;
		}
		
		private function addHandlers() : void
		{
			applicationsList.addEventListener( ApplicationItemRenderer.RENDERER_CREATED, applicationItemRenderer_rendererCreatedHandler, true )
			applicationsList.addEventListener( IndexChangeEvent.CHANGE, changeHandler );
		}
		
		private function applicationItemRenderer_rendererCreatedHandler( event : Event ) : void
		{
			var renderer : ApplicationItemRenderer = event.target as ApplicationItemRenderer;

			var mediator : ApplicationItemRendererMediator = new ApplicationItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}
		
		private function changeHandler( event : IndexChangeEvent ) : void
		{
			var d : * = "";
		}
	}
}
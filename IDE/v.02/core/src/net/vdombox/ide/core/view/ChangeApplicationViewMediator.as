package net.vdombox.ide.core.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.ApplicationListItemRenderer;
	import net.vdombox.ide.core.view.components.ChangeApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;

	public class ChangeApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ChangeApplicationViewMediator";
		
		private var applications : Array;
		private var applicationsChanged : Boolean;
		
		public function ChangeApplicationViewMediator(viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get changeApplicationView() : ChangeApplicationView
		{
			return viewComponent as ChangeApplicationView;
		}
		
		public function get applicationList() : List
		{
			return changeApplicationView.applicationList as List;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SERVER_APPLICATIONS_GETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.SERVER_APPLICATIONS_GETTED:
				{
					applications = notification.getBody() as Array;
					applicationsChanged = true;
					//selectedApplicationChanged = true;*/
					
					break;
				}
			
			}
			
			commitProperties();
		}
		
		private function commitProperties() : void
		{
			if ( applicationsChanged )
			{
				applicationsChanged = false;
				applicationList.dataProvider = new ArrayList( applications );
			}
		}
		
		override public function onRegister() : void
		{
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
			addHandlers();
		}
		
		private function addHandlers() : void
		{
			applicationList.addEventListener( ApplicationListItemRenderer.RENDERER_CREATED, rendererCreatedHandler, true );
		}
		
		private function rendererCreatedHandler( event : Event ) : void
		{
			var renderer : ApplicationListItemRenderer = event.target as ApplicationListItemRenderer;
			
			var mediator : ApplicationListItemRendererMediator = new ApplicationListItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}
	}
}
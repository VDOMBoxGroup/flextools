package net.vdombox.ide.core.view
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.ApplicationListItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationListItemRendererMediator extends Mediator implements IMediator
	{
		public function ApplicationListItemRendererMediator( viewComponent : Object = null )
		{
			super( NAME +"/"+viewComponent.name, viewComponent );

			addHandlers();
		}
		
		private static const NAME : String = "ApplicationListItemRendererMediator";
		
		private static var serial : Number = 0;
		
		
		private var _applicationVO : ApplicationVO;
		
//		private static function getNextID() : String
//		{
//			var id : String = NAME + "/" + serial;
//			serial++;
//			return id;
//		}
		
		public function get resourceVO():ResourceVO
		{
			return applicationListItemRenderer.resourceVO;
		}

		

		private function get applicationVO():ApplicationVO
		{
			return applicationListItemRenderer.applicationVO;
		}

		

		private function get applicationListItemRenderer() : ApplicationListItemRenderer
		{
			return viewComponent as ApplicationListItemRenderer;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_UPDATED );
			interests.push( ApplicationFacade.GET_APPLICATIONS_LIST );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			if ( !applicationListItemRenderer.resourceVO )
				return;
			
			var resVO : ResourceVO;
			
			switch ( notification.getName() )
			{
				
					
				case ApplicationFacade.APPLICATION_INFORMATION_UPDATED:
				{
//					if ( notification.getBody() === applicationListItemRenderer.data )
//						iconRequest()

					break;
				}
					
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
				
				case ApplicationFacade.GET_APPLICATIONS_LIST:
				{
//					facade.removeMediator( mediatorName );
					
					break;
				}
					
			}	
		}
		
		private function addHandlers(): void
		{
			applicationListItemRenderer.addEventListener( ApplicationListItemRenderer.ICON_REQUEST, iconRequestHandler );
			applicationListItemRenderer.addEventListener(FlexEvent.REMOVE, renderRemoveHandler);
		}
		
		override public function onRegister() : void
		{
			iconRequest();
			//refreshProperties();
		}
		
		override public function onRemove() : void
		{
			applicationListItemRenderer.removeEventListener( ApplicationListItemRenderer.ICON_REQUEST, iconRequestHandler );
			applicationListItemRenderer.removeEventListener(FlexEvent.REMOVE, renderRemoveHandler);
		}
		
		private function iconRequest():void
		{
			if (resourceVO)
				sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO} );
		}
		
		private function iconRequestHandler( event : Event ) : void
		{
			iconRequest();
//			setIcon();
			
		}
		
		private function renderRemoveHandler ( event : FlexEvent ) : void
		{
			facade.removeMediator( mediatorName );
		}
		
		
		
		
	}
}
package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.binding.utils.BindingUtils;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationItemRendererMediator extends Mediator implements IMediator
	{
		public function ApplicationItemRendererMediator( viewComponent : Object = null )
		{
			super( getNextID(), viewComponent );
		}

		private static const NAME : String = "ApplicationItemRendererMediator";

		private static var serial : Number = 0;

		private static function getNextID() : String
		{
			var id : String = NAME + "/" + serial;
			serial++;
			return id;
			
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( mediatorName + "/" + ApplicationFacade.RESOURCE_GETTED );

			return interests;
		}

		override public function onRegister() : void
		{
			var iconID : String = applicationItemRenderer.data.iconID;
			var ownerID : String = applicationItemRenderer.data.id;
			
			if ( iconID != "" )
				sendNotification( ApplicationFacade.GET_RESOURCE, { resourceID: iconID, ownerID : ownerID, recepientName: mediatorName });
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var resourceVO :ResourceVO = notification.getBody() as ResourceVO;
				
			BindingUtils.bindSetter( setIcon, resourceVO, "data" );
		}
		
		private function get applicationItemRenderer() : ApplicationItemRenderer
		{
			return viewComponent as ApplicationItemRenderer;
		}
		
		private function setIcon( value : * ) : void
		{
			applicationItemRenderer.imageHolder.source = value;
		}
	}
}
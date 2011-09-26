package net.vdombox.ide.core.view
{
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
			super( getNextID(), viewComponent );
		}
		
		private static const NAME : String = "ApplicationListItemRendererMediator";
		
		private static var serial : Number = 0;
		
		private var resourceVO : ResourceVO;
		
		private static function getNextID() : String
		{
			var id : String = NAME + "/" + serial;
			serial++;
			return id;
		}
		
		private function get applicationListItemRenderer() : ApplicationListItemRenderer
		{
			return viewComponent as ApplicationListItemRenderer;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.RESOURCE_LOADED + "/" + mediatorName );
			//interests.push( ApplicationFacade.APPLICATION_EDITED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.RESOURCE_LOADED + "/" + mediatorName:
				{
					var resourceVO : ResourceVO = notification.getBody() as ResourceVO;
					
					BindingUtils.bindSetter( setIcon, resourceVO, "data" );
					
					break;
				}
			}	
		}
		
		private function setIcon( value : * ) : void
		{
			applicationListItemRenderer.imageHolder.source = value;
		}
		
		override public function onRegister() : void
		{
			applicationListItemRenderer.addEventListener( FlexEvent.DATA_CHANGE, dataChangeHandler );
			
			refreshProperties();
		}
		
		
		private function dataChangeHandler( event : FlexEvent ) : void
		{
			refreshProperties();
		}
		
		private function refreshProperties() : void
		{
			var applicationVO : ApplicationVO = applicationListItemRenderer.data as ApplicationVO;
			
			if ( applicationVO )
			{
				applicationListItemRenderer.nameLabel.text = applicationVO.name;
				
				if ( applicationVO.iconID && ( !resourceVO || resourceVO.id != applicationVO.iconID ) )
				{
					resourceVO = new ResourceVO( applicationVO.id );
					resourceVO.setID( applicationVO.iconID );
					
					sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
				}
			}
			else
			{
				applicationListItemRenderer.nameLabel.text = "";
			}
		}
	}
}
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
			
			interests.push( ApplicationFacade.RESOURCE_LOADED );
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_UPDATED );
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			interests.push( ApplicationFacade.RESOURCE_SETTED_ERROR );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var resVO : ResourceVO;
			var applicationVO : ApplicationVO = applicationListItemRenderer.data as ApplicationVO;
			switch ( notification.getName() )
			{
				case ApplicationFacade.RESOURCE_LOADED:
				{
					resVO = notification.getBody() as ResourceVO;
					trace("1111111");
					if ( resVO.ownerID != applicationVO.id )
						return;
					trace("321");
					resourceVO = notification.getBody() as ResourceVO;
					BindingUtils.bindSetter( setIcon, resourceVO, "data", false, true );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_INFORMATION_UPDATED:
				{
					if ( notification.getBody() === applicationListItemRenderer.data )
						refreshProperties();
					
					break;
				}
					
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
					
					resVO = notification.getBody() as ResourceVO;
					
					if ( applicationVO.id == resVO.ownerID )
					{
						resourceVO = new ResourceVO(applicationVO.id );
						resourceVO.setID(resVO.id);
						//BindingUtils.bindSetter( setIcon, resourceVO, "data", false, true );
						sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
					}
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED_ERROR:
				{
					
					sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
					
					break;
				}
			}	
		}
		
		
		private function setIcon( value : * ) : void
		{
			var loader : Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, setIconLoaded );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, setIconLoaded );
			
			try
			{
				loader.loadBytes( resourceVO.data );
			}
			catch ( error : Error )
			{
				// FIXME Сделать обработку исключения если не грузится изображение
			}
		}
		
		private function setIconLoaded( event : Event ) : void
		{
			if ( event.type == IOErrorEvent.IO_ERROR )
				return;
			applicationListItemRenderer.imageHolder.source = event.target.content;
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
				
				sendNotification( ApplicationFacade.CHANGE_RESOURCE, applicationVO );
				
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
package net.vdombox.ide.core.view
{
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.view.components.CreateEditApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class CreateEditApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateEditApplicationViewMediator";
		
		private var applicationVO : ApplicationVO;
		
		private var newIconResourceVO : ResourceVO;
		
		public function CreateEditApplicationViewMediator(viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get createEditApplicationView() : CreateEditApplicationView
		{
			return viewComponent as CreateEditApplicationView;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW );	
			interests.push( ApplicationFacade.RESOURCE_LOADED );
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var resourceVO : ResourceVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.OPEN_APPLICATION_IN_EDIT_VIEW:
				{
					applicationVO = body as ApplicationVO;
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_LOADED:
				{
					if ( !applicationVO )
						return;
					
					resourceVO = body as ResourceVO;
					
					if ( resourceVO.ownerID != applicationVO.id )
						return;
					
					BindingUtils.bindSetter( setIcon, resourceVO, "data" );
					
					return;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = body as ResourceVO;
					
					if ( resourceVO == newIconResourceVO )
					{
						newIconResourceVO = null;
						
						var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
						applicationInformationVO.iconID = resourceVO.id;
						
						sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
							applicationInformationVO: applicationInformationVO } );
					}
					/*if ( applicationVO )
						editApplicationView.applicationsList.dataProvider.addItem( applicationVO );*/
					
					break;
				}
					
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
					
			}
			commitProperties();
		}
		
		private function setIcon( value : * ) : void
		{
			createEditApplicationView.iconChooser.selectedIcon.source = value;
		}
		
		private function commitProperties() : void
		{
			if ( applicationVO )
			{
				createEditApplicationView.txtapplicationName.text = applicationVO.name;
				createEditApplicationView.txtapplicationDescription.text = applicationVO.description;
				
				if ( applicationVO.iconID )
				{
					var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );
					resourceVO.setID( applicationVO.iconID );
				
					sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
				}
			}
			
		}
		
		override public function onRegister() : void
		{
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		private function addHandlers() : void
		{
			createEditApplicationView.addEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			facade.registerMediator( new IconChooserMediator( createEditApplicationView.iconChooser ) );
		}
		
		private function removeHandlers() : void
		{
			createEditApplicationView.removeEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			facade.removeMediator( IconChooserMediator.NAME );
		}
		
		private function saveInformationHandler( event : ApplicationManagerWindowEvent ) : void
		{
			if ( applicationVO )
			{
				// Name
				
				var newApplicationName : String = createEditApplicationView.txtapplicationName.text;
				
				if ( newApplicationName == "" )
					return;
				
				var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
				
				if ( newApplicationName != applicationVO.name )
					applicationInformationVO.name = newApplicationName;
				
				//Description
				
				var newApplicationDescription : String = createEditApplicationView.txtapplicationDescription.text;
				
				if ( newApplicationDescription != applicationVO.description )
					applicationInformationVO.description = newApplicationDescription;
				
				sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
					applicationInformationVO: applicationInformationVO } );
				
				//Icon
				
				var iconChooserMediator : IconChooserMediator = facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;
				
				var newApplicationIcon : ByteArray = iconChooserMediator.selectedIcon;
				
				if ( !newApplicationIcon )
					return;
				
				newIconResourceVO = new ResourceVO( applicationVO.id );
				
				newIconResourceVO.name = "Application Icon";
				newIconResourceVO.setData( newApplicationIcon );
				newIconResourceVO.setType( "png" );
				
				sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
			}
			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_CHANGE_VIEW );
		}
		
		
	}
}
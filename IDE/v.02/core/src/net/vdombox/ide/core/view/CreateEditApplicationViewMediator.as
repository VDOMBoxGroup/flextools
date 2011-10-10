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
		
		private var newApplicationInformation : Object;
		
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
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_CREATE_VIEW );
			interests.push( ApplicationFacade.RESOURCE_LOADED );
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			interests.push( ApplicationFacade.SERVER_APPLICATION_CREATED);	
			
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
					
				case ApplicationFacade.OPEN_APPLICATION_IN_CREATE_VIEW:
				{
					applicationVO = null;
					
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
					trace("RESOURCE_SETTED")
					resourceVO = body as ResourceVO;
					
					if ( resourceVO == newIconResourceVO )
					{
						newIconResourceVO = null;
						
						applicationInformationVO.iconID = resourceVO.id;
						
						trace("send EDIT_APPLICATION_INFORMATION");
						sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
							applicationInformationVO: applicationInformationVO } );
						
						applicationInformationVO = null;
					}
					
					break;
				}
					
				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
				{
					facade.removeMediator( mediatorName );
					
					break;
				}	
					
				case ApplicationFacade.SERVER_APPLICATION_CREATED:
				{
					var newAppIcon : ByteArray;
					
					applicationVO = body as ApplicationVO;
					
					// get icon, selected or default
					newAppIcon = iconChooserMediator.selectedIcon ? iconChooserMediator.selectedIcon : iconChooserMediator.defaultIcon;
					
					newIconResourceVO = createIconResourceVO( newAppIcon ); 
					
					sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
					
					break
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
				
				if ( applicationVO.scriptingLanguage == "python" )
					createEditApplicationView.python.selected = true;
				else
					createEditApplicationView.vbscript.selected = true;
				
				createEditApplicationView.iconChooser.selectedIcon.source = null;
				
				if ( applicationVO.iconID )
				{
					var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );
					resourceVO.setID( applicationVO.iconID );
				
					sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
				}
			}
			else
			{
				createEditApplicationView.txtapplicationName.text = "";
				createEditApplicationView.txtapplicationDescription.text = "";
				createEditApplicationView.iconChooser.selectedIcon.source = null;
				
				createEditApplicationView.python.selected = true;
				createEditApplicationView.vbscript.selected = false;
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
			createEditApplicationView.addEventListener( ApplicationManagerWindowEvent.CANCEL, cancelInformationHandler );
			facade.registerMediator( new IconChooserMediator( createEditApplicationView.iconChooser ) );
		}
		
		private function removeHandlers() : void
		{
			createEditApplicationView.removeEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			createEditApplicationView.removeEventListener( ApplicationManagerWindowEvent.CANCEL, cancelInformationHandler );
			facade.removeMediator( IconChooserMediator.NAME );
		}
		
		private var applicationInformationVO : ApplicationInformationVO ;
		private function saveInformationHandler( event : ApplicationManagerWindowEvent ) : void
		{
			var newAppIcon : ByteArray ;
			applicationInformationVO = getApplicationInformationVO();
			
			if (applicationInformationVO.name == "" )
				return;
			
			// if is editing of  applicationVO
			if ( applicationVO )
			{
				//Icon
				 newAppIcon = iconChooserMediator.selectedIcon;
				
				if ( newAppIcon )
				{
					newIconResourceVO = createIconResourceVO( newAppIcon ); 
				
					sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
				}
				else
				{
					sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
						applicationInformationVO: applicationInformationVO } );
					
				}
			}
			else // creating new applicationVO
			{
				sendNotification( ApplicationFacade.CREATE_APPLICATION, applicationInformationVO );
			}

			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_CHANGE_VIEW );
		}
		
		private function cancelInformationHandler( event : ApplicationManagerWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_APPLICATION_IN_CHANGE_VIEW );
		}
		
		private function getApplicationInformationVO() : ApplicationInformationVO
		{
			trace("getApplicationInformationVO");
			var appInfVO : ApplicationInformationVO = new ApplicationInformationVO();
			
			appInfVO = new ApplicationInformationVO()
			appInfVO.name = createEditApplicationView.txtapplicationName.text;
			appInfVO.description = createEditApplicationView.txtapplicationDescription.text;
			appInfVO.scriptingLanguage = createEditApplicationView.languageRBGroup.selectedValue.toString();
			
			return appInfVO;
		}
		
		private function  get iconChooserMediator():IconChooserMediator
		{
			return facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;
		}
		
		private function createIconResourceVO( icon : ByteArray ):ResourceVO
		{
			trace("createIconResourceVO")
			var resourceVO: ResourceVO = new ResourceVO( applicationVO.id );
			
			resourceVO.name = "Application Icon";
			resourceVO.setData( icon );
			resourceVO.setType( "png" );
			
			return resourceVO;
		}
		
	}
}
package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.events.EditApplicationViewEvent;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;
	import net.vdombox.ide.modules.applicationsManagment.view.components.EditApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class EditApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EditApplicationViewMediator";

		public function EditApplicationViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private const ACTIONS_TEMPLATE : String = "Actions for {0}";

		private const PO_TEMPLATE : String = "PAGES: {0}\nOBJECTS: {1}";

		private var settings : SettingsVO;

		private var applications : Array;

		private var applicationsChanged : Boolean;

		private var selectedApplicationVO : ApplicationVO;

		private var selectedApplicationChanged : Boolean;

		private var newIconResourceVO : ResourceVO;

		override public function onRegister() : void
		{
			addEventListeners();

			if ( facade.hasMediator( IconChooserMediator.NAME ) )
				facade.removeMediator( IconChooserMediator.NAME );

			facade.registerMediator( new IconChooserMediator( editApplicationView.iconChooser ) );

			applicationsList.itemRenderer = new ClassFactory( ApplicationItemRenderer );

			sendNotification( ApplicationFacade.GET_SETTINGS, mediatorName );
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
			sendNotification( ApplicationFacade.GET_TYPES );
		}

		override public function onRemove() : void
		{
			removeEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.APPLICATIONS_LIST_GETTED );
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );

			interests.push( ApplicationFacade.SETTINGS_GETTED + "/" + mediatorName );
			interests.push( ApplicationFacade.SETTINGS_CHANGED );

			interests.push( ApplicationFacade.APPLICATION_EDITED );
			interests.push( ApplicationFacade.APPLICATION_CREATED );
			interests.push( ApplicationFacade.RESOURCE_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var applicationVO : ApplicationVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.APPLICATIONS_LIST_GETTED:
				{
					applications = notification.getBody() as Array;
					applicationsChanged = true;
					selectedApplicationChanged = true;

					break;
				}

				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					var newSelectedApplication : ApplicationVO = notification.getBody() as ApplicationVO;

					if ( newSelectedApplication && newSelectedApplication == selectedApplicationVO )
						return;

					selectedApplicationVO = newSelectedApplication;
					selectedApplicationChanged = true;

					break;
				}

				case ApplicationFacade.SETTINGS_GETTED + "/" + mediatorName:
				{
					settings = body as SettingsVO;

					selectedApplicationChanged = true;

					break;
				}

				case ApplicationFacade.SETTINGS_CHANGED:
				{
					selectedApplicationChanged = true;

					break;
				}

				case ApplicationFacade.APPLICATION_EDITED:
				{
					applicationVO = body as ApplicationVO;

					if ( applicationVO === selectedApplicationVO )
						refreshApplicationProperties();

					break;
				}

				case ApplicationFacade.APPLICATION_CREATED:
				{
					applicationVO = body as ApplicationVO;

					if ( applicationVO )
						editApplicationView.applicationsList.dataProvider.addItem( applicationVO );

					break;
				}

				case ApplicationFacade.RESOURCE_SETTED:
				{
					var resourceVO : ResourceVO = body as ResourceVO;

					if ( resourceVO == newIconResourceVO )
					{
						newIconResourceVO = null;

						var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
						applicationInformationVO.iconID = resourceVO.id;

						sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: selectedApplicationVO,
											  applicationInformationVO: applicationInformationVO } );
					}
					if ( applicationVO )
						editApplicationView.applicationsList.dataProvider.addItem( applicationVO );

					break;
				}
			}

			commitProperties();
		}

		private function get editApplicationView() : EditApplicationView
		{
			return viewComponent as EditApplicationView;
		}

		private function get applicationsList() : List
		{
			return editApplicationView.applicationsList;
		}

		private function addEventListeners() : void
		{
			editApplicationView.addEventListener( EditApplicationViewEvent.APPLICATION_NAME_CHANGED,
												  applicationNameChangedHandler );
			editApplicationView.addEventListener( EditApplicationViewEvent.APPLICATION_DESCRIPTION_CHANGED,
												  applicationDescriptionChangedHandler );

			editApplicationView.addEventListener( EditApplicationViewEvent.APPLICATION_ICON_CHANGED,
												  applicationIconChangedHandler )

			editApplicationView.addEventListener( EditApplicationViewEvent.APPLICATION_LANGUAGE_CHANGED,
												  applicationLanguageChangedHandler )

			applicationsList.addEventListener( ApplicationItemRenderer.RENDERER_CREATED, applicationItemRenderer_rendererCreatedHandler,
											   true );

			applicationsList.addEventListener( IndexChangeEvent.CHANGE, applicationsList_changeHandler );
		}

		private function removeEventListeners() : void
		{
			editApplicationView.removeEventListener( EditApplicationViewEvent.APPLICATION_NAME_CHANGED,
													 applicationNameChangedHandler );
			editApplicationView.removeEventListener( EditApplicationViewEvent.APPLICATION_DESCRIPTION_CHANGED,
													 applicationDescriptionChangedHandler );

			editApplicationView.removeEventListener( EditApplicationViewEvent.APPLICATION_ICON_CHANGED,
													 applicationDescriptionChangedHandler )

			editApplicationView.removeEventListener( EditApplicationViewEvent.APPLICATION_LANGUAGE_CHANGED,
													 applicationLanguageChangedHandler )

			applicationsList.removeEventListener( ApplicationItemRenderer.RENDERER_CREATED, applicationItemRenderer_rendererCreatedHandler,
												  true );

			applicationsList.removeEventListener( IndexChangeEvent.CHANGE, applicationsList_changeHandler );
		}

		private function commitProperties() : void
		{
			if ( applicationsChanged )
			{
				applicationsChanged = false;

				applicationsList.dataProvider = new ArrayList( applications );
			}

			if ( selectedApplicationChanged )
			{
				selectedApplicationChanged = false;

				if ( selectedApplicationVO )
				{
					applicationsList.selectedItem = selectedApplicationVO;

					refreshApplicationProperties();

					if ( settings && settings.saveLastApplication && settings.lastApplicationID != selectedApplicationVO.id )
					{
						settings.lastApplicationID = selectedApplicationVO.id
					}

					sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, selectedApplicationVO );
				}
				else
				{
					var newSelectedApplication : ApplicationVO;

					if ( !applications || applications.length == 0 )
						return;

					if ( settings )
					{
						for ( var i : int = 0; i < applications.length; i++ )
						{
							if ( applications[ i ].id == settings.lastApplicationID )
							{
								newSelectedApplication = applications[ i ];
								break;
							}
						}
						
						
					}
					
					if( !newSelectedApplication )
						newSelectedApplication = applications[ 0 ];

					sendNotification( ApplicationFacade.SET_SELECTED_APPLICATION, newSelectedApplication );
				}
			}
		}

		private function refreshApplicationProperties() : void
		{
			editApplicationView.applicationName.text = selectedApplicationVO.name;
			editApplicationView.newApplicationName.text = selectedApplicationVO.name;

			editApplicationView.actionsForLabel.text = StringUtil.substitute( ACTIONS_TEMPLATE, selectedApplicationVO.name );

			editApplicationView.counts.text = StringUtil.substitute( PO_TEMPLATE, selectedApplicationVO.numberOfPages,
																	 selectedApplicationVO.numberOfObjects );

			editApplicationView.applicationDescription.text = selectedApplicationVO.description;
			editApplicationView.newApplicationDescription.text = selectedApplicationVO.description;

			editApplicationView.iconChooser.iconsList.selectedIndex = -1;
			editApplicationView.iconChooser.selectedIcon.source = null;

			if ( selectedApplicationVO.scriptingLanguage == "python" )
				editApplicationView.python.selected = true;
			else
				editApplicationView.vbscript.selected = true;
			
		}

		private function applicationNameChangedHandler( event : EditApplicationViewEvent ) : void
		{
			var newApplicationName : String = editApplicationView.newApplicationName.text;

			if ( newApplicationName && newApplicationName == selectedApplicationVO.name )
				return;

			var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO;
			applicationInformationVO.name = newApplicationName;

			sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: selectedApplicationVO,
								  applicationInformationVO: applicationInformationVO } );
		}

		private function applicationDescriptionChangedHandler( event : EditApplicationViewEvent ) : void
		{
			var newApplicationDescription : String = editApplicationView.newApplicationDescription.text;

			if ( newApplicationDescription && newApplicationDescription == selectedApplicationVO.description )
				return;

			var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO;
			applicationInformationVO.description = newApplicationDescription;

			sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: selectedApplicationVO,
								  applicationInformationVO: applicationInformationVO } );
		}

		private function applicationIconChangedHandler( event : EditApplicationViewEvent ) : void
		{
			var iconChooserMediator : IconChooserMediator = facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;

			var newApplicationIcon : ByteArray = iconChooserMediator.selectedIcon;

			if ( !newApplicationIcon )
				return;

			newIconResourceVO = new ResourceVO( selectedApplicationVO.id );

			newIconResourceVO.name = "Application Icon";
			newIconResourceVO.setData( newApplicationIcon );
			newIconResourceVO.setType( "png" );

			sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
		}

		private function applicationLanguageChangedHandler( event : EditApplicationViewEvent ) : void
		{
			var newApplicationLanguage : String = editApplicationView.languageRBGroup.selectedValue.toString();

			if ( newApplicationLanguage && newApplicationLanguage == selectedApplicationVO.scriptingLanguage )
				return;

			var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO;
			applicationInformationVO.scriptingLanguage = newApplicationLanguage;

			sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: selectedApplicationVO,
								  applicationInformationVO: applicationInformationVO } );
		}

		private function applicationItemRenderer_rendererCreatedHandler( event : Event ) : void
		{
			var renderer : ApplicationItemRenderer = event.target as ApplicationItemRenderer;

			var mediator : ApplicationItemRendererMediator = new ApplicationItemRendererMediator( renderer );
			facade.registerMediator( mediator );
		}

		private function applicationsList_changeHandler( event : IndexChangeEvent ) : void
		{
			var newSelectedApplication : ApplicationVO;
			editApplicationView.currentState = "default";

			if ( event.newIndex != -1 )
				newSelectedApplication = applications[ event.newIndex ] as ApplicationVO;

			if ( selectedApplicationVO != newSelectedApplication )
			{
				selectedApplicationVO = newSelectedApplication;
				selectedApplicationChanged = true;
				commitProperties();
			}
		}
	}
}
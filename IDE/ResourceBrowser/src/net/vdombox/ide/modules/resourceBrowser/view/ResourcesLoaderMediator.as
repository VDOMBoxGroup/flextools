package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.events.FileListEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.events.ResourcesLoaderEvent;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.ResourcesLoader;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ResourcesLoaderMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoadResourcesViewMediator";

		public function ResourcesLoaderMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public function get resourcesLoader() : ResourcesLoader
		{
			return viewComponent as ResourcesLoader;
		}

		private var statesProxy : StatesProxy;

		private var isActive : Boolean;

		private var file : File;

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.RESOURCE_UPLOADED );
			interests.push( Notifications.RESOURCES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( notification.getName() )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case Notifications.RESOURCES_GETTED:
				{
					break;
				}

				case Notifications.RESOURCE_UPLOADED:
				{
					var resourceVO : ResourceVO = body as ResourceVO;

					if ( !resourceVO || resourcesLoader.resourcesArrayList && resourcesLoader.resourcesArrayList.length > 0 )
					{
						var resourceItemsArray : Array = resourcesLoader.resourcesArrayList.source;
						var currentResourceVO : ResourceVO;

						for ( var i : uint = 0; i < resourceItemsArray.length; i++ )
						{
							currentResourceVO = resourceItemsArray[ i ] as ResourceVO;

							if ( currentResourceVO && currentResourceVO.id == resourceVO.id )
							{
								resourcesLoader.resourcesArrayList.removeItem( currentResourceVO );
								break;
							}
						}
					}

					uploadResource();

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			resourcesLoader.addResourcesGroup.addEventListener( MouseEvent.CLICK, addResourcesGroup_clickHandler );
			resourcesLoader.addEventListener( ResourcesLoaderEvent.START_UPLOAD, startUploadHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			resourcesLoader.removeEventListener( ResourcesLoaderEvent.START_UPLOAD, startUploadHandler );
		}

		private function clearData() : void
		{
			resourcesLoader.resourcesArrayList.removeAll();
		}

		private function uploadResource() : void
		{
			var resourceVO : ResourceVO;

			if ( !statesProxy.selectedApplication )
				return;

			if ( resourcesLoader.resourcesArrayList.length > 0 )
				resourceVO = resourcesLoader.resourcesArrayList.getItemAt( 0 ) as ResourceVO;

			if ( resourceVO )
				sendNotification( Notifications.UPLOAD_RESOURCE, resourceVO );
		}

		private function addResourcesGroup_clickHandler( event : MouseEvent ) : void
		{
			file = new File();

			file.addEventListener( FileListEvent.SELECT_MULTIPLE, file_selectMulitpleHandler, false, 0, true );
			file.browseForOpenMultiple( "----Перевести------" );
		}

		private function file_selectMulitpleHandler( event : FileListEvent ) : void
		{
			if ( file )
			{
				file.removeEventListener( FileListEvent.SELECT_MULTIPLE, file_selectMulitpleHandler );
				file = null;
			}

			var files : Array = event.files;

			if ( !statesProxy.selectedApplication || !files || files.length == 0 )
				return;

			var uploadedFile : File;
			var newResourceVO : ResourceVO;

			for ( var i : uint = 0; i < files.length; i++ )
			{
				uploadedFile = files[ i ] as File;

				if ( uploadedFile )
				{
					newResourceVO = new ResourceVO( statesProxy.selectedApplication.id );

					newResourceVO.name = uploadedFile.name;
					newResourceVO.setPath( uploadedFile.nativePath );
					newResourceVO.setType( uploadedFile[ "extension" ].toLowerCase() ); //dirty hack;

					resourcesLoader.resourcesArrayList.addItem( newResourceVO );
				}
			}
		}

		private function startUploadHandler( event : ResourcesLoaderEvent ) : void
		{
			uploadResource();
		}
	}
}

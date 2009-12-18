package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.graphics.codec.PNGEncoder;
	
	import net.vdombox.ide.common.vo.ApplicationPropertiesVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.events.CreateApplicationViewEvent;
	import net.vdombox.ide.modules.applicationsManagment.model.GalleryProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.GalleryItemVO;
	import net.vdombox.ide.modules.applicationsManagment.view.components.CreateApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.TextInput;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;

	public class CreateApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateApplicationMediator";

		public function CreateApplicationViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var loader : Loader;
		
		override public function onRegister() : void
		{
			createApplication.addEventListener( FlexEvent.SHOW, creationCompleteHandler );
			
			createApplication.addEventListener( CreateApplicationViewEvent.SHOW_ICONS_GALLERY, showIconsGalleryHandler );
			createApplication.addEventListener( CreateApplicationViewEvent.LOAD_ICON,loadIconHandler );
			createApplication.addEventListener( CreateApplicationViewEvent.SAVE, saveHandler );
			createApplication.addEventListener( CreateApplicationViewEvent.CANCEL, cancelHandler );
		}

		private function get createApplication() : CreateApplicationView
		{
			return viewComponent as CreateApplicationView
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			createApplication.itemList.addEventListener( IndexChangeEvent.CHANGE, itemList_changeHandler );
			createApplication.nameField.addEventListener( TextOperationEvent.CHANGE, nameField_changeHandler );
		}

		private function showIconsGalleryHandler( event : CreateApplicationViewEvent ) : void
		{
			if ( createApplication.currentState == "default" )
			{
				createApplication.currentState = "gallery";

				var gp : GalleryProxy = facade.retrieveProxy( GalleryProxy.NAME ) as GalleryProxy;
				createApplication.itemList.dataProvider = new ArrayList( gp.items );
			}
			else
			{
				createApplication.currentState = "default";
			}
		}
		
		private function loadIconHandler( CreateApplicationEvent : Event ) : void
		{
			createApplication.currentState = "default";
			
			var file : File = new File();
			var fileFilter : FileFilter = new FileFilter( "Image", "*.jpg;*.jpeg;*.gif;*.png" );
			
			file.addEventListener( Event.SELECT, file_selectHandler );
			file.browseForOpen( "Load image", [ fileFilter ]);
		}
		
		private function saveHandler( event : CreateApplicationViewEvent ) : void
		{
			var name : String = createApplication.nameField.text;
			var description : String = createApplication.descriptionField.text;
			var icon : ByteArray = createApplication.selectedIcon.source as ByteArray;
			
			sendNotification( ApplicationFacade.NEW_APP_PROPS_SUBMITTED, { name : name, description : description, icon : icon } );
		}
		
		private function cancelHandler( event : CreateApplicationViewEvent ) : void
		{
			sendNotification( ApplicationFacade.NEW_APP_PROPS_CANCELED );
		}
		
		private function itemList_changeHandler( event : IndexChangeEvent ) : void
		{
			var d : GalleryItemVO = event.currentTarget.selectedItem as GalleryItemVO;
			createApplication.selectedIcon.source = d.content;
		}

		private function file_selectHandler( event : Event ) : void
		{
			var file : File = event.currentTarget as File;
			
			if ( !file || !file.exists )
				return;
			
			file.removeEventListener( Event.SELECT, file_selectHandler );
			
			var fileStream : FileStream = new FileStream();
			var byteArray : ByteArray = new ByteArray();
			
			try
			{
				fileStream.open( file, FileMode.READ );
				fileStream.readBytes( byteArray );
			}
			catch ( error : Error )
			{
				return;
			}
			
			if ( byteArray.length > 0 )
			{
				loader = new Loader();
				
				loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loader_completeHandler );
				loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loader_ioErrorHandler );
				
				loader.loadBytes( byteArray );
			}
		}		

		private function loader_completeHandler( event : Event ) : void
		{
			var image : Bitmap = loader.content as Bitmap;
			
			var matrix : Matrix = new Matrix();
			var scaleX : Number = 55 / image.width;
			var scaleY : Number = 55 / image.height;

			matrix.scale( scaleX, scaleY );
			var scaledImage : Bitmap = new Bitmap( new BitmapData( 55, 55, true, 0x00ffffff ), PixelSnapping.AUTO, true );
			scaledImage.bitmapData.draw( image.bitmapData, matrix );

			var pnge : PNGEncoder = new PNGEncoder();
			var iconByteArray : ByteArray = pnge.encode( scaledImage.bitmapData );

			createApplication.selectedIcon.source = iconByteArray;
		}

		private function loader_ioErrorHandler( event : IOErrorEvent ) : void
		{
			return;
		}
		
		private function nameField_changeHandler( event : TextOperationEvent ) : void
		{
			var nameField : TextInput = event.currentTarget as TextInput;
			
			if ( nameField.text == "" && createApplication.saveButton.enabled )
				createApplication.saveButton.enabled = false;
			else if ( nameField.text != "" && !createApplication.saveButton.enabled )
				createApplication.saveButton.enabled = true;
				
		}
	}
}
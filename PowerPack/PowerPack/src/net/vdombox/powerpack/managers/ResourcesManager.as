/**
 * Created with IntelliJ IDEA.
 * User: salova oo
 * Date: 13.05.13
 * Time: 14:27
 * To change this template use File | Settings | File Templates.
 */
package net.vdombox.powerpack.managers
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.utils.ByteArray;
import mx.utils.Base64Encoder;
import mx.utils.UIDUtil;
import net.vdombox.powerpack.events.ResourcesEvent;
import net.vdombox.powerpack.template.BuilderTemplate;

public class ResourcesManager extends EventDispatcher
{

	private static var instance : ResourcesManager;

	public function ResourcesManager()
	{
		if ( instance )
			throw new Error( "Singleton and can only be accessed through ResourcesUtils.getInstance()" );
	}

	public static function getInstance() : ResourcesManager
	{
		return instance || ( instance = new ResourcesManager());
	}

	public function addResource () : void
	{
		var folder : File = new File (File.desktopDirectory.nativePath);
		var selectedResource : File;

		selectResource();

		function selectResource () : void
		{
			folder.addEventListener(Event.SELECT, resourceSelectHandler);
			folder.addEventListener(Event.CANCEL, resourceCancelHandler);

			folder.browseForOpen("Select resource");
		}

		function resourceSelectHandler (event : Event) : void
		{
			folder.removeEventListener(Event.SELECT, resourceSelectHandler);
			folder.removeEventListener(Event.CANCEL, resourceCancelHandler);

			selectedResource = event.target as File;

			selectedResource.addEventListener(Event.COMPLETE, loadCompleteHandler);
			selectedResource.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			selectedResource.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);

			selectedResource.load();
		}

		function resourceCancelHandler (event : Event) : void
		{
			folder.removeEventListener(Event.CANCEL, resourceCancelHandler);

			if (selectedResource)
			{
				selectedResource.removeEventListener(Event.COMPLETE, loadCompleteHandler);
				selectedResource.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
				selectedResource.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
			}

			dispatchEvent( new ResourcesEvent(ResourcesEvent.CANCEL) );
		}

		function loadErrorHandler (event : Event) : void
		{
			folder.removeEventListener(Event.CANCEL, resourceCancelHandler);

			selectedResource.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			selectedResource.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			selectedResource.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);

			dispatchEvent( new ResourcesEvent(ResourcesEvent.ERROR, "", "Error loading resource.") );
		}

		function loadCompleteHandler (event : Event) : void
		{
			folder.removeEventListener(Event.CANCEL, resourceCancelHandler);

			selectedResource.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			selectedResource.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
			selectedResource.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);

			var resourceData : ByteArray = selectedResource.data;
			resourceData.position = 0;

			var encoder : Base64Encoder = new Base64Encoder();
			encoder.insertNewLines = false;
			encoder.encodeBytes( resourceData );
			var b64Data : String = encoder.flush();

			var data : ByteArray = new ByteArray();
			data.writeUTFBytes( b64Data );

			var resourceID : String = createResource(selectedResource.name, selectedResource.extension, data);

			dispatchEvent( new ResourcesEvent(ResourcesEvent.COMPLETE, resourceID) );
		}
	}

	public function createResource(name: String, type : String, data : ByteArray) : String
	{
		var ID : String = UIDUtil.createUID();
		var name : String = !name ? ID + "." + type : name;

		if (!type)
			type = "";

		var category : String = CashManager.typeCategoryMap.hasOwnProperty(type) ? CashManager.typeCategoryMap[type] : CashManager.typeCategoryMap["other"];

		if (currentTemplate)
			CashManager.setObject( currentTemplate.fullID, <object category={category} ID={ID} name={name} type={type} />, data );

		dispatchEvent( new ResourcesEvent(ResourcesEvent.CHANGED) );

		return ID;
	}

	public function removeResource( id : String ) : void
	{
		if (!currentTemplate)
			return;

		CashManager.removeObject( currentTemplate.fullID, id );

		dispatchEvent( new ResourcesEvent(ResourcesEvent.CHANGED) );
	}

	public function get allResources() : XMLList
	{
		if (!currentTemplate)
			return null;

		var objIndex : XML = CashManager.getIndex( currentTemplate.fullID );

		if ( !objIndex )
			return null;

		return objIndex.resource.(hasOwnProperty( '@category' ) && @category == 'image' || @category == 'database');
	}

	private function get currentTemplate() : BuilderTemplate
	{
		return BuilderContextManager.currentTemplate;
	}


}
}

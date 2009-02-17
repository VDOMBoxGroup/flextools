// ActionScript file
import flash.events.Event;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.controls.Alert;
import mx.core.Application;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

import vdom.controls.resourceBrowser.ListItemEvent;
import vdom.controls.resourceBrowser.TypesIcons;
import vdom.events.FileManagerEvent;
import vdom.events.ResourceBrowserEvent;
import vdom.managers.DataManager;
import vdom.managers.FileManager;

/**
 * Resource Browser component action script file.
 * Developed by Vadim A. Usoltsev, Tomsk, Russia, 2008
 **/

private const defaultView : String = "list";


/**
 * Variables
 **/

/*
   Selected resource ID sets by property "selectedItemID" from the outside the Class.
   It is used to show which item is currently selected (or not, if it is null).
 */
private var typesIcons : TypesIcons = new TypesIcons();
private var _selectedItemID : String = '';
private var allResourcesList : XML; // XML, Getting by FileManager Class instance
private var rTypes : Array; // Avalible resources types (get during resources scanning)
private var fileForUpload : File;
private var resourcesListLoadedFlag : Boolean = false;
private var fileManager : FileManager = FileManager.getInstance(); // FileManager global Class instance
private var dataManager : DataManager = DataManager.getInstance();

[Bindable]
private var filterDataProvider : Array;

private var listDataProvider : Array; /* of Object */

[Bindable]
private var totalResources : int = 0;

[Bindable]
private var filteredResources : int = 0;

private var resourcesListDataProvider : XML = new XML(
	<Resources/>
	)

private var firstFilterClickFlag : Boolean = true;
private var timer : Timer = new Timer(1200, 1);

private var resourceIDForDelete : String = "";

public function set selectedItemID(itemID : String) : void
{
	_selectedItemID = itemID;

	if (resourcesListLoadedFlag)
	{
		applyExtensionFilter();
		showResource();
	}
}

public function get selectedItemID() : String
{
	return _selectedItemID;
}

private function registerEvent(flag : Boolean) : void
{
	if (flag)
	{
		addEventListener(CloseEvent.CLOSE, closeHandler);

		Application.application.addEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);

		__thumbsList.addEventListener(ListItemEvent.DELETE_RESOURCE, deleteResourceHandler);

		fileManager.addEventListener(FileManagerEvent.RESOURCE_DELETED, fileManager_resourceDeletedHandler);
		fileManager.addEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, fileManager_resourceListLoadedHandler);
		fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
		fileManager.addEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR, fileManager_resourceSavedErrorHandler);
	}
	else
	{
		removeEventListener(CloseEvent.CLOSE, closeHandler);

		Application.application.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressHandler);

		__thumbsList.removeEventListener(ListItemEvent.DELETE_RESOURCE, deleteResourceHandler);

		fileManager.removeEventListener(FileManagerEvent.RESOURCE_DELETED, fileManager_resourceDeletedHandler);
		fileManager.removeEventListener(FileManagerEvent.RESOURCE_LIST_LOADED, fileManager_resourceListLoadedHandler);
		fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED, fileManager_resourceSavedHandler);
		fileManager.removeEventListener(FileManagerEvent.RESOURCE_SAVED_ERROR, fileManager_resourceSavedErrorHandler);
		
		if( timer )
			timer.removeEventListener(TimerEvent.TIMER, nameFilterOnTheFly);
		if( fileForUpload )
			fileForUpload.removeEventListener(Event.SELECT, fileForUpload_selectHandler);
		if( __preview )
			__preview.removeEventListener(Event.COMPLETE, setImageProperties);
	}
}

private function listResourcesQuery() : void
{
	fileManager.getListResources();
}

private function doneHandler() : void
{
	if (__thumbsList.selectedItem)
		this.dispatchEvent(ResourceBrowserEvent(new ResourceBrowserEvent(ResourceBrowserEvent.RESOURCE_SELECTED,
																		 __thumbsList.selectedItem.@id,
																		 __thumbsList.selectedItem.@name)));

	var cEvent : CloseEvent = new CloseEvent(CloseEvent.CLOSE);
	this.dispatchEvent(cEvent);
}

private function determineResourcesTypes() : void
{
	rTypes = [];

	try
	{
		for each (var resource : XML in allResourcesList.Resource)
		{
			rTypes[resource.@type] = resource.@type;
		}
	}
	catch (err : Error)
	{
		return ;
	}

	createFilters();
}


private function createFilters() : void
{
	filterDataProvider = [];

	filterDataProvider.push({label : 'None', data : '*'});

	for each (var type : String in rTypes)
	{
		filterDataProvider.push({label : type.toUpperCase(), data : type.toLowerCase()});
	}

	__filterCBx.selectedIndex = 0;
	__filterCBx.selectedItem = __filterCBx.selectedItem; // :-) Don't worry, it's ok! Just in case...
	applyExtensionFilter(); //  !!!  Create actual thumbs (at start and later)  !!!
}

private function applyExtensionFilter() : void
{
	var i : int = 0;

	filteredResources = 0;

	if (__filterCBx.selectedItem.data == '*')
	{

		resourcesListDataProvider = allResourcesList;

	}
	else
	{

		var newResourcesList : XML = new XML(
			<Resources/>
			);


		for each (var resourceItem : XML in allResourcesList.Resource)
		{
			if (resourceItem.@type == __filterCBx.selectedItem.data)
			{
				filteredResources++;
				newResourcesList.appendChild(resourceItem);
			}
		}

		resourcesListDataProvider = newResourcesList;

	}

	__thumbsList.dataProvider = resourcesListDataProvider.Resource;
	for (i = 0; i < resourcesListDataProvider.Resource.length(); i++)
	{
		if (resourcesListDataProvider.Resource[i].@id == _selectedItemID)
		{
			__thumbsList.selectedIndex = i;
			break;
		}
	}
}

private function nameFilterOnTheFly(e : Event) : void
{
	timer.removeEventListener(TimerEvent.TIMER, nameFilterOnTheFly);
	timer.stop();

	if (__nameFilter.text == '')
	{
		applyExtensionFilter();
		__spinner.visible = false;
		return ;
	}

	var tempResourcesList : XML = new XML(
		<Resources/>
		);
	filteredResources = 0;

	for each (var resourceItem : XML in resourcesListDataProvider.Resource)
	{
		if (String(resourceItem.@name).toLowerCase().indexOf(__nameFilter.text.toLowerCase()) >= 0)
		{
			filteredResources++;
			tempResourcesList.appendChild(resourceItem);
		}
	}

	__thumbsList.dataProvider = tempResourcesList.Resource;

	for (var i : int = 0; i < tempResourcesList.Resource.length(); i++)
	{
		if (tempResourcesList.Resource[i].@id == _selectedItemID)
		{
			__thumbsList.selectedIndex = i;
			break;
		}
	}

	__spinner.visible = false;
}

private function showResource() : void
{

	if (!__thumbsList.selectedItem)
	{
		__rName.text = 'No item selected';
		__rType.text = '---';
		__rID.text = 'Unknown resource ID';
		__iResolution.text = "Can not determine";
		__preview.__image.source = null; //typesIcons.spinnerbox;
		return ;
	}

	_selectedItemID = __thumbsList.selectedItem.@id;

	/* Fill in resource information in the info area */
	__rName.text = __thumbsList.selectedItem.@name;
	__rType.text = String(__thumbsList.selectedItem.@type).toUpperCase();
	__rID.text = 'ID: ' + __thumbsList.selectedItem.@id;

	if (typesIcons.isViewable(__thumbsList.selectedItem.@type))
	{

		__preview.__image.source = typesIcons.spinner;
		__preview.addEventListener(Event.COMPLETE, setImageProperties);
		__preview.objID = __thumbsList.selectedItem.@id;

	}
	else
	{

		if (typesIcons.icon[__thumbsList.selectedItem.@type])
			__preview.imageSource = typesIcons.icon[__thumbsList.selectedItem.@type];
		else
			__preview.imageSource = typesIcons.blank_Icon;

		__iResolution.text = "Can not determine";
	}
}


private function setImageProperties(event : Event) : void
{
	__iResolution.text = event.currentTarget.imageWidth.toString() + " x " + event.currentTarget.imageHeight.toString();
}

private function creationCompleteHandler() : void
{
	registerEvent(true);
	callLater(listResourcesQuery);
}

private function keyPressHandler(keybEvent : KeyboardEvent) : void
{
	switch (keybEvent.keyCode)
	{
		case 27 : /* Escape Press */ 
			closeHandler(new CloseEvent(CloseEvent.CLOSE));
			break;
		case 13 : /* Enter Press */ 
			doneHandler();
			break;
	}
}

private function closeHandler(cEvent : CloseEvent) : void
{
	registerEvent(false);
	PopUpManager.removePopUp(this);
}

private function nameFilter_clickHandler() : void
{
	if (firstFilterClickFlag)
	{
		__nameFilter.text = '';
		firstFilterClickFlag = false;
	}
}

private function nameFilter_changeHandler() : void
{
	timer.addEventListener(TimerEvent.TIMER_COMPLETE, nameFilterOnTheFly);
	timer.reset();
	timer.start();
	__spinner.visible = true;
}

private function deleteResourceHandler(event : ListItemEvent) : void
{
	resourceIDForDelete = event.resourceID;
	Alert.show("Delete resource: " + event.resourceName + "?", "Alert!", Alert.YES | Alert.NO,
			   this, acceptDeleteHandler)
}

private function acceptDeleteHandler(event : CloseEvent) : void
{
	if (event.detail == Alert.YES)
	{
		fileManager.deleteResource(resourceIDForDelete);
	}

	resourceIDForDelete = "";
}

private function uploadButton_clickHandler() : void
{
	if (fileForUpload == null)
	{
		fileForUpload = new File();
	}

	var allFilesFilter : FileFilter = new FileFilter("All Files (*.*)", "*.*");
	var imagesFilter : FileFilter = new FileFilter('Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png');
	var docFilter : FileFilter = new FileFilter('Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt');

	fileForUpload.addEventListener(Event.SELECT, fileForUpload_selectHandler);
	fileForUpload.browseForOpen("Choose file to upload", [imagesFilter, docFilter, allFilesFilter]);
}

private function fileForUpload_selectHandler(event : Event) : void
{
	fileForUpload.removeEventListener(Event.SELECT, fileForUpload_selectHandler);

	if (fileForUpload && !fileForUpload.isDirectory)
	{
		var srcBytes : ByteArray = new ByteArray();
		var srcStream : FileStream = new FileStream();

		try
		{

			srcStream.open(fileForUpload, FileMode.READ);

			if (srcStream.bytesAvailable == 0)
			{
				Alert.show("File is empty", "Could not send file");
				return ;
			}

			srcStream.readBytes(srcBytes, 0, srcStream.bytesAvailable);
			srcStream.close();
		}
		catch (err : Error)
		{
			Alert.show('Could not open file!', 'IO Error');
			return ;
		}

		var fileType : String = "";
		try
		{
			fileType = fileForUpload.type.substr(1);
		}
		catch (err : Error)
		{
			fileType = fileForUpload.extension;
		}

		try
		{
			var fileName : String = fileForUpload.name.substr(0, fileForUpload.name.length - fileType.length - 1);
			setResource(fileType, fileName, srcBytes);
		}
		catch (err : Error)
		{
			Alert.show('Unexpected error', 'Could not upload selected resource!');
			return ;
		}
	}
}


private function setResource(resType : String, resName : String, resData : ByteArray) : void
{
	fileManager.setResource(resType, resName, resData);
}


private function fileManager_resourceSavedHandler(fmEvent : FileManagerEvent) : void
{
	try
	{
		var result : XML = XML(fmEvent.result);
		_selectedItemID = result.Resource.@id.toString();
		listResourcesQuery();
	}
	catch (err : Error)
	{
		Alert.show("Unknown response from server", "Resource Id getting error");
	}
}


private function fileManager_resourceSavedErrorHandler(fmEvent : FileManagerEvent) : void
{
	trace('Resource browser: ERROR at sending resource');
	Alert.show("Could not send resource to server!", "Sending resource error");
}

private function fileManager_resourceListLoadedHandler(event : FileManagerEvent) : void
{
	allResourcesList = new XML(event.result.Resources);

	try
	{
		totalResources = allResourcesList.Resource.length();
	}
	catch (err : Error)
	{
		trace("Resource browser exception occured! :: " + err.message);
	}

	resourcesListLoadedFlag = true;
	determineResourcesTypes();
	showResource();
}

private function fileManager_resourceDeletedHandler(event : FileManagerEvent) : void
{
	listResourcesQuery();
}
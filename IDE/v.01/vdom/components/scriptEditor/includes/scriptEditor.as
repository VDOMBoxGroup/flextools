import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;

import vdom.components.scriptEditor.CreatingNewActionWindow;
import vdom.events.DataManagerEvent;
import vdom.events.ScriptEditorEvent;
import vdom.managers.DataManager;

[Bindable]
private var arrAppl : ArrayCollection = new ArrayCollection();

private var dataManager : DataManager = DataManager.getInstance();

private var massIconResouceID : Array = new Array();

private var selectedApplication : Object;

private var curContainerID : String;
private var curContainerTypeID : String;

private var libraries : XMLList;

private var scriptChanged : Boolean = false;
private var librariesChanged : Boolean = false;

private var currentEditing : String;
private var currentLibraryName : String;

override protected function commitProperties() : void
{
	super.commitProperties();

	if ( librariesChanged )
	{
		librariesChanged = false;
		librariesList.dataProvider = libraries;
	}
}

private function createScript( name : String ) : void
{
	var extension : String = "";
	var extStartPosition : int = name.lastIndexOf( "_" );

	if ( extStartPosition != -1 )
		extension = name.substr( extStartPosition );

	var dataXML : XML = new XML( "<Action/>" );

	if ( extension == "_python" )
	{
		dataXML.@Name = name.substr( 0, extStartPosition );
		dataXML.@Language = "python";
	}
	else
	{
		dataXML.@Name = name;
		dataXML.@label = name;
		dataXML.@Language = "vscript";
	}

	dataXML.@Top = "5";
	dataXML.@Left = "5";
	dataXML.@State = "true";

	serverScripts.addScript = dataXML;
	currentEditing = "script";
	textEditor.setFocus();
	save();
}

private function createLibrary( name : String ) : void
{
	dataManager.setLibrary( name, "" );
}

private function editLibrary() : void
{
	saveButton.setStyle( "color", "0x000000" );
	saveButton.setStyle( "borderColor", "0xAAB3B3" );

	var item : XML = librariesList.selectedItem as XML;
	
	if ( item && currentEditing == "library" && currentLibraryName == item.@Name )
		return;

	if ( item )
	{
		textEditor.enabled = true;
		textEditor.text = item.toString();
		currentEditing = "library";
		currentLibraryName = item.@Name
		nameLabel.text = "Library Name: " + currentLibraryName;
	}
	else
	{
		textEditor.enabled = false;
		currentEditing = "none";
		nameLabel.text = currentLibraryName = "";
	}
}

private function getIcon( ID : String ) : String
{
	if ( massIconResouceID[ ID ] )
		return massIconResouceID[ ID ];

	for each ( var lavel : XML in dataManager.getTopLevelTypes() )
	{
		if ( lavel.Information.ID == ID )
		{
			var strLabel : String = lavel.Information.StructureIcon;
			return massIconResouceID[ ID ] = strLabel.substr( 5, 36 );
		}
	}
	return "";
}

private function save() : void
{
	if ( !textEditor.enabled )
		return;

	if ( currentEditing == "script" )
		serverScripts.script = textEditor.text;
	else if ( currentEditing == "library" )
	{
		var data : XML = librariesList.selectedItem as XML;
		var name : String = data.@Name;
		dataManager.setLibrary( name, textEditor.text );
	}

	saveButton.setStyle( "color", "0x000000" );
	saveButton.setStyle( "borderColor", "0xAAB3B3" );

	scriptChanged = false;
}

private function revert() : void
{
	saveButton.setStyle( "color", "0x000000" );
	saveButton.setStyle( "borderColor", "0xAAB3B3" );

	textEditor.text = serverScripts.script;

	scriptChanged = false;
}

private function showHandler() : void
{
	curContainerID = dataManager.currentPageId;
	if ( curContainerID )
	{
		curContainerTypeID = dataManager.getTypeByObjectId( curContainerID ).Information.ID.toString();
	}

	dataManager.addEventListener( DataManagerEvent.PAGE_CHANGED, dataManager_pageChangedHandler );
	dataManager.addEventListener( DataManagerEvent.OBJECT_CHANGED, dataManager_objectChangedHandler );
	dataManager.addEventListener( DataManagerEvent.GET_LIBRARIES_COMPLETE, dataManager_getLibrariesCompleteHandler );
	dataManager.addEventListener( DataManagerEvent.SET_LIBRARY_COMPLETE, dataManager_setLibraryCompleteHandler );
	dataManager.addEventListener( DataManagerEvent.REMOVE_LIBRARY_COMPLETE, dataManager_removeLibraryCompleteHandler );

	dataManager.getLibraries();

	arrAppl.removeAll();
	arrAppl.addItem( { label : "Session Actions", ID : "session", iconResID : "", typeID : "" } );

	for each ( var lavel : XML in dataManager.listPages )
	{
		var ID : String = lavel.@ID;
		var strLabel : String = lavel.Attributes.Attribute.( @Name == "title" );

		var typeID : String = lavel.@Type.toString();
		var iconResID : String = getIcon( typeID );

		arrAppl.addItem( { label : strLabel, ID : ID, iconResID : iconResID, typeID : typeID } );
	}


	var sort : Sort = new Sort();
	sort.fields = [ new SortField( "typeID" ), new SortField( "label", true ) ];
	arrAppl.sort = sort;
	arrAppl.refresh();

	function searchIndex() : int
	{
		var curID : String = dataManager.currentPageId;
		for ( var i : String in arrAppl )
		{
			if ( arrAppl[ i ].ID == curID )
				return Number( i );
		}
		return 0;
	}

	pages.selectedIndex = searchIndex();
	serverScripts.dataProvider = dataManager.currentPageId;
	containersBranch.currentPageID = dataManager.currentPageId;
}

private function hideHandler() : void
{
	dataManager.removeEventListener( DataManagerEvent.PAGE_CHANGED, dataManager_pageChangedHandler );
	dataManager.removeEventListener( DataManagerEvent.OBJECT_CHANGED, dataManager_objectChangedHandler );
	dataManager.removeEventListener( DataManagerEvent.GET_LIBRARIES_COMPLETE, dataManager_getLibrariesCompleteHandler );
	dataManager.removeEventListener( DataManagerEvent.SET_LIBRARY_COMPLETE, dataManager_setLibraryCompleteHandler );
	dataManager.removeEventListener( DataManagerEvent.REMOVE_LIBRARY_COMPLETE, dataManager_removeLibraryCompleteHandler );
}

private function textEditor_keyDownHandler( event : KeyboardEvent ) : void
{
	if ( scriptChanged )
		return;

	saveButton.setStyle( "color", "0xCC0000" );
	saveButton.setStyle( "borderColor", "0xEE0000" );

	scriptChanged = true;
}

private function pages_changeHandler( obj : Object ) : void
{
	selectedApplication = ComboBox( obj ).selectedItem;
	if ( selectedApplication.ID == "session" )
	{
		containersBranch.currentPageID = selectedApplication.ID;
		serverScripts.dataProvider = selectedApplication.ID;
	}
	else
		dataManager.changeCurrentPage( selectedApplication.ID );
}

private function serverScripts_scriptChangedHandler() : void
{
	saveButton.setStyle( "color", "0x000000" );
	saveButton.setStyle( "borderColor", "0xAAB3B3" );

	librariesList.selectedIndex = -1;

	if ( serverScripts.dataEnabled && serverScripts.script != "null" )
	{
		textEditor.enabled = true;
		textEditor.text = serverScripts.script;
		currentEditing = "script";
		nameLabel.text = "Script Name: " + serverScripts.dataEnabled.@Name;
	}
	else
	{
		textEditor.enabled = false;
		currentEditing = "none";
		nameLabel.text = "";
	}
}

private function librariesList_changeHandler( event : ListEvent ) : void
{
	editLibrary();
}

private function librariesList_valueCommitHandler( event : FlexEvent ) : void
{
	editLibrary();
}

private function addScript_clickHandler() : void
{
	var rbWnd : CreatingNewActionWindow = CreatingNewActionWindow( PopUpManager.createPopUp( this,
																							 CreatingNewActionWindow,
																							 true ) );
	rbWnd.name = "addScript";

	rbWnd.addEventListener( ScriptEditorEvent.SET_NAME, setNameHandler );
	rbWnd.inputText.setFocus();
}

private function addLibrary_clickHandler() : void
{
	var rbWnd : CreatingNewActionWindow = CreatingNewActionWindow( PopUpManager.createPopUp( this,
																							 CreatingNewActionWindow,
																							 true ) );
	rbWnd.insertLabel.text = "Input Library name:"
	rbWnd.title = "Add Library";

	rbWnd.name = "addLibrary";

	rbWnd.addEventListener( ScriptEditorEvent.SET_NAME, setNameHandler );
	rbWnd.inputText.setFocus();
}

private function deleteScript_clickHandler() : void
{
	serverScripts.deleteScript();
}

private function deleteLibrary_clickHandler() : void
{
	if ( currentEditing != "library" || librariesList.selectedIndex == -1 )
		return;
	var name : String = librariesList.selectedItem.@Name;
	dataManager.removeLibrary( name );
}

private function setNameHandler( event : ScriptEditorEvent ) : void
{
	var scriptName : String = event.scriptName;
	var action : String = event.currentTarget.name;

	if ( action == "addScript" )
		createScript( scriptName );
	else if ( action == "addLibrary" )
		createLibrary( scriptName );
}

private function dataManager_pageChangedHandler( dmEvt : DataManagerEvent ) : void
{
	containersBranch.currentPageID = dataManager.currentPageId;
}

private function dataManager_objectChangedHandler( dmEvt : DataManagerEvent ) : void
{
	serverScripts.dataProvider = dataManager.currentObjectId;
}

private function dataManager_getLibrariesCompleteHandler( event : DataManagerEvent ) : void
{
	libraries = event.result.*;
	librariesChanged = true;
	invalidateProperties();
}

private function dataManager_setLibraryCompleteHandler( event : DataManagerEvent ) : void
{
	libraries += event.result as XML;
	librariesChanged = true;
	invalidateProperties();
}

private function dataManager_removeLibraryCompleteHandler( event : DataManagerEvent ) : void
{
	var name : String = event.result.@Name;

	for ( var i : int = 0; i < libraries.length(); i++ )
	{
		if ( libraries[ i ].@Name == name )
			delete libraries[ i ];
	}

	librariesChanged = true;
	invalidateProperties();
}
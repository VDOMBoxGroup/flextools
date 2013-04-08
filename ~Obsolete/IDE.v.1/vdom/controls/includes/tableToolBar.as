import mx.core.UIComponent;

import vdom.containers.IItem;
import vdom.controls.wysiwyg.table.Table;
import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;
import vdom.managers.RenderManager;
import vdom.managers.renderClasses.ItemDescription;

private var dataManager : DataManager = DataManager.getInstance();
private var renderManager : RenderManager = RenderManager.getInstance();

private var item : IItem;
private var table : Table;
private var attributeName : String;
private var objectId : String;
private var resourceId : String;

private var _selfChanged : Boolean = true;

private var _selectedItem : IItem;

public function get selectedItem() : IItem 
{
	return _selectedItem;
}

public function set selectedItem( value : IItem ) : void 
{
	_selectedItem = value;
}

public function init( item : IItem ) : void {
	
	this.item = item;
	table = item.editableAttributes[ 0 ].sourceObject;
	
	dataManager.addEventListener( 
		DataManagerEvent.GET_OBJECT_XML_SCRIPT_COMPLETE, 
		getObjectXMLScriptCompleteHandler );
	
	dataManager.getObjectXMLScript( table.objectId );
	
//	renderManager.hideItemById( item.objectId );
	
//	var container : Object = item.editableAttributes[0].sourceObject;
//	
//	attributeName = "value";
//	
//	objectId = item.objectId;
//	
//	var resRegExp : RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;
//	
//	var result : Array = container['value'].match(resRegExp);
//	
//	if(result && result[1])
//		resourceId = container['value'].match(resRegExp)[1]
//	else
//		enabled = false;
}

public function close() : void {
	
}

public function get selfChanged() : Boolean {
	
	return _selfChanged;
}

private function test() : void {
	
	var objDescr : ItemDescription = renderManager.getItemDescriptionById( item.objectId );
	
	var dummy : ItemDescription = renderManager.getItemDescriptionById( table.objectId ); // FIXME remove dummy
	
	var dmy : XML = new XML( dummy.XMLPresentation );
	
	UIComponent( item ).visible = false;
	
	dmy.@contents = "static";
	
	renderManager.renderItem( dummy.parentId, dmy )
}

private function rotate(value : int) : void {
	
	applyChanges( 'rotate',
		<Attributes>
			<Attribute Name="method">{value}</Attribute>
		</Attributes>
	);
}

private function brightness(value : Number) : void {
	
	applyChanges( 'brightness',
		<Attributes>
			<Attribute Name="factor">{value}</Attribute>
		</Attributes>
	);
}

private function contrast(value : Number) : void {
	
	applyChanges('contrast',
		<Attributes>
			<Attribute Name="factor">{value}</Attribute>
		</Attributes>
	);
}

private function flip(value : int) : void {
	
	applyChanges('flip',
		<Attributes>
			<Attribute Name="method">{value}</Attribute>
		</Attributes>
	);
}

private function greyscale() : void {
	
	applyChanges('greyscale', null);
}

private function applyChanges(operation : String, attributes : XML) : void {
	
	item.waitMode = true;
	dataManager.addEventListener(DataManagerEvent.MODIFY_RESOURCE_COMPLETE, resourceModifedHandler);
	dataManager.modifyResource(resourceId, operation, attributeName, attributes);
}

private function resourceModifedHandler(event : DataManagerEvent) : void {
	
	var resId : String = event.result.Object.Attributes.Attribute.(@Name == "value")[0];
	
	var resRegExp : RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;
	
	resourceId = resId.match(resRegExp)[1]
}

private function getObjectXMLScriptCompleteHandler( event : DataManagerEvent ) : void
{
	var dummy : * = ""; // FIXME remove dummy
}
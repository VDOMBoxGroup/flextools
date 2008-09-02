import vdom.containers.IItem;
import vdom.events.DataManagerEvent;
import vdom.managers.DataManager;

private var dataManager:DataManager = DataManager.getInstance();

private var item:IItem;
private var attributeName:String;
private var objectId:String;
private var resourceId:String;

private var _selfChanged:Boolean = true;

public function init(item:IItem):void {
	
	this.item = item;
	
	var container:Object = item.editableAttributes[0].sourceObject;
	
	attributeName = "value";
	
	objectId = item.objectId;
	
	var resRegExp:RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;
	
	var result:Array = container['value'].match(resRegExp);
	
	if(result && result[1])
		resourceId = container['value'].match(resRegExp)[1]
	else
		enabled = false;
}

public function close():void {
	
}

public function get selfChanged():Boolean {
	
	return _selfChanged;
}

private function rollback():void {
	
	applyChanges('rollback', null);
}

private function rotate(value:int):void {
	
	applyChanges('rotate',
		<Attributes>
			<Attribute Name="method">{value}</Attribute>
		</Attributes>
	);
}

private function brightness(value:Number):void {
	
	applyChanges('brightness',
		<Attributes>
			<Attribute Name="factor">{value}</Attribute>
		</Attributes>
	);
}

private function contrast(value:Number):void {
	
	applyChanges('contrast',
		<Attributes>
			<Attribute Name="factor">{value}</Attribute>
		</Attributes>
	);
}

private function flip(value:int):void {
	
	applyChanges('flip',
		<Attributes>
			<Attribute Name="method">{value}</Attribute>
		</Attributes>
	);
}

private function greyscale():void {
	
	applyChanges('greyscale', null);
}

private function applyChanges(operation:String, attributes:XML):void {
	
	item.waitMode = true;
	dataManager.addEventListener(DataManagerEvent.RESOURCE_MODIFIED, resourceModifedHandler);
	dataManager.modifyResource(resourceId, operation, attributeName, attributes);
}

private function resourceModifedHandler(event:DataManagerEvent):void {
	
	var resId:String = event.result.Object.Attributes.Attribute.(@Name == "value")[0];
	
	var resRegExp:RegExp = /^#Res\(([-a-zA-Z0-9]*)\)/;
	
	resourceId = resId.match(resRegExp)[1]
}
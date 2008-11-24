import mx.binding.utils.BindingUtils;
import mx.core.Application;

import vdom.managers.DataManager;
import vdom.managers.FileManager;

private var dataManager:DataManager = DataManager.getInstance();
private var fileManager:FileManager = FileManager.getInstance();

private var watchers:Array;

private function showHandler():void
{
	watchers = [];
	
	watchers.push(
		BindingUtils.bindProperty(this, 'dataProvider', dataManager, 'currentApplicationInformation')
	);
}

public function set dataProvider(value:XML):void
{
	if(!value)
		return;
	
	applicationName.text = value.Name;
	applicationDescription.text = value.Description;
	
	if(value.Icon.toString())
		fileManager.loadResource(value.Id, value.Icon, applicationIcon, 'source', true);
	else
		applicationIcon.source = Application.application.getStyle('appIconPersonalPages');
}
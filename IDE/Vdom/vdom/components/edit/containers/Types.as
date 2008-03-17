package vdom.components.editor.containers {

import mx.collections.ArrayCollection;
import mx.containers.Accordion;
import mx.containers.VBox;

import vdom.components.editor.containers.typesClasses.Type;
import vdom.managers.FileManager;
	
public class Types extends Accordion {
	
	private var fileManager:FileManager;
	
	public function Types()	{
		
		super();
		
		fileManager = FileManager.getInstance();
	}
	
	public function set dataProvider(typesXML:XML):void {
		
		var cat:Object = {};
		var typesCollection:ArrayCollection = new ArrayCollection();
		for each (var num:XML in typesXML.Type) {
			
			if(!cat[num.Information.Category]) {
				
				cat[num.Information.Category] = new VBox();
				addChild(cat[num.Information.Category]);
			}
			
			cat[num.Information.Category].label = num.Information.Category;
			cat[num.Information.Category].setStyle('horizontalAlign', 'center');
			cat[num.Information.Category].horizontalScrollPolicy = 'off';
			cat[num.Information.Category].percentWidth = 100;
			
			var et:Type = new Type(num);
			
			et.setStyle('horizontalAlign', 'center');
			et.width = 90;
			et.aviableContainers = num.Information.Containers;
			
			var resourceID:String = num.Information.Icon;
			var resourceRE:RegExp = /#Res\((.*)\)/;
			resourceID = resourceID.match(resourceRE)[1];
			
			fileManager.loadResource(num.Information.ID, resourceID, et);
			cat[num.Information.Category].addChild(et); 
		}
	}
}
}
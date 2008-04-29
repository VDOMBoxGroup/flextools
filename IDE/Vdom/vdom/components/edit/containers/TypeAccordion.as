package vdom.components.edit.containers {

import mx.collections.ArrayCollection;
import mx.containers.Accordion;

import vdom.components.edit.containers.typeAccordionClasses.Type;
import vdom.components.edit.containers.typeAccordionClasses.Types;
import vdom.managers.FileManager;
	
public class TypeAccordion extends Accordion {
	
	private var fileManager:FileManager;
	private var categories:Object;
	
	public function TypeAccordion()	{
		
		super();
		
		fileManager = FileManager.getInstance();
		categories = {};
	}
	
	public function set dataProvider(typesXML:XMLList):void {
		
		var typesCollection:ArrayCollection = new ArrayCollection();
		
		var standardCategory:Array = ['STANDARD', 'FORM', 'TABLE', 'DATABASE'];
		
		for each (var category:String in standardCategory)
			insertCategory(category);
		
		for each (var num:XML in typesXML) {
			
			if(num.Information.Container == 3)
				continue;
			
			var categoryName:String = String(num.Information.Category).toUpperCase();
			var currentCategory:Types = insertCategory(categoryName);
			
			var et:Type = new Type(num);
			
			et.setStyle('horizontalAlign', 'center');
			et.width = 90;
			et.aviableContainers = num.Information.Containers;
			
			var resourceID:String = num.Information.Icon;
			var resourceRE:RegExp = /#Res\((.*)\)/;
			resourceID = resourceID.match(resourceRE)[1];
			
			fileManager.loadResource(num.Information.ID, resourceID, et);
			currentCategory.addChild(et); 
		}
	}
	
	private function insertCategory(categoryName:String):Types {
		
		var currentCategory:Types;
		
		if(!categories[categoryName]) {
			
			currentCategory	= new Types();
			
			categories[categoryName] = currentCategory;
			addChild(currentCategory);
			
			currentCategory.label = categoryName;
			currentCategory.setStyle('horizontalAlign', 'center');
			currentCategory.horizontalScrollPolicy = 'off';
			currentCategory.percentWidth = 100;
			
		} else {
			
			currentCategory = categories[categoryName];
		}

		return currentCategory;
	}
}
}
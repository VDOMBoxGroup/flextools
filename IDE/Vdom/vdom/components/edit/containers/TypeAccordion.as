package vdom.components.edit.containers {

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Accordion;

import vdom.components.edit.containers.typeAccordionClasses.Type;
import vdom.components.edit.containers.typeAccordionClasses.Types;
import vdom.managers.FileManager;
	
public class TypeAccordion extends Accordion {
	
	private var fileManager:FileManager;
	private var categories:Object;
	private var types:ArrayCollection;
	
	public function TypeAccordion()	{
		
		super();
		
		fileManager = FileManager.getInstance();
		categories = {};
		types = new ArrayCollection();
	}
	
	public function set dataProvider(typesXML:XMLList):void {
		
		if(!typesXML) return;
		
		var typeId:String, displayName:String, phraseId:String, resourceId:String, 
			typeName:String, categoryName:String, aviableContainers:String;
		
		var phraseRE:RegExp = /#Lang\((\w+)\)/;
		var resourceRE:RegExp = /#Res\((.*)\)/;
		
		for each (var typeDescription:XML in typesXML) {
			
			if(typeDescription.Information.Container == 3)
				continue;
			
			typeId = typeDescription.Information.ID;
			
			displayName = typeDescription.Information.DisplayName;
		
			phraseId = displayName.match(phraseRE)[1];
			
			resourceId = typeDescription.Information.Icon;
			resourceId = resourceId.match(resourceRE)[1];
			
			typeName = resourceManager.getString(typeDescription.Information.Name, phraseId);
			categoryName = String(typeDescription.Information.Category).toUpperCase();
			
			aviableContainers = typeDescription.Information.Containers;
			
			types.addItem({
				typeName:typeName, 
				categoryName:categoryName, 
				typeId:typeId, 
				resourceId:resourceId,
				aviableContainers:aviableContainers
			});
		}
		
		types.sort = new Sort();
		types.sort.fields = [new SortField('typeName')];
		types.refresh();
		
		var standardCategory:Array = ['STANDARD', 'FORM', 'TABLE', 'DATABASE'];
		
		for each (var category:String in standardCategory)
			insertCategory(category);
		
		var type:Type, currentCategory:Types;		
		
		var cursor:IViewCursor = types.createCursor();
		
		var currentDescription:Object;
		
		while(!cursor.afterLast) {
			
			currentDescription = cursor.current;
			
			currentCategory = insertCategory(currentDescription.categoryName);
			
			type = new Type(currentDescription);
			
			type.setStyle('horizontalAlign', 'center');
			type.width = 90;
			type.typeLabel = currentDescription.typeName;
			
			currentCategory.addChild(type);
			fileManager.loadResource(currentDescription.typeId, currentDescription.resourceId, type, 'resource', true);
			cursor.moveNext();
		}
			
		
		/* for each (var num:XML in typesXML) {
			 
			currentCategory = insertCategory(categoryName);
			
			type = new Type(num);
			
			type.setStyle('horizontalAlign', 'center');
			type.width = 90;
			
			resourceID = num.Information.Icon;
			resourceID = resourceID.match(resourceRE)[1];
			
			fileManager.loadResource(num.Information.ID, resourceID, type);
			currentCategory.addChild(type);
		} */
	}
	
	private function insertCategory(categoryName:String):Types {
		
		var currentCategory:Types;
		
		if(!categories[categoryName]) {
			
			currentCategory	= new Types();
			
			categories[categoryName] = currentCategory;
			
			currentCategory.label = categoryName;
			currentCategory.setStyle('horizontalAlign', 'center');
			currentCategory.horizontalScrollPolicy = 'off';
			currentCategory.percentWidth = 100;
			
			addChild(currentCategory);
			
		} else {
			
			currentCategory = categories[categoryName];
		}

		return currentCategory;
	}
}
}
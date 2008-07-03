package vdom.components.edit.containers {

import mx.collections.ArrayCollection;
import mx.collections.IViewCursor;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Accordion;

import vdom.components.edit.containers.typeAccordionClasses.Type;
import vdom.components.edit.containers.typeAccordionClasses.Types;
import vdom.managers.ExternalManager;
import vdom.managers.FileManager;

public class TypeAccordion extends Accordion {
	
	private var fileManager:FileManager;
	private var categories:Object = {};
	private var types:ArrayCollection;
	
	private var phraseRE:RegExp = /#lang\((\w+)\)/;
	private var resourceRE:RegExp = /#Res\((.*)\)/;
	
	private var standardCategories:Array = ['standard', 'form', 'table', 'database', 'debug'];
	
	public function TypeAccordion()	{
		
		super();
		
		fileManager = FileManager.getInstance();
		types = new ArrayCollection();
	}
	
	public function set dataProvider(typesXML:XMLList):void {
		
		if(!typesXML) return;
		
		var typeId:String, displayName:String, phraseId:String, resourceId:String, 
			typeName:String, typeNameLocalized:String, categoryName:String, aviableContainers:String;
		
		for each (var typeDescription:XML in typesXML) {
			
			if(typeDescription.Information.Container == 3)
				continue;
			
			typeId = typeDescription.Information.ID;
			
			displayName = typeDescription.Information.DisplayName.toLowerCase();
		
			phraseId = displayName.match(phraseRE)[1];
			
			resourceId = typeDescription.Information.Icon;
			resourceId = resourceId.match(resourceRE)[1];
			
			typeName = typeDescription.Information.Name;
			typeNameLocalized = resourceManager.getString(typeName, phraseId);
			categoryName = String(typeDescription.Information.Category)
			
			aviableContainers = typeDescription.Information.Containers;
			
			types.addItem({
				typeName:typeName,
				typeNameLocalized:typeNameLocalized,
				categoryName:categoryName, 
				typeId:typeId,
				resourceId:resourceId,
				aviableContainers:aviableContainers
			});
		}
		
		types.sort = new Sort();
		types.sort.fields = [new SortField('typeName')];
		types.refresh();
		
		var labelValue:String;
		
		for each (var category:String in standardCategories) {
			
			labelValue = resourceManager.getString('Edit', category);
			insertCategory(category, labelValue);
		}
		
		var type:Type, currentCategory:Types;		
		
		var cursor:IViewCursor = types.createCursor();
		
		var currentDescription:Object;
		
		while(!cursor.afterLast) {
			
			currentDescription = cursor.current;
			categoryName = currentDescription.categoryName.toLowerCase();
			
			labelValue = null;
			
			if(standardCategories.indexOf(categoryName) != -1)
				labelValue = resourceManager.getString('Edit', categoryName);
				
			else if (categoryName.match(phraseRE)) {
				
				phraseId = categoryName.match(phraseRE)[1];
				categoryName = 'lang_' + phraseId;
				labelValue = resourceManager.getString(currentDescription.typeName, phraseId);
			}
			
			if(!labelValue) {
				cursor.moveNext();
				continue;
			}
				
			
			currentCategory = insertCategory(categoryName, labelValue);
			
			type = new Type(currentDescription);
			
			type.setStyle('horizontalAlign', 'center');
			type.width = 90;
			type.typeLabel = currentDescription.typeNameLocalized;
			
			currentCategory.addChild(type);
			fileManager.loadResource(currentDescription.typeId, currentDescription.resourceId, type, 'resource', true);
			cursor.moveNext();
		}
	}
	
	private function insertCategory(categoryName:String, label:String):Types {
		
		var currentCategory:Types;
		
		
		
		if(!categories[categoryName]) {
			
			currentCategory	= new Types();
			
			categories[categoryName] = currentCategory;
	
			currentCategory.label = label;
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
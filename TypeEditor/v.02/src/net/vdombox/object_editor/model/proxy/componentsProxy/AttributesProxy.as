/*
	Class AtributesProxy is a wrapper over the Atributes
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class AttributesProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "AttributesProxy";

		public function AttributesProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( attributesVO: ArrayCollection ):XML
		{		
			var attribsXML:XML = new XML("<Attributes/>");		
			
			for each(var obj:Object in attributesVO )
			{	
				var attribVO:AttributeVO = obj.data;
				var attrXML:XML = new XML("<Attribute/>");
				attrXML.Name			= attribVO.name;
				attrXML.DisplayName		= attribVO.displayName;
				attrXML.DefaultValue	= attribVO.defaultValue;	
				attrXML.Visible			= attribVO.visible;	
				attrXML.Help			= attribVO.help;
				attrXML.InterfaceType	= attribVO.interfaceType;
				attrXML.CodeInterface	= attribVO.codeInterface;	
				attrXML.Colorgroup		= attribVO.colorgroup;
				attrXML.ErrorValidationMessage		= attribVO.errorValidationMessage;
				attrXML.RegularExpressionValidation	= attribVO.regularExpressionValidation;
				attribsXML.appendChild(attrXML);
			}
			return attribsXML;
		}	
		
		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var atributesCollection:ArrayCollection = new ArrayCollection();
			
			for each ( var attrinuteXML : XML in objTypeXML.descendants("Attribute") )
			{
				var atrib:AttributeVO = new AttributeVO;
				
				atrib.name			= attrinuteXML.Name;
				atrib.displayName	= attrinuteXML.DisplayName;
				atrib.defaultValue	= attrinuteXML.DefaultValue;
				atrib.visible		= attrinuteXML.Visible.toString() == "1";
				atrib.help			= attrinuteXML.Help;
				atrib.interfaceType	= attrinuteXML.InterfaceType;
				atrib.codeInterface	= attrinuteXML.CodeInterface;
				atrib.colorgroup	= attrinuteXML.Colorgroup;
				atrib.errorValidationMessage		= attrinuteXML.ErrorValidationMessage;
				atrib.regularExpressionValidation	= attrinuteXML.RegularExpressionValidation;
				
				atributesCollection.addItem({label:atrib.name, data:atrib});	
			}			
			return atributesCollection;
		}
	}
}
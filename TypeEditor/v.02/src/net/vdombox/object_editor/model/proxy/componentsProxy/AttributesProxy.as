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
			var attribsXML:XML = <Attributes/>;		
			
			for each (var obj:Object in attributesVO)
			{	
				var attribVO:AttributeVO = obj.data;
				var attrXML:XML = <Attribute/>;
				attrXML.Name			= attribVO.name;
				attrXML.DisplayName		= attribVO.displayName;
				attrXML.DefaultValue	= attribVO.defaultValue;	
				attrXML.Visible			= (attribVO.visible)? "1": "0";	
				attrXML.Help			= attribVO.help;
				attrXML.InterfaceType	= attribVO.interfaceType;
				attrXML.CodeInterface	= attribVO.codeInterface;
				attrXML.CodeInterface	= attribVO.codeInterface.replace("Number1", "Number");
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
			
			for each (var attrinuteXML : XML in objTypeXML.descendants("Attribute"))
			{
				var attrib:AttributeVO = new AttributeVO;
				
				attrib.name			= attrinuteXML.Name;
				attrib.displayName	= attrinuteXML.DisplayName;
				attrib.defaultValue	= attrinuteXML.DefaultValue;
				attrib.visible		= attrinuteXML.Visible.toString() == "1";
				attrib.help			= attrinuteXML.Help;
				attrib.interfaceType	= attrinuteXML.InterfaceType;
				attrib.codeInterface	= attrinuteXML.CodeInterface;
				attrib.colorgroup	= attrinuteXML.Colorgroup;
				attrib.errorValidationMessage		= attrinuteXML.ErrorValidationMessage;
				attrib.regularExpressionValidation	= attrinuteXML.RegularExpressionValidation;
				
				atributesCollection.addItem({label:attrib.name, color:attrib.colorgroup, data:attrib});	
			}			
			return atributesCollection;
		}
	}
}